# eBPF Networking Lab

This repository contains hands-on examples for learning eBPF networking hooks.

## 📁 Directory Structure

Program directories are numbered to match the Instruqt challenge that uses them:

```
ebpf-networking-lab/
├── 05-xdp/           # Challenge 05: XDP packet processing
├── 06-tc/            # Challenge 06: Traffic Control (TC)
├── 08-socket/        # Challenge 08: Socket-level hooks (sockops + sk_msg)
├── 09-bpftrace/      # Challenge 09: Network observability
└── 12-exam/          # Challenge 12: Practical exam
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

### Build the programs

```bash
make all        # compiles every eBPF program to its .o
```

## 📚 Learning Path

1. **Challenge 01**: Networking basics
2. **Challenge 02**: Kernel & eBPF fundamentals
3. **Challenge 05**: XDP packet processing (`05-xdp/`)
4. **Challenge 06**: Traffic Control with TC (`06-tc/`)
5. **Challenge 08**: Socket-level networking (`08-socket/`)
6. **Challenge 09**: Network observability (`09-bpftrace/`)
7. **Challenge 11**: Real-world architectures (Cilium, Hubble, Katran)
8. **Challenge 10**: Checkpoint quiz
9. **Challenge 12**: Practical exam (`12-exam/`)

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
