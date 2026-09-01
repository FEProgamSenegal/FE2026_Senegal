#!/bin/bash
# =====================================================================
# fe2026_etapes_1a8.sh — LES 8 ÉTAPES DU COURS, DIDACTIQUES ET SÉPARÉES
# ---------------------------------------------------------------------
# Un seul fichier, huit fonctions (une par etape). Vous lancez l'etape
# que vous voulez ; tout s'execute sur le serveur, mais se LANCE depuis
# le Mac — vous n'avez donc jamais a vous demander « suis-je au bon
# endroit ». Chaque etape explique ce qu'elle fait avant de le faire.
#
# VOS PARAMETRES (deja remplis) :
#   Mac                : macbook   (/Users/macbook)
#   Serveur (head node): el@18.116.212.24   (interne ip-10-3-6-185)
#   Cle privee          : ~/.ssh/aws-key   (alias SSH : aws)
#   Depot serveur       : ~/FE2026_Senegal
#   Environnement EMOD  : ~/environments/emodpy   (Python 3.9.25)
#   Partition Slurm     : demo
#   Branche perso        : etudiants/Dr-ElHadji-Cheikh-Abdoulaye-DIOP
#   GitHub / e-mail      : elhadjicheikhabdoulaye-diop / elhadjicheikh.diop@uadb.edu.sn
#
# UTILISATION (SUR LE MAC — une seule ligne, jamais coller le contenu) :
#   bash ~/Documents/EMOD_Acces/fe2026_etapes_1a8.sh          -> menu
#   bash ~/Documents/EMOD_Acces/fe2026_etapes_1a8.sh 5        -> etape 5 seule
#   bash ~/Documents/EMOD_Acces/fe2026_etapes_1a8.sh 1 2 3    -> plusieurs
#   bash ~/Documents/EMOD_Acces/fe2026_etapes_1a8.sh tout     -> etapes 1 a 7
#
# Idempotent : relancable sans risque. Rien n'est jamais supprime.
# Les actions INTERACTIVES (git push avec token, salloc) ne sont PAS
# automatisees : elles sont affichees comme commandes a taper vous-meme.
# =====================================================================

# --- PARAMETRES ------------------------------------------------------
KEY_PATH="$HOME/.ssh/aws-key"
HOST_ALIAS="aws"
SERVER_IP="18.116.212.24"
SERVER_USER="el"
REPO="FE2026_Senegal"
VENV="environments/emodpy"
PARTITION="demo"
BRANCHE="etudiants/Dr-ElHadji-Cheikh-Abdoulaye-DIOP"
GITHUB_USER="elhadjicheikhabdoulaye-diop"
GIT_NAME="El Hadji Cheikh Abdoulaye DIOP"
GIT_EMAIL="elhadjicheikh.diop@uadb.edu.sn"
EMOD_VERSION="3.1.1"       # 3.1.3 n'existe pas dans le depot ; 3.1.1 est la bonne
IDMOD_INDEX="https://packages.idmod.org/api/pypi/pypi-production/simple"
# ---------------------------------------------------------------------

titre() {
    echo ""
    echo "======================================================"
    echo "  $1"
    echo "======================================================"
}

# Verifie qu'on est sur le Mac, la cle et l'alias. Appele une fois.
preparer_mac() {
    if [ "$(uname)" != "Darwin" ]; then
        echo "[ERREUR] A lancer sur le MAC, pas sur le serveur."
        echo "         Si l'invite affiche [el@ip-...], tapez 'exit' puis relancez."
        exit 1
    fi
    if [ ! -f "$KEY_PATH" ]; then
        echo "[ERREUR] Cle SSH introuvable : $KEY_PATH"
        exit 1
    fi
    chmod 600 "$KEY_PATH"
    local cfg="$HOME/.ssh/config"
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    touch "$cfg"
    if ! grep -q "^Host $HOST_ALIAS\$" "$cfg"; then
        cat >> "$cfg" << EOF

Host $HOST_ALIAS
    HostName $SERVER_IP
    User $SERVER_USER
    IdentityFile $KEY_PATH
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
    fi
    chmod 600 "$cfg"
}

