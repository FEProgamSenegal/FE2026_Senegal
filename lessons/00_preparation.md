# Module 0 — Préparation

## Comptes et logiciels

Chaque étudiant doit avoir : un compte GitHub avec double authentification, Git, un terminal SSH et un accès attribué par l'enseignant au cluster. Sous Windows, Git Bash ou Windows Terminal avec OpenSSH convient.

Configurez Git avec votre propre identité :

```bash
git config --global user.name "Prénom Nom"
git config --global user.email "adresse-associee-a-github@example.org"
git config --global init.defaultBranch main
git --version
ssh -V
```

## Sécurité

Une clé privée est un secret. Elle ne doit jamais être envoyée par courriel, copiée dans ce dépôt ou partagée avec un camarade. Sous Linux/macOS :

```bash
chmod 600 chemin/vers/votre-cle.pem
```

L'enseignant fournit le nom DNS, le nom d'utilisateur et la méthode de connexion. Ne devinez pas ces valeurs.

## Vérification

```bash
bash scripts/student_check.sh
```

Conservez la sortie et signalez chaque ligne `À INSTALLER` avant la première séance.
