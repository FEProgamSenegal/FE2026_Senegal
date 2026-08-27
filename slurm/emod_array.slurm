#!/usr/bin/env bash
#SBATCH --job-name=fe2026-emod-array
#SBATCH --array=1-5
#SBATCH --output=logs/emod-%A_%a.out
#SBATCH --error=logs/emod-%A_%a.err
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

set -euo pipefail
cd "${SLURM_SUBMIT_DIR}"
source .venv/bin/activate
python emod/run_tutorial.py --seed "${SLURM_ARRAY_TASK_ID}" --output "results/run-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}"
