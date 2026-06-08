#!/bin/bash
# capture_packet.sh - Capture and display packet structure with headers
#
# This script demonstrates what a network packet looks like by capturing
# a real HTTP request and showing all its headers (Ethernet, IP, TCP, HTTP).

set -e

echo "=========================================="
echo "Capturing a Packet to See Its Structure"
echo "=========================================="
echo ""
echo "We'll capture 1 packet from an HTTP request to see how headers are nested:"
echo "  Ethernet header → IP header → TCP header → HTTP data"
echo ""
echo "Command breakdown:"
echo "  tcpdump              - Packet capture tool"
echo "    -i lo              - Capture on loopback interface (local traffic)"
echo "    -c 1               - Capture only 1 packet"
echo "    -XX                - Show packet contents in hex AND ASCII"
echo "    'tcp port 8080'    - Filter: only TCP traffic on port 8080"
echo ""
echo "Starting capture in background, then generating traffic..."
echo ""

# Start tcpdump in background
tcpdump -i lo -c 1 -XX 'tcp port 8080' 2>/dev/null &
TCPDUMP_PID=$!

# Give tcpdump time to start
sleep 1

# Generate HTTP traffic
curl -s http://localhost:8080/ > /dev/null 2>&1

# Wait for tcpdump to finish
wait $TCPDUMP_PID 2>/dev/null

echo ""
echo "=========================================="
echo "What You're Seeing:"
echo "=========================================="
echo ""
echo "The output above shows:"
echo "  1. Packet timestamp and basic info (IP addresses, ports)"
echo "  2. Hex dump on the left (raw bytes)"
echo "  3. ASCII representation on the right (readable text)"
echo ""
echo "Key parts to notice:"
echo "  - IP header:  Source/destination IPs (127.0.0.1 → 127.0.0.1)"
echo "  - TCP header: Source/destination ports, sequence numbers"
echo "  - HTTP data:  'GET / HTTP/1.1' in the ASCII column"
echo ""
echo "Each layer added its own header to the original HTTP request!"
echo ""
