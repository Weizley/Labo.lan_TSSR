## FICHE DE PROCÉDURE : Génération et Déploiement de Clés SSH via PowerShell

**Objectif :** Remplacer l'authentification par mot de passe par une authentification par clé asymétrique sécurisée (ED25519) en utilisant uniquement les outils natifs de Windows (OpenSSH/PowerShell).

---

**Étape 1 : Génération de la paire de clés sur le poste Windows**

- Ouvrir un terminal **PowerShell** (sans privilèges d'administrateur nécessaires).
- Exécuter la commande suivante pour générer une clé basée sur l'algorithme moderne **ED25519** :

PowerShell

ssh-keygen -t ed25519 -C "<prenom.nom@entreprise.fr>"

- - _\-t ed25519 : Spécifie l'algorithme de chiffrement (recommandé pour sa sécurité et sa rapidité)._
    - _\-C : Ajoute un commentaire pour identifier facilement le propriétaire de la clé sur le serveur._

- **Interactions dans la console :**
  - **Emplacement :** À l'invite Enter file in which to save the key, appuyer sur **Entrée** pour accepter le chemin par défaut (\$HOME\\.ssh\\id_ed25519).
  - **Passphrase :** Saisir un mot de passe robuste pour chiffrer la clé privée sur le poste de travail, puis valider.

---  

**Étape 2 : Vérification des fichiers générés**

Pour s'assurer que la génération a réussi, lister le contenu du répertoire SSH local :

PowerShell

Get-ChildItem \$HOME\\.ssh\\

Le dossier doit impérativement contenir deux fichiers distincts :

- **id_ed25519** : La **clé privée**. _Ne doit jamais être partagée ou transférée._
- **id_ed25519.pub** : La **clé publique**. _C'est celle qui sera copiée sur les serveurs cibles._

---

**Étape 3 : Déploiement de la clé publique sur le serveur Linux**

**Méthode A : Automatique (via PowerShell)**

Si l'authentification par mot de passe est encore active sur le serveur distant, exécuter cette ligne de commande (adapter le port et l'IP) :

PowerShell

Get-Content \$HOME\\.ssh\\id_ed25519.pub | ssh -p 5555 utilisateur@IP_SERVEUR "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

**Méthode B : Manuelle (Copier-Coller sécurisé)**

Si la méthode automatique échoue ou si l'accès par mot de passe est coupé :

- Afficher le contenu de la clé publique dans PowerShell :

PowerShell

Get-Content \$HOME\\.ssh\\id_ed25519.pub

- Copier la ligne de texte générée (qui commence par ssh-ed25519).
- Se connecter au serveur Linux et ouvrir le fichier de destination :

Bash

nano ~/.ssh/authorized_keys

- Coller la clé sur une **nouvelle ligne** à la fin du fichier, puis sauvegarder (Ctrl+O, Ctrl+X).

---

**Étape 4 : Sécurisation des permissions sur le serveur Linux**

Le démon sshd refuse les clés si les droits du dossier ou du fichier sont trop permissifs. Exécuter les commandes suivantes sur le serveur cible :

Bash

\# Restriction des droits sur le dossier (Lecture/Écriture/Exécution pour le propriétaire seul)

chmod 700 ~/.ssh

\# Restriction des droits sur le fichier des clés (Lecture/Écriture pour le propriétaire seul)

chmod 600 ~/.ssh/authorized_keys

\# Validation de la propriété de l'utilisateur sur son dossier

chown -R \$USER:\$USER ~/.ssh

---

**Étape 5 : Connexion et validation**

Depuis le PowerShell Windows, initier la connexion SSH :

PowerShell

ssh -p 5555 utilisateur@IP_SERVEUR

---

**Étape 6 : Optimisation de l'ergonomie (Optionnel)**

Pour éviter de spécifier l'IP, le port et l'utilisateur à chaque connexion, créer un fichier texte nommé config (sans extension) dans le dossier C:\\Users\\Utilisateur\\.ssh\\ du poste Windows :

Plaintext

Host mon-serveur

HostName 10.8.0.101

User william

Port 5555

IdentityFile ~/.ssh/id_ed25519

**Résultat :** Un simple ssh mon-serveur dans PowerShell suffit désormais pour ouvrir la session de manière totalement transparente.