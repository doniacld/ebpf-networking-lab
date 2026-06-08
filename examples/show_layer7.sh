#!/bin/bash
# show_layer7.sh - Display Layer 7 (Application) traffic
#
# Layer 7 is the application layer (HTTP, DNS, SSH, etc.).
# This happens in USERSPACE, not the kernel!
# The kernel just sees this as payload bytes in TCP packets.

set -e

echo "=========================================="
echo "Layer 7: Application (HTTP Traffic)"
echo "=========================================="
echo ""
echo "Layer 7 protocols (HTTP, DNS, SSH) are processed in userspace applications."
echo "The kernel only sees them as TCP/UDP payload bytes."
echo ""
echo "We'll capture HTTP traffic to show the difference between:"
echo "  - What the kernel sees (TCP payload bytes)"
echo "  - What the application sees (HTTP headers and content)"
echo ""
echo "Command: tcpdump -i lo -A 'tcp port 8080' (1 packet)"
echo "  tcpdump             - Packet capture tool"
echo "    -i lo             - Capture on loopback interface"
echo "    -A                - Show packet payload in ASCII (not hex)"
echo "    'tcp port 8080'   - Filter for HTTP traffic on port 8080"
echo ""
echo "Expected output:"
echo "  GET / HTTP/1.1"
echo "  Host: localhost:8080"
echo "  User-Agent: curl/7.81.0"
echo ""
echo "Starting capture..."
echo ""

# Start tcpdump in background
timeout 3 tcpdump -i lo -A 'tcp port 8080' 2>/dev/null &
TCPDUMP_PID=$!

# Give tcpdump time to start
sleep 1

# Generate HTTP traffic
curl -s http://localhost:8080/ > /dev/null 2>&1

# Wait for tcpdump (or timeout)
wait $TCPDUMP_PID 2>/dev/null || true

echo ""
echo "=========================================="
echo "What You're Seeing:"
echo "=========================================="
echo ""
echo "The ASCII output shows HTTP headers (Layer 7):"
echo "  - GET / HTTP/1.1     - HTTP method and version"
echo "  - Host: localhost    - HTTP header"
echo "  - User-Agent: curl   - HTTP header"
echo ""
echo "Key insight:"
echo "  - The KERNEL doesn't parse these HTTP headers"
echo "  - It just delivers the bytes to the application (web server)"
echo "  - The APPLICATION (in userspace) parses HTTP"
echo ""
echo "Layer 7 = Userspace only!"
echo ""
