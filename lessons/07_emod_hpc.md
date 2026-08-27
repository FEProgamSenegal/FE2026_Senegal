# Module 7 — EMOD sur le HPC

## Validation en deux étapes

1. L'installation et les imports sont validés sur le head node.
2. La simulation est exécutée avec `sbatch` sur un compute node.

```bash
cd ~/FE2026_Senegal
mkdir -p logs results
sbatch slurm/emod_malaria.slurm
squeue -u "$USER"
```

Après la fin :

```bash
sacct -X --starttime today --format=JobID,JobName,State,Elapsed,MaxRSS,ExitCode
tail -n 50 logs/emod-*.out
tail -n 50 logs/emod-*.err
find results -maxdepth 3 -type f | sort
```

Le script fourni est un cadre pédagogique. L'enseignant doit d'abord valider le tutoriel officiel `emodpy-malaria` et adapter le fichier `emod/run_tutorial.py` aux versions retenues. Ne présentez pas une absence d'erreur d'import comme une validation scientifique du modèle.

## Répétitions

Pour une simulation stochastique, lancez un tableau Slurm avec plusieurs graines :

```bash
sbatch slurm/emod_array.slurm
```

Chaque tâche reçoit `SLURM_ARRAY_TASK_ID`, utilisé comme graine. Comparez ensuite les résultats entre répétitions.

Complétez [le projet final](../exercises/06_final_project.md).
