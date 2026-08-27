# Module 5 — AWS ParallelCluster

AWS ParallelCluster est un outil open source pris en charge par AWS pour déployer et gérer des clusters HPC. Dans ce cours, l'enseignant administre l'infrastructure ; l'étudiant utilise Slurm.

## Observer sans modifier

```bash
sinfo -o "%P %a %l %D %t %N"
scontrol show partition
squeue -u "$USER"
```

Une partition Slurm correspond à une file configurée dans ParallelCluster. Les nœuds dynamiques inutilisés sont arrêtés automatiquement selon la configuration. Un nœud représenté avec `~` est généralement défini mais éteint.

## Bonnes pratiques de coût

- Ne jamais utiliser `srun` interactif puis abandonner la session.
- Fixer une durée avec `--time`.
- Annuler un job inutile : `scancel JOB_ID`.
- Vérifier la taille des sorties avec `du -sh`.
- Ne pas créer, modifier ou supprimer le cluster sans rôle administrateur et autorisation.

## Diagnostic en quatre questions

1. Le job a-t-il été accepté (`sbatch` retourne un ID) ?
2. Quel est son état (`squeue`, puis `sacct`) ?
3. Que disent les journaux `.out` et `.err` ?
4. Le chemin et l'environnement existent-ils sur le compute node ?
