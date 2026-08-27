#!/usr/bin/env bash
#SBATCH --job-name=fe2026-hello
#SBATCH --output=logs/hello-%j.out
#SBATCH --error=logs/hello-%j.err
#SBATCH --time=00:02:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M

set -euo pipefail
echo "Bonjour FE2026 Sénégal"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Hôte: $(hostname)"
echo "Date UTC: $(date -u)"
echo "CPU demandés: ${SLURM_CPUS_PER_TASK}"
