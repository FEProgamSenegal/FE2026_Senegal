# Module 2 — Linux, fichiers et SSH

## Commandes de base

```bash
pwd                 # où suis-je ?
ls -lah             # que contient ce dossier ?
mkdir -p essais     # créer un dossier
cd essais           # entrer dans le dossier
cp source copie     # copier
mv copie nouveau    # déplacer/renommer
less fichier.txt    # lire sans modifier
head -n 5 fichier   # premières lignes
rm fichier          # supprimer un fichier : vérifier avant Entrée
```

## Connexion au cluster

Remplacez uniquement les valeurs fournies par l'enseignant :

```bash
ssh -i chemin/cle.pem UTILISATEUR@NOM_DNS_HEAD_NODE
```

Après connexion :

```bash
hostname
whoami
pwd
df -h
sinfo
```

Le head node sert à préparer et soumettre les travaux. Les calculs doivent s'exécuter sur les compute nodes.

## Transfert

Depuis votre ordinateur, et non depuis la session distante :

```bash
scp -i chemin/cle.pem fichier.txt UTILISATEUR@NOM_DNS_HEAD_NODE:~/
scp -i chemin/cle.pem UTILISATEUR@NOM_DNS_HEAD_NODE:~/resultat.txt .
```

Complétez [l'exercice 2](../exercises/02_linux_ssh.md).