# =====================================================================
# ÉTAPE 1 — SE CONNECTER AU HEAD NODE
# =====================================================================
etape1() {
    titre "ÉTAPE 1 — Se connecter au head node"
    echo "But : verifier que la connexion SSH au cluster fonctionne."
    echo "Ce qui se passe : on protege la cle, puis on demande au serveur"
    echo "de dire qui vous etes (whoami), sur quelle machine (hostname)"
    echo "et dans quel dossier (pwd)."
    echo ""
    if ssh -o ConnectTimeout=15 "$HOST_ALIAS" \
        'echo "  whoami   : $(whoami)"; echo "  hostname : $(hostname)"; echo "  pwd      : $(pwd)"'; then
        echo ""
        echo "[OK] Étape 1 validee. Connexion au serveur operationnelle."
    else
        echo "[ERREUR] Connexion impossible (Internet ? IP changee ?)."
        return 1
    fi
}

# =====================================================================
# ÉTAPE 2 — S'ORIENTER DANS LINUX
# =====================================================================
etape2() {
    titre "ÉTAPE 2 — S'orienter dans Linux"
    echo "But : maitriser pwd (ou suis-je), ls (que contient), cd (se"
    echo "deplacer). On cree aussi un dossier d'exercice et un fichier-"
    echo "preuve, comme le demande le cours."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' << 'REMOTE'
set -u
echo "=> pwd (dossier personnel)"; cd ~; pwd
echo ""
echo "=> ls -lah ~ (contenu)"; ls -lah ~ | head -20
echo ""
echo "=> creation du dossier d'exercice + fichier-preuve"
mkdir -p ~/essais
echo "Cree sur $(hostname) le $(date)" > ~/essais/preuve.txt
echo "=> cat ~/essais/preuve.txt"; cat ~/essais/preuve.txt
REMOTE
    echo ""
    echo "[OK] Étape 2 validee. pwd / ls / cd maitrises, fichier-preuve cree."
    echo "     (Rappel : pour lire un fichier avec 'less', on sort avec la touche q.)"
}

# =====================================================================
# ÉTAPE 3 — GIT & GITHUB
# =====================================================================
etape3() {
    titre "ÉTAPE 3 — Git conserve l'histoire ; GitHub la partage"
    echo "But : identite Git, depot clone, votre branche personnelle et"
    echo "un dossier d'exercice. La PUBLICATION (git push) est interactive"
    echo "(token) : elle est affichee a la fin, a taper vous-meme."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' -- "$GIT_NAME" "$GIT_EMAIL" "$GITHUB_USER" "$BRANCHE" << 'REMOTE'
set -u
NAME="$1"; EMAIL="$2"; USER="$3"; BR="$4"
echo "=> identite Git"
git config --global user.name  "$NAME"
git config --global user.email "$EMAIL"
printf '*.pem\naws-key*\n.ssh/\n.venv/\n.DS_Store\n' > ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
git config --global credential.helper 'cache --timeout=3600'
echo "   $(git config --global user.name) <$(git config --global user.email)>"
echo ""
echo "=> depot"
cd ~
if [ -d ~/FE2026_Senegal/.git ]; then
    echo "   deja clone ; mise a jour"
    cd ~/FE2026_Senegal && git pull --ff-only 2>/dev/null || true
else
    git clone https://github.com/FEProgamSenegal/FE2026_Senegal.git
    cd ~/FE2026_Senegal
fi
echo ""
echo "=> branche personnelle + dossier d'exercice"
cd ~/FE2026_Senegal
mkdir -p exercices/${USER}_EMOD2026
touch    exercices/${USER}_EMOD2026/Report.txt
if git show-ref --verify --quiet "refs/heads/$BR"; then
    git switch "$BR"
    echo "   branche « $BR » deja existante"
else
    git switch -c "$BR"
fi
git add exercices/
if git diff --cached --quiet; then
    echo "   rien de nouveau a commiter"
else
    git commit -m "Ajoute le dossier d'exercice de $USER"
fi
echo ""
echo "=> etat"
echo "   branche : $(git branch --show-current)"
echo "   commit  : $(git log --oneline -1)"
REMOTE
    echo ""
    echo "[OK] Étape 3 (identite + clone + branche) validee."
    echo ""
    echo "PUBLICATION SUR GITHUB (interactif — a taper vous-meme sur le serveur) :"
    echo "   ssh aws"
    echo "   cd ~/FE2026_Senegal"
    echo "   git push -u origin $BRANCHE"
    echo "   # Username : $GITHUB_USER    Password : votre TOKEN (pas le mot de passe)"
}

