# Exercice 5 — Environnement EMOD

Créez `.venv`, installez les dépendances et sauvegardez :

```bash
python --version > environment_report.txt
python -m pip freeze >> environment_report.txt
python -m pip check >> environment_report.txt
```

Ajoutez une ligne expliquant pourquoi `.venv/` ne doit pas être commité. Ne commitez que `environment_report.txt`.
