#!/usr/bin/env bash
#SBATCH --job-name=fe2026-emod
#SBATCH --output=logs/emod-%j.out
#SBATCH --error=logs/emod-%j.err
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

set -euo pipefail
REPO_DIR="${SLURM_SUBMIT_DIR}"
cd "${REPO_DIR}"
source .venv/bin/activate
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK}"
python emod/run_tutorial.py --seed 1 --output "results/run-${SLURM_JOB_ID}"
