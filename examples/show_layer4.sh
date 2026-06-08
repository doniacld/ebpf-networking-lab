#!/bin/bash
# show_layer4.sh - Display Layer 4 (Transport) information
#
# Layer 4 handles TCP/UDP connections and sockets.
# This script shows active connections, listening sockets, and statistics.

set -e

echo "=========================================="
echo "Layer 4: Transport (TCP/UDP & Sockets)"
echo "=========================================="
echo ""

echo "1. Listening Sockets (Servers)"
echo "-------------------------------"
echo ""
echo "Command: ss -tlnp"
echo "  ss        - Socket statistics utility"
echo "    -t      - Show TCP sockets only"
echo "    -l      - Show listening sockets (servers waiting for connections)"
echo "    -n      - Show numeric addresses (don't resolve hostnames)"
echo "    -p      - Show process using the socket"
echo ""
echo "Expected output:"
echo "  State   Recv-Q Send-Q Local Address:Port  Process"
echo "  LISTEN  0      128    0.0.0.0:22          users:((\"sshd\",pid=123))"
echo "  LISTEN  0      128    *:8080              users:((\"python3\",pid=456))"
echo ""

ss -tlnp

echo ""
echo "What you're seeing:"
echo "  - LISTEN:       Server is waiting for connections"
echo "  - 0.0.0.0:22:   Listening on all interfaces, port 22 (SSH)"
echo "  - *:8080:       Listening on port 8080 (HTTP server)"
echo "  - Process:      Which program owns this socket"
echo ""
echo "=========================================="
echo ""

echo "2. Established Connections"
echo "---------------------------"
echo ""
echo "Command: ss -tnp"
echo "  ss        - Socket statistics utility"
echo "    -t      - Show TCP sockets only"
echo "    -n      - Show numeric addresses"
echo "    -p      - Show process using the socket"
echo "  (no -l, so shows ESTABLISHED connections, not listening)"
echo ""
echo "Expected output:"
echo "  State       Recv-Q Send-Q Local Address:Port  Peer Address:Port   Process"
echo "  ESTAB       0      0      127.0.0.1:45678     127.0.0.1:8080      users:((\"curl\",pid=789))"
echo ""

ss -tnp 2>/dev/null | head -20 || true

echo ""
echo "What you're seeing:"
echo "  - ESTAB:        Connection is established and active"
echo "  - Local Address: This machine's IP:port"
echo "  - Peer Address:  Remote machine's IP:port"
echo "  - Recv-Q/Send-Q: Bytes waiting to be read/sent"
echo ""
echo "=========================================="
echo ""

echo "3. Socket Statistics Summary"
echo "----------------------------"
echo ""
echo "Command: ss -s"
echo "  ss -s  - Show summary statistics for all socket types"
echo ""
echo "Expected output:"
echo "  Total: 45 (kernel 123)"
echo "  TCP:   12 (estab 3, closed 2, orphaned 0)"
echo "  UDP:   8"
echo ""

ss -s

echo ""
echo "What you're seeing:"
echo "  - Total:   Number of sockets"
echo "  - estab:   Established connections"
echo "  - closed:  Connections being closed"
echo "  - orphaned: Connections with no process attached"
echo ""
echo "This shows socket activity at Layer 4 (Transport layer)!"
echo ""
