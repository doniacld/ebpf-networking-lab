# Makefile for the eBPF Networking lab programs
#
# Each target compiles one eBPF C program to BPF bytecode (.o).
# Requires: clang, llvm, libbpf headers (and linux-headers for the running kernel).

CLANG ?= clang
ARCH := $(shell uname -m)
CFLAGS := -O2 -g -target bpf -I/usr/include/$(ARCH)-linux-gnu

.PHONY: all xdp tc socket clean

all: xdp tc socket

xdp: xdp/xdp_drop.o
tc: tc/tc_ratelimit.o
socket: socket/sockops_tracker.o

# Pattern rule: build any .o from its matching .c
%.o: %.c
	$(CLANG) $(CFLAGS) -c $< -o $@
	@echo "  ✓ built $@"

clean:
	rm -f xdp/*.o tc/*.o socket/*.o
	@echo "  cleaned build artifacts"
