# Module 4 — HPC et Slurm

## Architecture

- Le head node reçoit les connexions et les soumissions.
- Slurm place les jobs dans une file d'attente appelée partition.
- AWS ParallelCluster peut démarrer des compute nodes dynamiques pour les jobs en attente.
- Le stockage partagé permet au head node et aux compute nodes d'accéder aux mêmes fichiers.

## Premier job

```bash
mkdir -p ~/FE2026_Senegal/logs
cd ~/FE2026_Senegal
sbatch slurm/hello.slurm
squeue -u "$USER"
```

Lorsque le job termine :

```bash
sacct -X --starttime today --format=JobID,JobName,State,Elapsed,AllocCPUS,ExitCode
cat logs/hello-*.out
cat logs/hello-*.err
```

États utiles : `PD` en attente, `R` en cours, `CG` finissante, `COMPLETED` réussie, `FAILED` échouée. Le démarrage d'un nœud dynamique peut prendre quelques minutes.

## Ressources

`--cpus-per-task`, `--mem` et `--time` sont des limites et des demandes au planificateur. Demander trop augmente l'attente et le coût ; demander trop peu provoque une erreur ou un arrêt.

Complétez [l'exercice 4](../exercises/04_slurm_jobs.md).
