# eBPF Networking Lab — Programs

Companion code for the **eBPF Networking** Isovalent lab. During the lab this
repository is cloned to `/root/ebpf-networking-lab` and you compile, load, and
inspect each program from there.

## Layout

```
.
├── xdp/      xdp_drop.c          DDoS mitigation — drop blocked source IPs (XDP)
├── tc/       tc_ratelimit.c      Token-bucket rate limiting (TC egress)
├── socket/   sockops_tracker.c   Per-cgroup TCP connection tracking (sockops)
├── bpftrace/ observe.sh          Interactive menu of observability one-liners
└── Makefile  build targets: make xdp | tc | socket | all | clean
```

## Build

```bash
make all        # build every program
make xdp        # build just xdp/xdp_drop.o
make clean      # remove all .o files
```

Requires `clang`, `llvm`, `libbpf` headers, and kernel headers for the running
kernel. The lab environment ships with these preinstalled.

## Programs

### `xdp/xdp_drop.c` — DDoS mitigation
Parses Ethernet + IPv4 headers, looks up the source IP in the `blocked_ips`
hash map, and returns `XDP_DROP` for blocked IPs (`XDP_PASS` otherwise). Drop
and pass counts are kept in the `xdp_stats` array map.

```bash
make xdp
ip link set dev lo xdpgeneric obj xdp/xdp_drop.o sec xdp
bpftool map update name blocked_ips key 0x7f 0x00 0x00 0x01 value 0x01 0x00 0x00 0x00  # block 127.0.0.1
bpftool map dump   name xdp_stats
ip link set dev lo xdpgeneric off
```

### `tc/tc_ratelimit.c` — token-bucket rate limiting
Refills a per-interface token bucket at a configured rate and returns
`TC_ACT_OK` (pass) or `TC_ACT_SHOT` (drop). Config lives in `rate_config`;
counters in `tc_stats`.

```bash
make tc
tc qdisc  add dev lo clsact
tc filter add dev lo egress bpf da obj tc/tc_ratelimit.o sec tc
bpftool map dump name tc_stats
tc qdisc del dev lo clsact
```

### `socket/sockops_tracker.c` — connection tracking
A `sockops` program that fires on TCP connection establishment, records the
4-tuple into a `SOCKHASH` (for `sk_msg` redirection), and keeps per-cgroup
connection counts in `cgroup_stats`.

```bash
make socket
bpftool prog load   socket/sockops_tracker.o /sys/fs/bpf/sockops_tracker type sockops
bpftool cgroup attach /sys/fs/cgroup sock_ops pinned /sys/fs/bpf/sockops_tracker
bpftool map dump    name cgroup_stats
bpftool cgroup detach /sys/fs/cgroup sock_ops pinned /sys/fs/bpf/sockops_tracker
rm /sys/fs/bpf/sockops_tracker
```

### `bpftrace/observe.sh` — observability one-liners
Interactive menu of common network observability patterns (connection
tracking, latency, retransmissions, drops, state changes).

```bash
./bpftrace/observe.sh
```

## References

- [eBPF documentation](https://ebpf.io/)
- [Cilium eBPF library](https://github.com/cilium/ebpf)
- [bpftrace](https://github.com/bpftrace/bpftrace)
