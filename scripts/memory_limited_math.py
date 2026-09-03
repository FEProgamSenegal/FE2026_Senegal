#!/usr/bin/env python3
"""Run a simple calculation until this process reaches a memory limit.

Linux-specific RSS measurement via /proc. The default limit is 3.5 decimal GB.
Request more memory from Slurm than the selected limit (for example, 5G).
"""

import argparse
import ctypes
import os
import socket
import sys
import time
from array import array


def rss_bytes():
    """Return current resident-set size for this process on Linux."""
    with open("/proc/self/statm", "r", encoding="ascii") as statm:
        resident_pages = int(statm.read().split()[1])
    return resident_pages * os.sysconf("SC_PAGE_SIZE")


def current_cpu_id():
    """Return the current Linux logical CPU number, if available."""
    try:
        libc = ctypes.CDLL(None)
        libc.sched_getcpu.restype = ctypes.c_int
        cpu = libc.sched_getcpu()
        return cpu if cpu >= 0 else "unavailable"
    except (AttributeError, OSError):
        return "unavailable"


def print_report(reason, checksum, started_at):
    used = rss_bytes()
    print("\nStopping:", reason, flush=True)
    print("Memory reached: {:.3f} GB ({:.3f} GiB)".format(
        used / 1_000_000_000, used / (1024 ** 3)), flush=True)
    print("Hostname:", socket.gethostname(), flush=True)
    print("Logical CPU ID:", current_cpu_id(), flush=True)
    print("Slurm process ID:", os.environ.get("SLURM_PROCID", "not running under srun"), flush=True)
    print("Checksum:", checksum, flush=True)
    print("Elapsed seconds: {:.2f}".format(time.monotonic() - started_at), flush=True)


def main():
    parser = argparse.ArgumentParser(
        description="Compute sums of squares until process RSS reaches a limit."
    )
    parser.add_argument(
        "--limit-gb", type=float, default=3.5,
        help="RSS limit in decimal GB (default: 3.5)",
    )
    parser.add_argument(
        "--chunk-mb", type=float, default=8.0,
        help="Allocation increment in MiB; smaller is more precise (default: 8)",
    )
    args = parser.parse_args()

    if args.limit_gb <= 0 or args.chunk_mb <= 0:
        parser.error("--limit-gb and --chunk-mb must be positive")

    target = int(args.limit_gb * 1_000_000_000)
    doubles_per_chunk = max(1, int(args.chunk_mb * 1024 ** 2) // 8)
    retained_chunks = []
    checksum = 0.0
    iteration = 0
    started_at = time.monotonic()

    print("Target RSS: {:.3f} GB".format(target / 1_000_000_000), flush=True)
    print("Hostname:", socket.gethostname(), flush=True)

    try:
        while rss_bytes() < target:
            iteration += 1
            value = float((iteration % 1000) + 1)

            # Allocate and touch every page, then retain the chunk so RSS grows.
            values = array("d", [value]) * doubles_per_chunk
            retained_chunks.append(values)

            # Simple math problem: accumulate the sum of squared values.
            checksum += value * value * len(values)

        print_report("RSS limit reached", checksum, started_at)
        return 0
    except MemoryError:
        # This works for Python allocation failures. A cgroup OOM kill cannot be
        # caught, which is why the Slurm allocation must exceed --limit-gb.
        print_report("allocation failed before the requested limit", checksum, started_at)
        return 2
    except KeyboardInterrupt:
        print_report("interrupted by user", checksum, started_at)
        return 130


if __name__ == "__main__":
    sys.exit(main())
