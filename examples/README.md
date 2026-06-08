# Networking Examples

This directory contains example scripts used in Challenge 01 to demonstrate networking concepts.

## Scripts Overview

### Layer 2 (Data Link)
- **`show_layer2.sh`** - Display network interfaces, MAC addresses, and link statistics
  - Uses: `ip link show`, `ip -s link`

### Layer 3 (Network)
- **`show_layer3.sh`** - Display IP addresses, routing table, and route lookups
  - Uses: `ip addr show`, `ip route show`, `ip route get`

### Layer 4 (Transport)
- **`show_layer4.sh`** - Display TCP/UDP sockets, connections, and statistics
  - Uses: `ss -tlnp`, `ss -tnp`, `ss -s`
- **`trace_socket_syscalls.sh`** - Trace socket system calls with strace
  - Uses: `strace` (standard tool, not eBPF)

### Layer 7 (Application)
- **`show_layer7.sh`** - Capture and display HTTP traffic (application layer)
  - Uses: `tcpdump -A`

### Packet Structure
- **`capture_packet.sh`** - Capture a packet and show its structure (all headers)
  - Uses: `tcpdump -XX`

## Usage

All scripts are self-contained and include:
- Explanation of what they do
- Command breakdowns (flags and options explained)
- Expected output examples
- Interpretation of the output

Simply run any script:
```bash
./show_layer2.sh
./show_layer3.sh
./show_layer4.sh
./trace_socket_syscalls.sh
./show_layer7.sh
./capture_packet.sh
```

## Prerequisites

- HTTP server running on `localhost:8080` (for traffic generation)
- Standard Linux networking tools: `ip`, `ss`, `tcpdump`, `strace`, `curl`

## Notes

These scripts use **standard Linux tools** only (no eBPF yet!). They demonstrate networking concepts before introducing eBPF hooks in later challenges.

Once you understand these layers with standard tools, you'll learn how to observe and manipulate them with eBPF programs.
