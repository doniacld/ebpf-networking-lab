// Socket Operations Tracker - Connection Tracking per Cgroup
// This program tracks TCP connections within cgroups (containers)
//
// Demonstrates:
// - sockops program attachment
// - Connection establishment tracking
// - Populating sockmaps for later redirection
// - Extracting connection 4-tuple

#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

// Structure to store connection 4-tuple
struct sock_key {
    __u32 src_ip;
    __u32 dst_ip;
    __u16 src_port;
    __u16 dst_port;
    __u32 family;  // AF_INET = 2
};

// Map to store sockets (for sk_msg redirection)
struct {
    __uint(type, BPF_MAP_TYPE_SOCKHASH);
    __uint(max_entries, 65536);
    __type(key, struct sock_key);
    __type(value, __u64);
} sock_map SEC(".maps");

// Statistics per cgroup
struct conn_stats {
    __u64 active_connections;
    __u64 passive_connections;
    __u64 total_connections;
};

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1024);
    __type(key, __u64);                  // cgroup ID
    __type(value, struct conn_stats);
} cgroup_stats SEC(".maps");

// Helper to extract socket key
static __always_inline void extract_key(struct bpf_sock_ops *skops,
                                        struct sock_key *key)
{
    key->src_ip = skops->local_ip4;
    key->dst_ip = skops->remote_ip4;
    key->src_port = skops->local_port;
    key->dst_port = bpf_ntohl(skops->remote_port);  // Convert to host byte order
    key->family = skops->family;
}

SEC("sockops")
int sockops_connection_tracker(struct bpf_sock_ops *skops)
{
    struct sock_key key;
    struct conn_stats *stats;
    struct conn_stats new_stats;
    __u64 cgroup_id;
    __u32 op = skops->op;

    // Only handle IPv4 TCP
    if (skops->family != 2)  // AF_INET
        return 0;

    // Get cgroup ID for this socket
    cgroup_id = bpf_get_current_cgroup_id();

    switch (op) {
    case BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB:
        // Server side connection established (accepted)
        extract_key(skops, &key);

        // Add socket to sockmap for potential redirection
        bpf_sock_hash_update(skops, &sock_map, &key, BPF_NOEXIST);

        // Update cgroup statistics
        stats = bpf_map_lookup_elem(&cgroup_stats, &cgroup_id);
        if (stats) {
            __sync_fetch_and_add(&stats->passive_connections, 1);
            __sync_fetch_and_add(&stats->total_connections, 1);
        } else {
            // Initialize new stats entry
            new_stats.passive_connections = 1;
            new_stats.active_connections = 0;
            new_stats.total_connections = 1;
            bpf_map_update_elem(&cgroup_stats, &cgroup_id, &new_stats, BPF_ANY);
        }
        break;

    case BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB:
        // Client side connection established (connected)
        extract_key(skops, &key);

        // Add socket to sockmap
        bpf_sock_hash_update(skops, &sock_map, &key, BPF_NOEXIST);

        // Update cgroup statistics
        stats = bpf_map_lookup_elem(&cgroup_stats, &cgroup_id);
        if (stats) {
            __sync_fetch_and_add(&stats->active_connections, 1);
            __sync_fetch_and_add(&stats->total_connections, 1);
        } else {
            // Initialize new stats entry
            new_stats.active_connections = 1;
            new_stats.passive_connections = 0;
            new_stats.total_connections = 1;
            bpf_map_update_elem(&cgroup_stats, &cgroup_id, &new_stats, BPF_ANY);
        }
        break;

    case BPF_SOCK_OPS_TCP_CONNECT_CB:
        // Connection attempt started
        // Could log this for connection tracking
        break;

    default:
        break;
    }

    return 0;
}

char _license[] SEC("license") = "GPL";

/*
 * How to compile:
 * clang -O2 -g -target bpf -c sockops_tracker.c -o sockops_tracker.o
 *
 * How to load (attach to root cgroup for system-wide tracking):
 * bpftool cgroup attach /sys/fs/cgroup/ sock_ops pinned /sys/fs/bpf/sockops_tracker
 *
 * Or load and pin:
 * bpftool prog load sockops_tracker.o /sys/fs/bpf/sockops_tracker
 * bpftool cgroup attach /sys/fs/cgroup/ sock_ops pinned /sys/fs/bpf/sockops_tracker
 *
 * How to view sockmap:
 * bpftool map dump name sock_map
 *
 * How to view per-cgroup statistics:
 * bpftool map dump name cgroup_stats
 *
 * How to detach:
 * bpftool cgroup detach /sys/fs/cgroup/ sock_ops pinned /sys/fs/bpf/sockops_tracker
 */
