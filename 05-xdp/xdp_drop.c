// XDP Drop Program - DDoS Mitigation Example
// This program drops packets from blocked IP addresses stored in an eBPF map
//
// Demonstrates:
// - Parsing Ethernet and IP headers
// - Looking up values in eBPF hash maps
// - Returning XDP actions (DROP vs PASS)

#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

// Map to store blocked IP addresses
// Key: IPv4 address (32-bit)
// Value: 1 (presence indicates blocked)
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 10000);
    __type(key, __u32);      // IPv4 address
    __type(value, __u32);    // 1 = blocked
} blocked_ips SEC(".maps");

// Statistics map to track drops and passes
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 2);
    __type(key, __u32);
    __type(value, __u64);
} xdp_stats SEC(".maps");

#define STAT_DROPPED 0
#define STAT_PASSED  1

SEC("xdp")
int xdp_drop_blocked_ips(struct xdp_md *ctx)
{
    // Get packet start and end pointers
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;

    // Parse Ethernet header
    struct ethhdr *eth = data;

    // Bounds check: ensure we can read Ethernet header
    if ((void *)(eth + 1) > data_end)
        return XDP_PASS;

    // Only process IPv4 packets (EtherType 0x0800)
    if (eth->h_proto != bpf_htons(ETH_P_IP))
        return XDP_PASS;

    // Parse IP header
    struct iphdr *ip = (void *)(eth + 1);

    // Bounds check: ensure we can read IP header
    if ((void *)(ip + 1) > data_end)
        return XDP_PASS;

    // Extract source IP address (network byte order)
    __u32 src_ip = ip->saddr;

    // Look up source IP in blocked list
    __u32 *blocked = bpf_map_lookup_elem(&blocked_ips, &src_ip);

    // Update statistics
    __u32 stat_key;
    __u64 *stat_value;

    if (blocked) {
        // IP is blocked - drop the packet
        stat_key = STAT_DROPPED;
        stat_value = bpf_map_lookup_elem(&xdp_stats, &stat_key);
        if (stat_value)
            __sync_fetch_and_add(stat_value, 1);

        return XDP_DROP;
    }

    // IP is not blocked - pass the packet
    stat_key = STAT_PASSED;
    stat_value = bpf_map_lookup_elem(&xdp_stats, &stat_key);
    if (stat_value)
        __sync_fetch_and_add(stat_value, 1);

    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";

/*
 * Compile:  make xdp   (or: clang -O2 -g -target bpf -c xdp_drop.c -o xdp_drop.o)
 *
 * Load (generic XDP on loopback for the lab):
 *   ip link set dev lo xdpgeneric obj xdp_drop.o sec xdp
 *
 * Block an IP (127.0.0.1 -> bytes 0x7f 0x00 0x00 0x01, value 1 = blocked):
 *   bpftool map update name blocked_ips key 0x7f 0x00 0x00 0x01 value 0x01 0x00 0x00 0x00
 *
 * View statistics:    bpftool map dump name xdp_stats
 * Unload:             ip link set dev lo xdpgeneric off
 */
