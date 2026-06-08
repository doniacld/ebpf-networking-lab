# eBPF Networking Lab

This repository contains hands-on examples for learning eBPF networking hooks.

## 📁 Directory Structure

```
ebpf-networking-lab/
├── examples/          # Challenge 01: Networking fundamentals demos
├── xdp/              # Challenge 03: XDP packet processing
├── tc/               # Challenge 04: Traffic Control (TC)
├── socket/           # Challenge 05: Socket-level hooks
└── bpftrace/         # Challenge 06: Network observability
```

## 🎯 Lab Overview

This lab teaches you how to use eBPF for networking through three use cases:

1. **Traffic Control** - Filtering, dropping, rate limiting (XDP, TC)
2. **Optimization** - Accelerating same-node traffic (socket hooks)
3. **Observability** - Understanding network behavior (kprobes, tracepoints)

## 🚀 Getting Started

Follow the [eBPF Networking track](https://play.instruqt.com/isovalent/tracks/ebpf-networking) on Instruqt.

Or explore locally:

### Prerequisites

- Linux kernel 5.10+ with BTF support
- Tools: `clang`, `bpftool`, `bpftrace`, `iproute2`, `tcpdump`

### Challenge 01: Networking Fundamentals

```bash
cd examples/
./capture_packet.sh       # See packet structure
./show_layer2.sh          # Layer 2 (interfaces)
./show_layer3.sh          # Layer 3 (routing)
./show_layer4.sh          # Layer 4 (sockets)
./show_layer7.sh          # Layer 7 (HTTP)
```

All scripts include explanations and expected output.

## 📚 Learning Path

1. **Challenge 01**: Networking fundamentals (this repository's `examples/`)
2. **Challenge 02**: Kernel networking internals
3. **Challenge 03**: XDP packet processing (`xdp/`)
4. **Challenge 04**: Traffic Control with TC (`tc/`)
5. **Challenge 05**: Socket-level networking (`socket/`)
6. **Challenge 06**: Network observability (`bpftrace/`)
7. **Challenge 07**: Real-world architectures (Cilium, Hubble, Katran)
8. **Challenge 08**: Quiz
9. **Challenge 09**: Practical exam

## 🏆 Badge

Complete the lab to earn a **Silver eBPF Networking** badge!

## 📖 Additional Resources

- [Getting Started with eBPF](https://play.instruqt.com/isovalent/tracks/ebpf-getting-started) - eBPF fundamentals
- [Cilium Documentation](https://docs.cilium.io/) - Production eBPF networking
- [BCC Tools](https://github.com/iovisor/bcc) - eBPF tracing tools
- [bpftrace](https://github.com/iovisor/bpftrace) - High-level tracing language

## 🤝 Contributing

This lab is part of the Isovalent learning platform. For issues or suggestions, contact the Isovalent TME team.

## 📄 License

Educational materials provided by Isovalent.
