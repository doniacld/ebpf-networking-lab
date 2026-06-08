#!/bin/bash
# trace_socket_syscalls.sh - Trace socket system calls
#
# This script uses strace (standard Linux tool, not eBPF) to trace
# the system calls involved in creating a socket connection.
# Later in the lab, we'll see how to do this with eBPF!

set -e

echo "=========================================="
echo "Tracing Socket System Calls"
echo "=========================================="
echo ""
echo "We'll trace the syscalls that curl makes when connecting to a server."
echo "This shows the boundary between userspace (application) and kernel."
echo ""
echo "Command: strace -e trace=socket,connect,sendto,recvfrom curl -s http://localhost:8080/"
echo "  strace                     - Trace system calls"
echo "    -e trace=...             - Only trace these specific syscalls:"
echo "      socket                 - Create a socket endpoint"
echo "      connect                - Connect to a remote address"
echo "      sendto                 - Send data"
echo "      recvfrom               - Receive data"
echo "    curl -s http://...       - The program we're tracing"
echo ""
echo "Expected output:"
echo "  socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 3"
echo "  connect(3, {sa_family=AF_INET, sin_port=htons(8080), ...}) = 0"
echo "  sendto(3, \"GET / HTTP/1.1\\r\\n...\", ...) = 78"
echo "  recvfrom(3, \"HTTP/1.0 200 OK\\r\\n...\", ...) = 145"
echo ""

strace -e trace=socket,connect,sendto,recvfrom curl -s http://localhost:8080/ 2>&1 > /dev/null | grep -E "socket|connect|sendto|recvfrom" | head -20

echo ""
echo "What you're seeing:"
echo "  1. socket()    - Creates a socket (returns file descriptor 3)"
echo "  2. connect()   - Connects to 127.0.0.1:8080 (loopback)"
echo "  3. sendto()    - Sends HTTP GET request"
echo "  4. recvfrom()  - Receives HTTP response"
echo ""
echo "These are the syscalls at the userspace/kernel boundary!"
echo "The kernel handles all the TCP/IP work internally."
echo ""
echo "Note: We're using strace (standard tool) here."
echo "Later, we'll see how eBPF can trace this more efficiently!"
echo ""
