# Examples Directory

This directory previously contained shell scripts that wrapped networking commands with explanations. Those scripts have been removed because:

1. **Commands are now inline** in the Instruqt assignment files
2. **Explanations are in the assignment** - no need to duplicate
3. **Direct commands are clearer** - users see exactly what runs

## What Was Removed

All example scripts (`.sh` files) have been moved directly into Challenge 01 and Challenge 03 assignments as inline commands with explanations:

- `capture_packet.sh` → Direct `tcpdump` command (Challenge 01)
- `show_layer2.sh` → Direct `ip link` commands (Challenge 03)
- `show_layer3.sh` → Direct `ip addr/route` commands (Challenge 03)
- `show_layer4.sh` → Direct `ss` commands (Challenge 03)
- `trace_socket_syscalls.sh` → Direct `strace` command (Challenge 03)
- `show_layer7.sh` → Direct `tcpdump` command (Challenge 03)

## Why This Is Better

**Before** (with scripts):
```markdown
```shell,run
/root/ebpf-networking-lab/examples/show_layer2.sh
```
```

Users didn't see what command actually ran.

**After** (direct commands):
```markdown
```shell,run
ip link show
```

Command breakdown:
- `ip` - Network configuration utility
- `link` - Layer 2 (link layer)
- `show` - Display interfaces
```

Users see the actual command, understand each flag, and can adapt it to their needs.

## What Remains in This Repository

- **eBPF C programs**: `xdp/`, `tc/`, `socket/` directories contain actual eBPF programs (not wrapper scripts)
- **bpftrace examples**: `bpftrace/` directory contains bpftrace scripts for observability
- **Makefile**: For compiling eBPF programs

This directory (`examples/`) may be removed entirely in the future.
