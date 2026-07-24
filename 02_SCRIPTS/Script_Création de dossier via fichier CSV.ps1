# Script PowerShell - Création automatique de dossier via fichier CSV
# Auteur : William Eiselé
# Version : 1.0

# 1. Définition des sous-dossiers à créer pour chaque utilisateur
$SousDossiers = @(
   "Documents",
   "Téléchargements",
   "Privé"
)

# 2. Lecture du fichier CSV et boucle pour chaque ligne 
Import-Csv -Path "C:\Chemin\Username.csv" | ForEach-Object {

   # Définition du chemin du dossier principal de l'utilisateur
   $CheminUtilisateur = "C:\Chemin\$($_.UserName)"

   # Étape A : Création du dossier principal de l'utilisateur
   New-Item -Path "C:\Chemin\" -Name $_.UserName -ItemType Directory -Force

   # Étape B : Création des sous-dossiers à l'intérieur du dossier principal
   $SousDossiers | ForEach-Object { 
      New-Item -Path $CheminUtilisateur -Name $_ -ItemType Directory -Force
   }
}