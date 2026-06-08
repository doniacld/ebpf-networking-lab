# eBPF Networking Exam

This directory contains 3 hands-on exercises for the final exam of the eBPF Networking track.

## Files

### Exercises (with TODOs)
- `01-connection-failures.bt` - Track failed TCP connections
- `02-latency-histogram.bt` - Measure connection establishment latency
- `03-health-dashboard.bt` - Combined network health monitoring

### Solutions (complete implementations)
- `solutions/01-connection-failures-solution.bt`
- `solutions/02-latency-histogram-solution.bt`
- `solutions/03-health-dashboard-solution.bt`

## How to Use

1. Open each `.bt` file in the Editor
2. Look for `FILL_THIS_IN` markers
3. Read the TODO comments and hints
4. Complete the missing code
5. Test with `bpftrace filename.bt`
6. Compare with solutions if stuck

## Testing

Each exercise includes test commands in the comments. Generally:

```bash
# Terminal 1: Run the bpftrace script
bpftrace 01-connection-failures.bt

# Terminal 2: Generate test traffic
curl http://localhost:8080/
timeout 1 curl http://192.0.2.1/ 2>/dev/null || true
```

Press Ctrl+C in Terminal 1 to stop and see results.

## What You'll Learn

- **Exercise 1**: kprobe/kretprobe pairing, state tracking, counting failures
- **Exercise 2**: Time measurement, histograms, unit conversion
- **Exercise 3**: Multi-probe scripts, aggregation patterns, formatted output

## Hints

If you get stuck:
1. Review the hints in the file comments
2. Refer back to Challenge 09 (Observability Hooks)
3. Check the solutions directory
4. Remember the patterns:
   - `@map_name = count()` - counting
   - `@map_name = sum(value)` - summing
   - `@map_name = hist(value)` - histograms
   - `@map[tid] = value` - thread-local storage
   - `nsecs` - current time in nanoseconds

Good luck! 🎯
