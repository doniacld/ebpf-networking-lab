# Socket Hooks

Socket-level eBPF programs attach at **Layer 4** - at socket operations like connect, send, and receive.

## 🎯 Use Cases

- **Same-Node Acceleration**: Bypass TCP/IP stack for local traffic
- **Connection Tracking**: Monitor established connections
- **Service Mesh**: Transparent proxying and load balancing
- **Security Policies**: Block connections at socket layer

## 🔧 Socket Hook Types

**sockops** (BPF_PROG_TYPE_SOCK_OPS):
- Runs on socket operations (connect, accept, state change)
- Can populate sockmaps for connection tracking
- Monitors TCP connection lifecycle

**sk_msg** (BPF_PROG_TYPE_SK_MSG):
- Runs on sendmsg operations
- Can redirect data between sockets
- Bypasses TCP/IP stack for huge performance gains

**sk_skb** (BPF_PROG_TYPE_SK_SKB):
- Runs on socket buffers
- Policy enforcement at socket layer
- Stream parser for protocol detection

## 📁 Programs

- `sockops_tracker.c` - Tracks TCP connections per cgroup and populates a **SOCKHASH** with every established socket (the foundation for redirection).
- `sk_msg_redirect.c` - Runs on every `sendmsg()` and, when the destination socket is in that SOCKHASH, redirects the payload **directly to the peer socket** with `bpf_msg_redirect_hash()` - bypassing TCP segmentation, IP routing, the qdisc and the loopback driver.

The two work as a pair: `sockops_tracker` fills the shared `sock_map`, and `sk_msg_redirect` consumes it.

## 🔬 Try the redirect (same-host acceleration)

Both programs must share the **same** pinned `sock_map`:

```bash
BPFFS=/sys/fs/bpf; CG=/sys/fs/cgroup

# 1. Load the sockops tracker and pin its maps (incl. sock_map)
bpftool prog load 05-socket/sockops_tracker.o $BPFFS/sockops_tracker pinmaps $BPFFS/sockops_maps
bpftool cgroup attach $CG sock_ops pinned $BPFFS/sockops_tracker

# 2. Load sk_msg REUSING the same pinned sock_map, then attach it to the sockhash
bpftool prog load 05-socket/sk_msg_redirect.o $BPFFS/sk_msg_redirect \
    map name sock_map pinned $BPFFS/sockops_maps/sock_map pinmaps $BPFFS/skmsg_maps
bpftool prog attach pinned $BPFFS/sk_msg_redirect msg_verdict pinned $BPFFS/sockops_maps/sock_map

# 3. Generate same-host TCP traffic, then read the redirect counters
#    key 0 = REDIRECTED (bypassed the stack), key 1 = PASSED (normal path)
bpftool map dump pinned $BPFFS/skmsg_maps/redirect_stats

# 4. Clean up
bpftool prog detach pinned $BPFFS/sk_msg_redirect msg_verdict pinned $BPFFS/sockops_maps/sock_map
bpftool cgroup detach $CG sock_ops pinned $BPFFS/sockops_tracker
rm -rf $BPFFS/sockops_tracker $BPFFS/sk_msg_redirect $BPFFS/sockops_maps $BPFFS/skmsg_maps
```

> **Note**: redirection only kicks in once *both* peer sockets are established and recorded in the sockhash, so establish the connection first, then send.
