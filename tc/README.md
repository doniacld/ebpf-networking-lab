# TC (Traffic Control)

TC (Traffic Control) eBPF programs run at the **qdisc layer** - after routing decisions, with full packet and device context.

## 🎯 Use Cases

- **Rate Limiting**: Control bandwidth per flow
- **Traffic Shaping**: QoS policies
- **Network Policies**: Allow/deny based on IP, port, protocol
- **Packet Modification**: Rewrite headers, NAT

## 🔧 How TC Works

TC programs attach to network interfaces at two points:
- **Ingress**: Packets entering the interface (from the wire)
- **Egress**: Packets leaving the interface (to the wire)

Programs return:
- `TC_ACT_OK`: Pass packet
- `TC_ACT_SHOT`: Drop packet
- `TC_ACT_REDIRECT`: Redirect to another interface
- `TC_ACT_STOLEN`: Take ownership of packet (don't free)

## 📁 Programs

This directory will contain TC programs demonstrated in Challenge 04.

Example:
- `tc_ratelimit.c` - Token bucket rate limiter
- `Makefile` - Build TC programs
- `README.md` - Detailed usage instructions

## 🚀 Coming Soon

Complete Challenge 04 to see TC in action!