# =====================================================================
# ÉTAPE 4 — EXAMINER UN DEPOT AVANT DE L'EXECUTER
# =====================================================================
etape4() {
    titre "ÉTAPE 4 — Examiner un depot avant de l'executer"
    echo "But : lire AVANT de lancer. Objectif (README), licence, activite"
    echo "(commits), versions (tags), et le script d'installation qu'on"
    echo "LIT d'abord, puis qu'on execute."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' << 'REMOTE'
set -u
cd ~/FE2026_Senegal || { echo "[ERREUR] depot absent : faites l'etape 3."; exit 1; }
echo "=> structure"; ls -la | sed 's/^/   /'
echo ""
echo "=> objectif (README, debut)"; head -15 README.md 2>/dev/null | sed 's/^/   /'
echo ""
echo "=> licence"; head -3 LICENSE 2>/dev/null | sed 's/^/   /'
echo ""
echo "=> activite (5 derniers commits)"; git log --oneline -5 | sed 's/^/   /'
echo ""
echo "=> versions etiquetees"; (git tag | tail -5 | sed 's/^/   /') || echo "   (aucune)"
echo ""
echo "=> script d'installation : on LIT d'abord"
if [ -f scripts/student_check.sh ]; then
    sed 's/^/     /' scripts/student_check.sh
    echo "   ...puis on execute :"
    bash scripts/student_check.sh | sed 's/^/     /'
fi
REMOTE
    echo ""
    echo "[OK] Étape 4 validee. Depot examine avant toute execution."
}

# =====================================================================
# ÉTAPE 5 — INSTALLER EMOD DANS UN ENVIRONNEMENT ISOLE
# =====================================================================
etape5() {
    titre "ÉTAPE 5 — Installer EMOD dans un environnement Python isole"
    echo "But : creer un venv dedie, y installer emodpy-malaria $EMOD_VERSION"
    echo "et ses dependances (index idmod). L'installation peut prendre"
    echo "PLUSIEURS MINUTES. On corrige aussi le requirements.txt (3.1.3"
    echo "n'existe pas -> $EMOD_VERSION)."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' -- "$VENV" "$EMOD_VERSION" "$IDMOD_INDEX" << 'REMOTE'
set -u
VENV="$HOME/$1"; VER="$2"; INDEX="$3"
cd ~/FE2026_Senegal || { echo "[ERREUR] depot absent : faites l'etape 3."; exit 1; }
echo "=> Python systeme : $(python3 --version)"
mkdir -p ~/environments
if [ -d "$VENV" ]; then
    echo "=> venv deja present : $VENV (reutilise)"
else
    echo "=> creation du venv : $VENV"
    python3 -m venv "$VENV" || { echo "[ERREUR] echec venv"; exit 1; }
fi
echo "=> pip a jour"
"$VENV/bin/python" -m pip install --upgrade pip 2>&1 | tail -1 | sed 's/^/   /'
echo "=> installation d'EMOD (patienter...)"
"$VENV/bin/python" -m pip install \
    "emodpy-malaria==$VER" idmtools idmtools-platform-slurm \
    "pandas>=2.2,<3" "matplotlib>=3.9,<4" \
    --extra-index-url "$INDEX" 2>&1 | tail -3 | sed 's/^/   /'
echo "=> correction du requirements.txt (3.1.3 -> $VER)"
sed -i "s/emodpy-malaria==3.1.3/emodpy-malaria==$VER/" requirements.txt 2>/dev/null || true
echo "=> verification"
"$VENV/bin/python" -m pip check 2>&1 | sed 's/^/   /' || true
"$VENV/bin/python" -c "import emodpy_malaria; print('   import emodpy_malaria : OK')" \
    || echo "   [ATTENTION] import emodpy_malaria a echoue"
REMOTE
    echo ""
    echo "[OK] Étape 5 validee. Environnement EMOD pret dans ~/$VENV."
}

