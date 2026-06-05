#!/bin/bash
# Collection of useful bpftrace one-liners for network observability
# These are referenced throughout the track challenges

echo "=== eBPF Network Observability - bpftrace Examples ==="
echo ""
echo "Choose an example to run:"
echo ""
echo "1. Track all TCP connections"
echo "2. Measure TCP connection latency"
echo "3. Track packet reception"
echo "4. Monitor TCP retransmissions"
echo "5. Find where packets are dropped"
echo "6. Track bytes sent per process"
echo "7. TCP state changes"
echo "8. Full connection lifecycle"
echo "9. DNS resolution timing"
echo "10. Exit"
echo ""
read -p "Enter choice (1-10): " choice

case $choice in
    1)
        echo "Tracking all TCP connections (Ctrl+C to stop)..."
        bpftrace -e '
kprobe:tcp_connect {
    $sk = (struct sock *)arg0;
    $inet = (struct inet_sock *)$sk;
    printf("PID %d (%s) connecting to %d.%d.%d.%d:%d\n",
        pid, comm,
        $inet->inet_daddr & 0xFF,
        ($inet->inet_daddr >> 8) & 0xFF,
        ($inet->inet_daddr >> 16) & 0xFF,
        ($inet->inet_daddr >> 24) & 0xFF,
        $inet->inet_dport);
}'
        ;;
    2)
        echo "Measuring TCP connection latency (Ctrl+C to stop)..."
        bpftrace -e '
kprobe:tcp_connect { @start[tid] = nsecs; }
kretprobe:tcp_connect /@start[tid]/ {
    printf("Connect latency: %d µs\n", (nsecs - @start[tid]) / 1000);
    delete(@start[tid]);
}'
        ;;
    3)
        echo "Tracking packet reception (Ctrl+C to stop)..."
        bpftrace -e '
tracepoint:net:netif_receive_skb {
    printf("RX: Packet received on interface\n");
}'
        ;;
    4)
        echo "Monitoring TCP retransmissions (Ctrl+C to stop)..."
        bpftrace -e '
kprobe:tcp_retransmit_skb {
    printf("[%s] TCP retransmission detected (PID %d)\n", strftime("%H:%M:%S", nsecs), pid);
    @retrans++;
}
interval:s:5 {
    printf("Retransmissions last 5s: %d\n", @retrans);
    clear(@retrans);
}'
        ;;
    5)
        echo "Finding where packets are dropped (Ctrl+C to stop)..."
        bpftrace -e '
tracepoint:skb:kfree_skb {
    printf("Packet dropped at:\n%s\n", kstack);
    @drops++;
}
interval:s:10 {
    printf("Total drops: %d\n", @drops);
}'
        ;;
    6)
        echo "Tracking bytes sent per process (Ctrl+C to stop)..."
        bpftrace -e '
kprobe:tcp_sendmsg {
    @bytes_sent[comm] = sum(arg2);
}
interval:s:5 {
    print(@bytes_sent);
    clear(@bytes_sent);
}'
        ;;
    7)
        echo "Tracking TCP state changes (Ctrl+C to stop)..."
        bpftrace -e '
tracepoint:sock:inet_sock_set_state {
    printf("TCP state: %d -> %d (PID %d)\n",
        args->oldstate, args->newstate, pid);
}'
        ;;
    8)
        echo "Full connection lifecycle tracking (Ctrl+C to stop)..."
        bpftrace -e '
kprobe:tcp_connect {
    printf("[CONNECT] PID %d starting connection\n", pid);
    @connects++;
}
kprobe:tcp_sendmsg {
    @sends[comm]++;
}
kprobe:tcp_recvmsg {
    @recvs[comm]++;
}
kprobe:tcp_retransmit_skb {
    printf("[RETRANS] Retransmission in PID %d\n", pid);
    @retrans++;
}
interval:s:10 {
    printf("\n=== Connection Stats (10s) ===\n");
    printf("Connects: %d\n", @connects);
    printf("Retransmissions: %d\n", @retrans);
    printf("\nSends per process:\n");
    print(@sends);
    printf("\nReceives per process:\n");
    print(@recvs);
    clear(@connects); clear(@retrans); clear(@sends); clear(@recvs);
}'
        ;;
    9)
        echo "DNS resolution timing (Ctrl+C to stop)..."
        bpftrace -e '
uprobe:/lib/x86_64-linux-gnu/libc.so.6:getaddrinfo {
    @start[tid] = nsecs;
}
uretprobe:/lib/x86_64-linux-gnu/libc.so.6:getaddrinfo /@start[tid]/ {
    printf("DNS lookup: %d ms\n", (nsecs - @start[tid]) / 1000000);
    delete(@start[tid]);
}'
        ;;
    10)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
