# Module 3 — Travailler avec Git

## Une modification traçable

```bash
git pull --ff-only
git switch -c etudiant/VOTRE_IDENTIFIANT
# modifier answers/VOTRE_IDENTIFIANT.md
git status
git diff
git add answers/VOTRE_IDENTIFIANT.md
git commit -m "Ajoute les réponses du module 1"
git push -u origin etudiant/VOTRE_IDENTIFIANT
```

Créez ensuite une pull request sur GitHub. Une pull request propose d'intégrer une branche ; elle n'est pas elle-même un commit.

## En cas de problème

`git status` est toujours le premier diagnostic. Ne forcez jamais un push pour « résoudre » un conflit de classe. Demandez une revue et conservez le travail des autres.

## Bon message de commit

Utilisez un verbe précis et une seule intention : `Ajoute le rapport du job Slurm`. Évitez `update`, `test` ou `final final 2`.

Complétez [l'exercice 3](../exercises/03_git_branch_pr.md).
