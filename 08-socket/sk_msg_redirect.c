// Socket Message Redirect - Same-Host Stack Bypass
// This program redirects messages directly between two sockets on the same
// host, bypassing the TCP/IP stack for a large latency reduction.
//
// It is the *second half* of the socket-acceleration pattern:
//   1. sockops_tracker.c  populates a SOCKHASH with every established socket
//   2. sk_msg_redirect.c   (this program) runs on each sendmsg() and, if the
//      destination socket is in that same SOCKHASH, redirects the payload
//      straight to it - skipping TCP segmentation, IP routing, the qdisc and
//      the loopback driver entirely.
//
// Demonstrates:
// - BPF_PROG_TYPE_SK_MSG programs
// - bpf_msg_redirect_hash() socket-to-socket redirection
// - Sharing a SOCKHASH between a sockops and an sk_msg program

#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

// MUST match the key layout used by sockops_tracker.c so both programs share
// the same sockhash entries.
struct sock_key {
    __u32 src_ip;
    __u32 dst_ip;
    __u16 src_port;
    __u16 dst_port;
    __u32 family;  // AF_INET = 2
};

// Same SOCKHASH the sockops tracker fills. Declaring it identically here lets
// libbpf/bpftool share the one pinned map between both programs.
struct {
    __uint(type, BPF_MAP_TYPE_SOCKHASH);
    __uint(max_entries, 65536);
    __type(key, struct sock_key);
    __type(value, __u64);
} sock_map SEC(".maps");

// Redirect statistics (key 0 = redirected, key 1 = passed to normal stack)
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 2);
    __type(key, __u32);
    __type(value, __u64);
} redirect_stats SEC(".maps");

#define STAT_REDIRECTED 0
#define STAT_PASSED     1

static __always_inline void bump(__u32 slot)
{
    __u64 *v = bpf_map_lookup_elem(&redirect_stats, &slot);
    if (v)
        __sync_fetch_and_add(v, 1);
}

SEC("sk_msg")
int sk_msg_redirect_prog(struct sk_msg_md *msg)
{
    // Only handle IPv4.
    if (msg->family != 2)  // AF_INET
        return SK_PASS;

    // The peer socket was stored by sockops under ITS OWN 4-tuple. From the
    // sender's point of view the peer's (src,dst) is our (dst,src), so we swap
    // to build the lookup key for the destination socket.
    struct sock_key key = {};
    key.src_ip   = msg->remote_ip4;
    key.dst_ip   = msg->local_ip4;
    key.src_port = (__u16)bpf_ntohl(msg->remote_port);  // remote_port is net order
    key.dst_port = (__u16)msg->local_port;              // local_port is host order
    key.family   = msg->family;

    // Redirect straight to the peer socket's ingress queue if we know it.
    // BPF_F_INGRESS (flag 1) delivers into the peer's receive path.
    long ret = bpf_msg_redirect_hash(msg, &sock_map, &key, BPF_F_INGRESS);

    if (ret == SK_PASS) {
        bump(STAT_REDIRECTED);
        return SK_PASS;
    }

    // No matching peer socket (e.g. remote/off-host) - use the normal stack.
    bump(STAT_PASSED);
    return SK_PASS;
}

char _license[] SEC("license") = "GPL";
