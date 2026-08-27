# Plan enseignant

## Format en six séances

1. GitHub, open source et sécurité — modules 0–1.
2. Linux, SSH et transfert — module 2.
3. Git, branches et revue — module 3.
4. HPC, Slurm et ParallelCluster — modules 4–5.
5. EMOD et environnement — module 6.
6. EMOD sur Slurm et lancement du projet — modules 7–8.

Prévoir environ 45 % de démonstration guidée, 45 % de pratique et 10 % de retour collectif. Former des binômes sans partager les identifiants.

## Préparation obligatoire

- Valider l'image OS et Python du cluster.
- Créer des utilisateurs distincts ou une méthode d'accès institutionnelle.
- Restreindre IAM selon le moindre privilège.
- Tester DNS, SSH, stockage partagé, Internet sortant ou miroir de paquets.
- Tester chaque script sur un compute node.
- Définir partition, quota, durée maximale et procédure d'arrêt.
- Précharger les paquets si l'accès Internet des compute nodes est bloqué.
- Ne jamais distribuer une même clé privée à toute la classe.

## Évaluation

Exercices 1–5 : 40 %. Projet final : 50 %. Participation/revue : 10 %.

## Points d'arrêt pédagogique

Ne passez à Slurm que lorsque tous savent distinguer ordinateur local et cluster. Ne passez à EMOD que lorsque tous peuvent retrouver les journaux d'un job. Ne présentez les résultats qu'après validation du vrai moteur, pas du simple test d'import.
