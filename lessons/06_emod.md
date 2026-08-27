# Module 6 — EMOD

EMOD est un modèle individuel stochastique. Deux exécutions identiques peuvent différer si la graine aléatoire change ; une expérience sérieuse exécute plusieurs répétitions.

## Fichiers conceptuels

- configuration : durée, type de simulation et paramètres ;
- demographics : population et lieux ;
- campaign : interventions et calendrier ;
- reports : sorties demandées ;
- résultats : séries temporelles et journaux.

## Installation isolée sur le head node

Le cluster doit fournir une version Python compatible avec les versions épinglées. N'utilisez pas `sudo`.

```bash
cd ~/FE2026_Senegal
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -c "import emodpy_malaria, idmtools; print('Imports EMOD: OK')"
```

Si l'installation échoue, conservez le message complet et exécutez :

```bash
python --version
python -m pip --version
python -m pip check
```

## Pourquoi épingler les versions ?

Un fichier de versions rend la classe plus reproductible. L'enseignant doit néanmoins retester ces versions sur l'image ParallelCluster avant chaque session, car EMOD n'est plus activement maintenu.

Complétez [l'exercice 5](../exercises/05_emod_environment.md).
