# Network Observability with bpftrace

bpftrace provides a high-level language for writing eBPF tracing scripts. Perfect for debugging, performance analysis, and understanding network behavior.

## 🎯 Use Cases

- **Debugging**: Trace packet drops, connection failures
- **Performance Analysis**: Measure latency at each layer
- **Security Auditing**: Monitor suspicious network activity
- **Troubleshooting**: Find root cause of network issues

## 🔧 Hook Types for Observability

**kprobes**:
- Attach to any kernel function
- Dynamic instrumentation (no kernel recompilation)
- Example: `kprobe:tcp_connect` traces TCP connection attempts

**tracepoints**:
- Stable kernel instrumentation points
- Designed for tracing (ABI stable)
- Example: `tracepoint:skb:kfree_skb` traces packet drops

**fprobes**:
- More efficient than kprobes
- Kernel 5.5+
- Example: `fprobe:tcp_*` traces all TCP functions

## 📁 Scripts

This directory will contain bpftrace scripts demonstrated in Challenge 06.

Example observability patterns:
- Track TCP connections
- Measure connection latency
- Find packet drops
- Monitor retransmissions
- Trace full connection lifecycle

## 🚀 Coming Soon

Complete Challenge 06 to learn network observability patterns!
