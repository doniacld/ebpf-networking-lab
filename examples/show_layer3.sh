#!/bin/bash
# show_layer3.sh - Display Layer 3 (Network/IP) information
#
# Layer 3 handles IP addressing and routing. This script shows:
# - IP addresses assigned to interfaces
# - Routing table (how packets are forwarded)

set -e

echo "=========================================="
echo "Layer 3: Network (IP Addressing & Routing)"
echo "=========================================="
echo ""

echo "1. IP Addresses"
echo "---------------"
echo ""
echo "Command: ip addr show"
echo "  ip addr show - Display IP addresses for all interfaces"
echo ""
echo "Expected output:"
echo "  1: lo: <LOOPBACK,UP,LOWER_UP>"
echo "     inet 127.0.0.1/8 scope host lo"
echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>"
echo "     inet 192.168.1.100/24 scope global eth0"
echo ""

ip addr show

echo ""
echo "What you're seeing:"
echo "  - inet:        IPv4 address"
echo "  - 127.0.0.1:   Loopback address (always points to this machine)"
echo "  - /8 or /24:   Subnet mask (how many addresses in this network)"
echo "  - scope host:  Only reachable on this machine"
echo "  - scope global: Reachable from outside"
echo ""
echo "=========================================="
echo ""

echo "2. Routing Table"
echo "----------------"
echo ""
echo "Command: ip route show"
echo "  ip route show - Display how packets are routed"
echo ""
echo "Expected output:"
echo "  default via 192.168.1.1 dev eth0"
echo "  192.168.1.0/24 dev eth0 scope link"
echo ""

ip route show

echo ""
echo "What you're seeing:"
echo "  - default via:  Default gateway (where unknown destinations go)"
echo "  - dev eth0:     Which interface to use"
echo "  - scope link:   Directly connected network (no gateway needed)"
echo ""
echo "=========================================="
echo ""

echo "3. Route Lookup Example"
echo "-----------------------"
echo ""
echo "Command: ip route get 8.8.8.8"
echo "  ip route get 8.8.8.8 - Show how a packet to 8.8.8.8 would be routed"
echo ""
echo "Expected output:"
echo "  8.8.8.8 via 192.168.1.1 dev eth0 src 192.168.1.100"
echo ""

ip route get 8.8.8.8

echo ""
echo "What you're seeing:"
echo "  - via:    Packet goes through this gateway"
echo "  - dev:    Using this interface"
echo "  - src:    Using this source IP"
echo ""
echo "This is how the kernel decides where to send packets (Layer 3 routing)!"
echo ""
