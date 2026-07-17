# Makefile for the eBPF Networking lab programs
#
# Each target compiles one eBPF C program to BPF bytecode (.o).
# Requires: clang, llvm, libbpf headers (and linux-headers for the running kernel).

CLANG ?= clang
ARCH := $(shell uname -m)
CFLAGS := -O2 -g -target bpf -I/usr/include/$(ARCH)-linux-gnu

.PHONY: all xdp tc socket clean

all: xdp tc socket

xdp: 05-xdp/xdp_drop.o
tc: 06-tc/tc_ratelimit.o
socket: 08-socket/sockops_tracker.o 08-socket/sk_msg_redirect.o

# Pattern rule: build any .o from its matching .c
%.o: %.c
	$(CLANG) $(CFLAGS) -c $< -o $@
	@echo "  ✓ built $@"

clean:
	rm -f 05-xdp/*.o 06-tc/*.o 08-socket/*.o
	@echo "  cleaned build artifacts"
