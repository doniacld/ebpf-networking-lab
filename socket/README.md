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

This directory will contain socket programs demonstrated in Challenge 05.

Example:
- `sockops_tracker.c` - Track TCP connections per cgroup
- `sk_msg_redirect.c` - Accelerate same-node traffic
- `Makefile` - Build socket programs
- `README.md` - Detailed usage instructions

## 🚀 Coming Soon

Complete Challenge 05 to see socket acceleration in action!
