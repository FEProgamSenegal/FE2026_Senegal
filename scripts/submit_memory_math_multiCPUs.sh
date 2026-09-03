#!/bin/bash
#SBATCH --job-name=memory_math
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:10:00
#SBATCH --output=memory_math_%j.out
#SBATCH --error=memory_math_%j.err

set -euo pipefail

echo "Job ID: ${SLURM_JOB_ID:-none}"
echo "Node: $(hostname)"
echo "Allocated CPUs: ${SLURM_CPUS_PER_TASK:-1}"

# The Python program is embedded, so no separate .py file is required.
srun --ntasks=1 --cpus-per-task="${SLURM_CPUS_PER_TASK:-4}" --cpu-bind=cores \
python - <<'PYTHON'
import ctypes
import multiprocessing as mp
import os
import queue
import socket
import time
from array import array

LIMIT_GB = 3.5                 # Aggregate parent + worker RSS, decimal GB
CHUNK_MIB = 4                  # Allocation increment per worker
POLL_SECONDS = 0.01
WORKERS = int(os.environ.get("SLURM_CPUS_PER_TASK", "4"))


def rss_bytes():
    with open("/proc/self/statm", "r") as statm:
        pages = int(statm.read().split()[1])
    return pages * os.sysconf("SC_PAGE_SIZE")


def cpu_id():
    try:
        libc = ctypes.CDLL(None)
        libc.sched_getcpu.restype = ctypes.c_int
        value = libc.sched_getcpu()
        return value if value >= 0 else "unavailable"
    except (AttributeError, OSError):
        return "unavailable"


def worker(worker_number, stop_event, results, worker_rss, chunk_bytes):
    retained = []
    doubles_per_chunk = max(1, chunk_bytes // 8)
    checksum = 0.0
    iterations = 0
    reason = "memory limit reached"

    try:
        while not stop_event.is_set():
            iterations += 1
            value = float(((iterations + worker_number) % 1000) + 1)
            numbers = array("d", [value]) * doubles_per_chunk
            retained.append(numbers)       # Retain and touch allocated memory
            checksum += value * value * len(numbers)  # Sum-of-squares work
            worker_rss[worker_number] = rss_bytes()
    except MemoryError:
        reason = "MemoryError"
        stop_event.set()
    finally:
        results.put((worker_number, os.getpid(), cpu_id(), iterations,
                     checksum, reason))


def main():
    target_bytes = int(LIMIT_GB * 1_000_000_000)
    chunk_bytes = int(CHUNK_MIB * 1024 ** 2)
    stop_event = mp.Event()
    results_queue = mp.Queue()
    worker_rss = mp.Array("Q", WORKERS, lock=False)
    processes = []
    peak_rss = 0
    started = time.monotonic()
    stop_reason = "aggregate RSS limit reached"

    print("Target: {:.3f} GB aggregate RSS".format(LIMIT_GB), flush=True)
    print("Workers: {}".format(WORKERS), flush=True)

    for number in range(WORKERS):
        process = mp.Process(
            target=worker,
            args=(number, stop_event, results_queue, worker_rss, chunk_bytes),
        )
        process.start()
        processes.append(process)

    try:
        while any(process.is_alive() for process in processes):
            aggregate = rss_bytes() + sum(worker_rss)
            peak_rss = max(peak_rss, aggregate)
            if aggregate >= target_bytes:
                stop_event.set()
                break
            if stop_event.is_set():
                stop_reason = "worker failed before requested limit"
                break
            time.sleep(POLL_SECONDS)
    except KeyboardInterrupt:
        stop_reason = "interrupted"
        stop_event.set()

    for process in processes:
        process.join(timeout=30)
        if process.is_alive():
            process.terminate()
            process.join()

    reports = []
    while len(reports) < WORKERS:
        try:
            reports.append(results_queue.get_nowait())
        except queue.Empty:
            break

    print("\nStopping: {}".format(stop_reason))
    print("Peak memory: {:.3f} GB ({:.3f} GiB)".format(
        peak_rss / 1_000_000_000, peak_rss / 1024 ** 3))
    print("Hostname: {}".format(socket.gethostname()))
    print("Slurm job ID: {}".format(os.environ.get("SLURM_JOB_ID", "none")))
    print("Parent PID: {} | CPU: {}".format(os.getpid(), cpu_id()))

    for number, pid, cpu, iterations, checksum, reason in sorted(reports):
        print("Worker {}: PID={}, CPU={}, iterations={}, checksum={:.1f}, {}"
              .format(number, pid, cpu, iterations, checksum, reason))

    print("Combined checksum: {:.1f}".format(sum(item[4] for item in reports)))
    print("Elapsed seconds: {:.2f}".format(time.monotonic() - started))


if __name__ == "__main__":
    main()
PYTHON
