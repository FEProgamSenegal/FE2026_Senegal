# Validation EMOD avant le cours

Le lanceur livré est volontairement un test d'environnement, pas une simulation fictivement « réussie ».

## Procédure

1. Consultez le tutoriel officiel actuel `emodpy-malaria` Tutorial 1.
2. Choisissez une version Python prise en charge et des versions compatibles.
3. Mettez à jour puis verrouillez `requirements.txt`.
4. Intégrez le code officiel du tutoriel dans `emod/run_tutorial.py`, en conservant `--seed` et `--output`.
5. Vérifiez le téléchargement/extraction du binaire et du schéma EMOD.
6. Exécutez d'abord un petit cas sur un compute node.
7. Vérifiez le code retour, les journaux, `InsetChart.json` et la plausibilité des canaux.
8. Lancez les cinq graines et vérifiez que chaque sortie est isolée.
9. Documentez versions, image AMI, type d'instance, partition, mémoire et temps.

Si les compute nodes n'ont pas accès à Internet, préparez un environnement partagé ou une wheelhouse sur le stockage partagé. Ne donnez pas `sudo` aux étudiants.
