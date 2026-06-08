#!/bin/bash
# show_layer2.sh - Display Layer 2 (Data Link) information
#
# Layer 2 handles the physical network interface (NIC) and Ethernet frames.
# This includes MAC addresses, link state, and packet statistics.

set -e

echo "=========================================="
echo "Layer 2: Data Link (Network Interfaces)"
echo "=========================================="
echo ""

echo "1. Listing Network Interfaces"
echo "------------------------------"
echo ""
echo "Command: ip link show"
echo "  ip link show - Display all network interfaces"
echo ""
echo "Expected output:"
echo "  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536"
echo "     link/loopback 00:00:00:00:00:00"
echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500"
echo "     link/ether aa:bb:cc:dd:ee:ff"
echo ""

ip link show

echo ""
echo "What you're seeing:"
echo "  - lo:        Loopback interface (for local communication)"
echo "  - eth0:      Physical/virtual network interface"
echo "  - UP:        Interface is active"
echo "  - mtu:       Maximum Transmission Unit (max packet size)"
echo "  - link/ether: MAC address (Layer 2 address)"
echo ""
echo "=========================================="
echo ""

echo "2. Interface Statistics"
echo "-----------------------"
echo ""
echo "Command: ip -s link show lo"
echo "  ip -s link show lo - Show statistics for loopback interface"
echo "    -s               - Include statistics (packets, bytes, errors)"
echo ""
echo "Expected output:"
echo "    RX: bytes  packets  errors  dropped"
echo "    TX: bytes  packets  errors  dropped"
echo ""

ip -s link show lo

echo ""
echo "What you're seeing:"
echo "  - RX (Receive): Incoming packets/bytes"
echo "  - TX (Transmit): Outgoing packets/bytes"
echo "  - errors:  Malformed packets"
echo "  - dropped: Packets dropped (no buffer space, etc.)"
echo ""
echo "These counters show network activity at Layer 2!"
echo ""
