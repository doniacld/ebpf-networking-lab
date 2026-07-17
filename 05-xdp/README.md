# XDP (eXpress Data Path)

XDP programs run at the **earliest possible point** in packet processing - right after the network driver, before the kernel's network stack.

## 🎯 Use Cases

- **DDoS Protection**: Drop malicious packets at line-rate
- **Load Balancing**: Fast packet forwarding (e.g., Facebook's Katran)
- **Packet Filtering**: Pre-filter before expensive kernel processing

## 🔧 How XDP Works

XDP programs attach to network interfaces and return one of:
- `XDP_PASS`: Let packet continue to kernel stack
- `XDP_DROP`: Drop packet immediately (fastest way to drop)
- `XDP_REDIRECT`: Send packet to another interface
- `XDP_TX`: Bounce packet back out the same interface
- `XDP_ABORTED`: Drop packet due to error

## 📁 Programs

This directory will contain XDP programs demonstrated in Challenge 03.

Example:
- `xdp_drop.c` - Drop packets based on blocked IP addresses
- `Makefile` - Build XDP programs
- `README.md` - Detailed usage instructions

## 🚀 Coming Soon

Complete Challenge 03 to see XDP in action!
