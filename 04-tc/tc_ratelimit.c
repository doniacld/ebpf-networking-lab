// TC Rate Limiter Program - Token Bucket Algorithm
// This program enforces bandwidth limits using a token bucket algorithm
//
// Demonstrates:
// - Token bucket rate limiting
// - TC actions (TC_ACT_OK vs TC_ACT_SHOT)
// - Per-flow tracking with eBPF maps
// - Timestamp handling in eBPF

#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

// Token bucket state
struct token_bucket {
    __u64 tokens;           // Current token count (in bytes)
    __u64 last_update_ns;   // Last update timestamp (nanoseconds)
};

// Configuration for rate limiting
struct rate_config {
    __u64 rate_bps;         // Rate in bytes per second
    __u64 burst_bytes;      // Maximum burst size in bytes
};

// Map to store token bucket state per interface
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1);
    __type(key, __u32);                  // ifindex
    __type(value, struct token_bucket);
} token_buckets SEC(".maps");

// Map to store rate configuration
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 1);
    __type(key, __u32);
    __type(value, struct rate_config);
} rate_config SEC(".maps");

// Statistics
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 3);
    __type(key, __u32);
    __type(value, __u64);
} tc_stats SEC(".maps");

#define STAT_PASSED      0
#define STAT_DROPPED     1
#define STAT_BYTES_TOTAL 2

// Helper function to update token bucket
static __always_inline int update_tokens(struct token_bucket *bucket,
                                         struct rate_config *config,
                                         __u64 now_ns,
                                         __u32 packet_len)
{
    // Calculate elapsed time in nanoseconds
    __u64 elapsed_ns = now_ns - bucket->last_update_ns;

    // Calculate tokens to add based on rate and elapsed time
    // tokens_to_add = (rate_bps * elapsed_ns) / 1_000_000_000
    __u64 tokens_to_add = (config->rate_bps * elapsed_ns) / 1000000000;

    // Add tokens but cap at burst size
    bucket->tokens += tokens_to_add;
    if (bucket->tokens > config->burst_bytes)
        bucket->tokens = config->burst_bytes;

    // Update timestamp
    bucket->last_update_ns = now_ns;

    // Check if we have enough tokens for this packet
    if (bucket->tokens >= packet_len) {
        bucket->tokens -= packet_len;
        return 1;  // Allow packet
    }

    return 0;  // Drop packet (rate limit exceeded)
}

SEC("tc")
int tc_ratelimit_egress(struct __sk_buff *skb)
{
    // Get current timestamp
    __u64 now_ns = bpf_ktime_get_ns();

    // Get packet length
    __u32 packet_len = skb->len;

    // Get interface index
    __u32 ifindex = skb->ifindex;

    // Look up rate configuration
    __u32 config_key = 0;
    struct rate_config *config = bpf_map_lookup_elem(&rate_config, &config_key);
    if (!config) {
        // No rate limit configured - pass all traffic
        return TC_ACT_OK;
    }

    // Look up or initialize token bucket
    struct token_bucket *bucket = bpf_map_lookup_elem(&token_buckets, &ifindex);
    struct token_bucket new_bucket;

    if (!bucket) {
        // Initialize new bucket
        new_bucket.tokens = config->burst_bytes;
        new_bucket.last_update_ns = now_ns;
        bpf_map_update_elem(&token_buckets, &ifindex, &new_bucket, BPF_ANY);
        bucket = &new_bucket;
    }

    // Update statistics - total bytes
    __u32 stat_key = STAT_BYTES_TOTAL;
    __u64 *stat_value = bpf_map_lookup_elem(&tc_stats, &stat_key);
    if (stat_value)
        __sync_fetch_and_add(stat_value, packet_len);

    // Check rate limit
    int allow = update_tokens(bucket, config, now_ns, packet_len);

    // Update bucket in map
    bpf_map_update_elem(&token_buckets, &ifindex, bucket, BPF_ANY);

    if (allow) {
        // Update passed counter
        stat_key = STAT_PASSED;
        stat_value = bpf_map_lookup_elem(&tc_stats, &stat_key);
        if (stat_value)
            __sync_fetch_and_add(stat_value, 1);

        return TC_ACT_OK;  // Allow packet
    } else {
        // Update dropped counter
        stat_key = STAT_DROPPED;
        stat_value = bpf_map_lookup_elem(&tc_stats, &stat_key);
        if (stat_value)
            __sync_fetch_and_add(stat_value, 1);

        return TC_ACT_SHOT;  // Drop packet (rate limited)
    }
}

char _license[] SEC("license") = "GPL";

/*
 * How to compile:
 * clang -O2 -g -target bpf -c tc_ratelimit.c -o tc_ratelimit.o
 *
 * How to load (egress):
 * tc qdisc add dev eth0 clsact
 * tc filter add dev eth0 egress bpf da obj tc_ratelimit.o sec tc
 *
 * How to configure rate limit (10 Mbps = 1,250,000 bytes/sec):
 * bpftool map update name rate_config key 0 0 0 0 value \
 *   0x10 0x12 0x13 0x00 0x00 0x00 0x00 0x00 \  # rate_bps (1,250,000 in little-endian)
 *   0x00 0x00 0x10 0x00 0x00 0x00 0x00 0x00     # burst_bytes (1MB)
 *
 * How to view statistics:
 * bpftool map dump name tc_stats
 *
 * How to unload:
 * tc filter del dev eth0 egress
 * tc qdisc del dev eth0 clsact
 */