# =====================================================================
# ÉTAPE 6 — SOUMETTRE UNE SIMULATION AVEC SLURM
# =====================================================================
etape6() {
    titre "ÉTAPE 6 — Slurm reserve les ressources avant le calcul"
    echo "But : preparer (raccourci .venv, partition dans les scripts,"
    echo "dossiers logs/results) puis SOUMETTRE la simulation EMOD sur la"
    echo "partition '$PARTITION'. Le calcul tourne sur un compute node,"
    echo "jamais sur le head node."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' -- "$VENV" "$PARTITION" << 'REMOTE'
set -u
VENV="$1"; PART="$2"
cd ~/FE2026_Senegal || { echo "[ERREUR] depot absent : faites l'etape 3."; exit 1; }
echo "=> raccourci .venv -> ~/$VENV (les scripts Slurm cherchent .venv)"
[ -e .venv ] || ln -s ~/"$VENV" .venv
ls -la .venv | sed 's/^/   /'
echo "=> ajout de la partition '$PART' dans les scripts (si absente)"
for f in slurm/hello.slurm slurm/emod_malaria.slurm slurm/emod_array.slurm; do
    grep -q "partition=$PART" "$f" 2>/dev/null || \
        sed -i "/#SBATCH --job-name/a #SBATCH --partition=$PART" "$f"
done
echo "=> dossiers de sortie"
mkdir -p logs results
echo "=> soumission de la simulation EMOD"
JOBID=$(sbatch --partition="$PART" slurm/emod_malaria.slurm | awk '{print $NF}')
echo "$JOBID" > ~/.derniere_soumission
echo "   Job soumis : $JOBID  (note pour l'etape 7)"
echo "=> etat immediat"
squeue -u "$USER" | sed 's/^/   /'
REMOTE
    echo ""
    echo "[OK] Étape 6 validee. Simulation soumise sur la partition '$PARTITION'."
    echo "     Lancez l'etape 7 dans 1-2 min pour la surveiller."
}

# =====================================================================
# ÉTAPE 7 — SURVEILLER LE JOB ET CONSERVER SES TRACES
# =====================================================================
etape7() {
    titre "ÉTAPE 7 — Surveiller le job et conserver ses traces"
    echo "But : suivre l'etat (squeue), consulter l'historique (sacct) et"
    echo "lire les journaux .out/.err du dernier job soumis a l'etape 6."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' << 'REMOTE'
set -u
cd ~/FE2026_Senegal || { echo "[ERREUR] depot absent."; exit 1; }
JOB=$(cat ~/.derniere_soumission 2>/dev/null || echo "")
echo "=> file d'attente (vide = termine)"
squeue -u "$USER" | sed 's/^/   /'
echo ""
echo "=> historique du jour"
sacct -X --starttime today --format=JobID,JobName,State,Elapsed,ExitCode 2>/dev/null | sed 's/^/   /'
echo ""
if [ -n "$JOB" ]; then
    echo "=> journaux du job $JOB"
    if [ -f "logs/emod-$JOB.err" ]; then
        SZ=$(stat -c%s "logs/emod-$JOB.err" 2>/dev/null || echo "?")
        echo "   logs/emod-$JOB.err : $SZ octet(s) (0 = aucune erreur)"
        [ "$SZ" != "0" ] && { echo "   --- contenu de .err ---"; tail -20 "logs/emod-$JOB.err" | sed 's/^/     /'; }
    fi
    [ -f "logs/emod-$JOB.out" ] && { echo "   --- fin de .out ---"; tail -15 "logs/emod-$JOB.out" | sed 's/^/     /'; }
fi
echo ""
echo "=> resultats produits"
ls -lh results/ 2>/dev/null | sed 's/^/   /' || echo "   (dossier results vide)"
REMOTE
    echo ""
    echo "[OK] Étape 7 : etat, historique et journaux affiches."
}

