# FE2026 Sénégal — GitHub, AWS HPC et EMOD

Cours pratique pour débutants : trouver un logiciel libre sur GitHub, travailler avec Git, se connecter à un cluster AWS ParallelCluster, soumettre des tâches Slurm et exécuter une simulation EMOD de paludisme.

## Résultats d'apprentissage

À la fin du cours, l'étudiant pourra :

1. expliquer Git, GitHub, dépôt, commit, branche, clone, pull et push ;
2. cloner et examiner un projet open source sans exécuter aveuglément son code ;
3. se connecter au nœud principal d'un AWS ParallelCluster ;
4. naviguer dans Linux et transférer des fichiers ;
5. demander des ressources et lancer un job avec Slurm ;
6. installer EMOD dans un environnement Python isolé ;
7. lancer, surveiller et documenter une simulation de paludisme ;
8. récupérer les résultats et publier un compte rendu reproductible.

## Parcours recommandé

| Module | Sujet | Durée | Production |
|---|---|---:|---|
| 0 | Préparation | 60 min avant cours | Comptes et accès validés |
| 1 | GitHub et logiciel libre | 90 min | Dépôt cloné et licence identifiée |
| 2 | Linux et SSH | 120 min | Connexion et fichiers manipulés |
| 3 | Git au quotidien | 120 min | Branche, commit et pull request |
| 4 | Comprendre le HPC | 90 min | Premier job Slurm |
| 5 | AWS ParallelCluster | 120 min | Job soumis et surveillé |
| 6 | EMOD et paludisme | 120 min | Environnement EMOD validé |
| 7 | EMOD sur le HPC | 180 min | Simulation et résultats |
| 8 | Projet final | 180–300 min | Expérience reproductible |

Durée totale guidée : environ 16 à 18 heures. Le cours peut être livré en 6 séances de 3 heures. Voir [le plan enseignant](instructor/COURSE_PLAN.md).

## Démarrage étudiant

```bash
git clone https://github.com/FEProgamSenegal/FE2026_Senegal.git
cd FE2026_Senegal
bash scripts/student_check.sh
```

Commencez par [la préparation](lessons/00_preparation.md), puis suivez les leçons dans l'ordre.

## Structure

- `lessons/` : contenu guidé ;
- `exercises/` : travaux à remettre ;
- `solutions/` : corrigés réservés à l'enseignant ;
- `slurm/` : scripts de soumission ;
- `emod/` : fichiers du projet de simulation ;
- `cluster/` : exemple de configuration administrateur ;
- `instructor/` : plan, évaluation et préparation ;
- `resources/` : glossaire et aide-mémoire.

## Règles importantes

- Ne publiez jamais de clé privée, mot de passe ou clé AWS dans GitHub.
- Ne lancez pas de calcul lourd sur le nœud principal.
- Utilisez `sbatch` pour les simulations et demandez seulement les ressources nécessaires.
- Arrêtez/supprimez les ressources AWS après le cours selon les instructions de l'administrateur.

## À propos d'EMOD

EMOD est un modèle épidémiologique individuel et stochastique. Le projet recommande aux chercheurs les paquets Python propres aux maladies, notamment `emodpy-malaria`, plutôt que la compilation directe du moteur C++. Les dépôts sont ouverts sous licence MIT, mais indiquent qu'ils ne sont plus activement maintenus. Ce cours épingle donc les dépendances et sépare une validation légère d'une simulation plus coûteuse.

## Références officielles

- [AWS ParallelCluster](https://docs.aws.amazon.com/parallelcluster/latest/ug/what-is-aws-parallelcluster.html)
- [Premier job AWS ParallelCluster](https://docs.aws.amazon.com/parallelcluster/latest/ug/tutorials-running-your-first-job-on-version-3.html)
- [EMOD](https://github.com/EMOD-Hub/EMOD)
- [emodpy-malaria](https://github.com/EMOD-Hub/emodpy-malaria)
- [idmtools et Slurm](https://docs.idmod.org/projects/idmtools/en/latest/platforms/slurm/)

## Licence du matériel pédagogique

Voir [LICENSE](LICENSE). EMOD et les autres logiciels conservent leurs propres licences.
