#!/usr/bin/env python3
"""Use multiple CPUs for math until aggregate process memory reaches a limit.

The parent monitors its RSS plus every worker's RSS. The default limit is
3.5 decimal GB across the whole program, not 3.5 GB per worker.
Linux is required because current RSS is read from /proc.
"""

import argparse
import ctypes
import multiprocessing as mp
import os
import queue
import socket
import sys
import time
from array import array


def rss_bytes():
    """Return the current RSS of this Linux process."""
    try:
        with open("/proc/self/statm", "r") as statm:
            resident_pages = int(statm.read().split()[1])
        return resident_pages * os.sysconf("SC_PAGE_SIZE")
    except (FileNotFoundError, ProcessLookupError):
        return 0


def current_cpu_id():
    """Return the current Linux logical CPU number, if available."""
    try:
        libc = ctypes.CDLL(None)
        libc.sched_getcpu.restype = ctypes.c_int
        cpu = libc.sched_getcpu()
        return cpu if cpu >= 0 else "unavailable"
    except (AttributeError, OSError):
        return "unavailable"


def worker(worker_id, stop_event, result_queue, rss_values, chunk_bytes):
    """Allocate touched memory and calculate sums of squares until stopped."""
    retained_chunks = []
    doubles_per_chunk = max(1, chunk_bytes // 8)
    checksum = 0.0
    iterations = 0
    reason = "stop requested"

    try:
        while not stop_event.is_set():
            iterations += 1
            value = float(((iterations + worker_id) % 1000) + 1)
            values = array("d", [value]) * doubles_per_chunk
            retained_chunks.append(values)  # Keep memory resident.
            checksum += value * value * len(values)
            rss_values[worker_id] = rss_bytes()
    except MemoryError:
        reason = "MemoryError"
        stop_event.set()
    finally:
        result_queue.put({
            "worker": worker_id,
            "pid": os.getpid(),
            "cpu": current_cpu_id(),
            "iterations": iterations,
            "checksum": checksum,
            "reason": reason,
        })


def print_summary(reason, peak_rss, results, started_at):
    print("\nStopping: {}".format(reason))
    print("Peak aggregate memory: {:.3f} GB ({:.3f} GiB)".format(
        peak_rss / 1_000_000_000, peak_rss / (1024 ** 3)))
    print("Hostname: {}".format(socket.gethostname()))
    print("Slurm job ID: {}".format(os.environ.get("SLURM_JOB_ID", "not under Slurm")))
    print("Slurm process ID: {}".format(os.environ.get("SLURM_PROCID", "not under srun")))
    print("Parent PID: {} | logical CPU ID: {}".format(os.getpid(), current_cpu_id()))

    for result in sorted(results, key=lambda item: item["worker"]):
        print(
            "Worker {worker}: PID={pid}, CPU={cpu}, iterations={iterations}, "
            "checksum={checksum:.1f}, reason={reason}".format(**result)
        )

    total_checksum = sum(item["checksum"] for item in results)
    print("Combined checksum: {:.1f}".format(total_checksum))
    print("Elapsed seconds: {:.2f}".format(time.monotonic() - started_at))


def main():
    parser = argparse.ArgumentParser(
        description="Run multi-CPU sums of squares to an aggregate RSS limit."
    )
    parser.add_argument(
        "--cpus", type=int,
        default=int(os.environ.get("SLURM_CPUS_PER_TASK", "4")),
        help="number of worker processes (default: SLURM_CPUS_PER_TASK or 4)",
    )
    parser.add_argument(
        "--limit-gb", type=float, default=3.5,
        help="aggregate RSS limit in decimal GB (default: 3.5)",
    )
    parser.add_argument(
        "--chunk-mb", type=float, default=4.0,
        help="allocation per worker iteration in MiB (default: 4)",
    )
    parser.add_argument(
        "--poll-ms", type=float, default=10.0,
        help="parent memory-check interval in milliseconds (default: 10)",
    )
    args = parser.parse_args()

    if args.cpus < 1:
        parser.error("--cpus must be at least 1")
    if args.limit_gb <= 0 or args.chunk_mb <= 0 or args.poll_ms <= 0:
        parser.error("memory limit, chunk size, and polling interval must be positive")

    target = int(args.limit_gb * 1_000_000_000)
    chunk_bytes = max(8, int(args.chunk_mb * 1024 ** 2))
    stop_event = mp.Event()
    result_queue = mp.Queue()
    workers = []
    # Workers publish their own RSS. This also works inside PID namespaces,
    # where a parent may not be able to address /proc/<child-pid> reliably.
    rss_values = mp.Array("Q", args.cpus, lock=False)
    started_at = time.monotonic()

    print("Aggregate RSS target: {:.3f} GB".format(target / 1_000_000_000), flush=True)
    print("Workers: {} | hostname: {}".format(args.cpus, socket.gethostname()), flush=True)

    for worker_id in range(args.cpus):
        process = mp.Process(
            target=worker,
            args=(worker_id, stop_event, result_queue, rss_values, chunk_bytes),
            name="math-worker-{}".format(worker_id),
        )
        process.start()
        workers.append(process)

    peak_rss = 0
    reason = "aggregate RSS limit reached"

    try:
        while any(process.is_alive() for process in workers):
            aggregate_rss = rss_bytes() + sum(rss_values)
            peak_rss = max(peak_rss, aggregate_rss)

            if aggregate_rss >= target:
                stop_event.set()
                break
            if stop_event.is_set():
                reason = "worker allocation failed before requested limit"
                break
            time.sleep(args.poll_ms / 1000.0)
    except KeyboardInterrupt:
        reason = "interrupted by user"
        stop_event.set()

    for process in workers:
        process.join(timeout=30)
    for process in workers:
        if process.is_alive():
            process.terminate()
            process.join()

    # Capture any final growth before workers disappear from /proc.
    peak_rss = max(peak_rss, rss_bytes())
    results = []
    while len(results) < len(workers):
        try:
            results.append(result_queue.get_nowait())
        except queue.Empty:
            break

    print_summary(reason, peak_rss, results, started_at)
    return 0 if reason == "aggregate RSS limit reached" else 2


if __name__ == "__main__":
    mp.freeze_support()
    sys.exit(main())
