# Publier le cours sur GitHub

Créez un dépôt vide nommé `FE2026_Senegal` dans votre compte ou organisation. Ne demandez pas à GitHub d'ajouter un README ou une licence, puisqu'ils existent déjà.

Depuis le dossier du cours :

```bash
git init
git add .
git commit -m "Crée le cours FE2026 Sénégal"
git branch -M main
git remote add origin https://github.com/VOTRE_ORGANISATION/FE2026_Senegal.git
git push -u origin main
```

## Réglages conseillés

- Activez les Issues et Discussions.
- Protégez `main` et exigez une pull request.
- Interdisez les force-pushes et les suppressions de branche protégée.
- Ajoutez les étudiants avec le rôle minimal requis.
- Activez la détection de secrets si disponible.
- Créez une branche ou un dépôt privé séparé pour les corrigés.

Avant le push, exécutez `git status` et vérifiez qu'aucun fichier `.pem`, `.env`, identifiant AWS ou résultat volumineux n'est suivi.
