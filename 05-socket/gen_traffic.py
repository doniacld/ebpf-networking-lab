#!/usr/bin/env python3
# Generates same-host TCP traffic to exercise the sk_msg redirect path.
# Establishes a localhost connection, waits for sockops to record BOTH sockets,
# then sends a burst of messages that sk_msg redirects socket-to-socket.
import socket, threading, time

def server():
    s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 9099)); s.listen(1)
    conn, _ = s.accept()
    try:
        while conn.recv(65536):
            pass
    except OSError:
        pass

threading.Thread(target=server, daemon=True).start()
time.sleep(0.5)
c = socket.socket(); c.connect(("127.0.0.1", 9099))
time.sleep(0.8)  # let sockops record both sockets before sending
for _ in range(50):
    try:
        c.sendall(b"y" * 4000)
    except OSError:
        break
time.sleep(0.4); c.close()
print("Sent 50 messages over localhost")