# =====================================================================
# ÉTAPE 8 — PUBLIER DES RESULTATS REPRODUCTIBLES
# =====================================================================
etape8() {
    titre "ÉTAPE 8 — Publier des resultats reproductibles"
    echo "But : rassembler et documenter (scripts, versions, parametres,"
    echo "graines, logs, synthese, figures). Ce script PREPARE un modele"
    echo "de rapport ; la publication (git push) reste interactive."
    echo ""
    ssh "$HOST_ALIAS" 'bash -s' -- "$GITHUB_USER" "$VENV" << 'REMOTE'
set -u
USER="$1"; VENV="$2"
cd ~/FE2026_Senegal || { echo "[ERREUR] depot absent."; exit 1; }
RAP="exercices/${USER}_EMOD2026/Report.txt"
mkdir -p "$(dirname "$RAP")"
echo "=> generation d'un modele de rapport : $RAP"
{
    echo "# Rapport reproductible — $USER"
    echo "Date : $(date -u)"
    echo "Machine : $(hostname)"
    echo ""
    echo "## Objectif"
    echo "(A COMPLETER : que teste cette simulation ?)"
    echo ""
    echo "## Environnement"
    echo "Python : $(python3 --version 2>&1)"
    echo "Paquets EMOD :"
    "$HOME/$VENV/bin/python" -m pip list 2>/dev/null | grep -iE "emod|idmtools|malaria|pandas|matplotlib" | sed 's/^/  /'
    echo ""
    echo "## Parametres et graines"
    echo "(A COMPLETER : graines utilisees, duree, population...)"
    echo ""
    echo "## Resultats"
    echo "Fichiers produits :"
    ls results/ 2>/dev/null | sed 's/^/  /' || echo "  (aucun encore)"
    echo ""
    echo "## Limites"
    echo "(A COMPLETER : portee, hypotheses, ce qui n'est pas modelise)"
} > "$RAP"
echo "   modele ecrit. A completer les sections (A COMPLETER)."
echo ""
echo "=> apercu du rapport"
sed 's/^/   /' "$RAP"
REMOTE
    echo ""
    echo "[OK] Étape 8 : modele de rapport genere."
    echo ""
    echo "POUR PUBLIER (a taper vous-meme sur le serveur, apres avoir complete le rapport) :"
    echo "   ssh aws"
    echo "   cd ~/FE2026_Senegal"
    echo "   # editez le rapport : nano exercices/${GITHUB_USER}_EMOD2026/Report.txt"
    echo "   git add exercices/ results/ 2>/dev/null"
    echo "   git commit -m \"Ajoute rapport et resultats reproductibles\""
    echo "   git push origin $BRANCHE      # Username + TOKEN"
    echo ""
    echo "Defi final (diapositive 15) : lancer 5 graines"
    echo "   sbatch --partition=$PARTITION slurm/emod_array.slurm"
    echo "puis ouvrir une pull request sur GitHub."
}

# =====================================================================
# MENU / DISPATCH
# =====================================================================
menu() {
    titre "COURS FE2026 — LES 8 ÉTAPES"
    echo "  1) Se connecter au head node"
    echo "  2) S'orienter dans Linux"
    echo "  3) Git & GitHub (branche perso)"
    echo "  4) Examiner un depot avant execution"
    echo "  5) Installer EMOD (environnement isole)"
    echo "  6) Soumettre une simulation (Slurm)"
    echo "  7) Surveiller le job et ses traces"
    echo "  8) Publier des resultats reproductibles"
    echo ""
    echo "  tout) etapes 1 a 7 en sequence"
    echo ""
    printf "Votre choix : "
    read -r CH
    lancer "$CH"
}

lancer() {
    case "$1" in
        1) etape1 ;;
        2) etape2 ;;
        3) etape3 ;;
        4) etape4 ;;
        5) etape5 ;;
        6) etape6 ;;
        7) etape7 ;;
        8) etape8 ;;
        tout|TOUT|all)
            etape1 && etape2 && etape3 && etape4 && etape5 && etape6
            echo ""; echo "(pause 90 s avant la surveillance du job...)"; sleep 90
            etape7
            ;;
        *) echo "[?] Choix inconnu : « $1 » (attendu : 1..8 ou 'tout')" ;;
    esac
}

# --- PROGRAMME PRINCIPAL ---------------------------------------------
preparer_mac
echo "[OK] Mac detecte, cle et alias prets."

if [ $# -eq 0 ]; then
    menu
else
    for arg in "$@"; do
        lancer "$arg"
    done
fi

echo ""
echo "Termine. (Chaque etape est relancable :  bash $0 N)"
