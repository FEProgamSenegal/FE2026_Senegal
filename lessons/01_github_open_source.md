# Module 1 — GitHub et logiciel libre

## Les idées essentielles

- Git conserve l'historique d'un projet sur une machine.
- GitHub héberge et facilite la collaboration autour de dépôts Git.
- `clone` crée une copie locale ; `pull` reçoit les changements ; `push` publie vos commits.
- Une licence indique les droits de réutilisation. « Visible publiquement » ne signifie pas automatiquement « libre de droits ».

## Examiner avant d'installer

Sur un dépôt open source, cherchez : `README`, `LICENSE`, versions publiées, documentation, problèmes ouverts, date des derniers changements et instructions de sécurité. Ne copiez pas une commande d'installation sans la comprendre.

## Pratique

```bash
git clone https://github.com/EMOD-Hub/EMOD.git
cd EMOD
git remote -v
git log -5 --oneline
git status
git tag --list | tail
```

Ouvrez `README.md` et `LICENSE`. Le dépôt source EMOD précise que la majorité des utilisateurs doivent employer les paquets Python propres aux maladies. Nous utiliserons donc `emodpy-malaria`.

Complétez [l'exercice 1](../exercises/01_open_source_audit.md).
