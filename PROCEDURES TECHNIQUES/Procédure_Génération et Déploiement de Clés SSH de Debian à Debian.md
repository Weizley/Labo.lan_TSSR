**FICHE DE PROCEDURE : Génération et Déploiement de Clés SSH de Debian à Debian**

**Objectif :** Configurer une authentification par clé asymétrique sécurisée entre un serveur Debian "Source" (ex: serveur de supervision ou de script) et un serveur Debian "Cible" (ex: serveur GLPI).

**Étape 1 : Génération de la paire de clés sur la Debian Source**

- Connexion sur **Debian Source** avec l'utilisateur qui doit initier la connexion.
- Exécuter la commande de génération :

Bash

ssh-keygen -t ed25519 -C "admin-debian-source"

- **Interactions dans le terminal :**
  - _Enter file in which to save the key :_ Appuiyer sur **Entrée** (chemin par défaut : ~/.ssh/id_ed25519).
  - _Enter passphrase :_ Laisser **vide** **uniquement s'il s'agit d'une clé destinée à des scripts automatisés** (sauvegardes, tâches cron). Si c'est pour une utilisation humaine, saisir une passphrase.

**Étape 2 : Déploiement automatisé sur la Debian Cible**

On utilise l'outil natif ssh-copy-id qui va automatiquement se connecter, création du dossier .ssh sur la cible et y injecter la clé avec les bonnes permissions.

Exécuter la commande suivante depuis ta Debian Source :

Bash

ssh-copy-id -p 5555 utilisateur@IP_DEBIAN_CIBLE

**Ce qui se passe à l'écran :**

- Le système demande de valider l'empreinte du serveur cible (tape yes).
- Le système demande le **mot de passe** de l'utilisateur sur la Debian Cible.
- Une fois validé, un message confirme qu'**une clé a été ajoutée**.

**Étape 3 : Sécurisation et permissions (Vérification automatique)**

ssh-copy-id configure automatiquement les permissions de sécurité strictes exigées par Linux sur la machine cible.

Voici les droits qui ont été appliqués en tâche de fond sur la **Debian Cible** :

- Dossier ~/.ssh >**Droits 700** (drwx------) : Seul le propriétaire peut lire/écrire/ouvrir le dossier.
- Fichier ~/.ssh/authorized_keys >**Droits 600** (-rw-------) : Seul le propriétaire peut lire/écrire le fichier.

**Étape 4 : Test de connexion**

Depuis la Debian Source, se connecter.

Bash

ssh -p 5555 utilisateur@IP_DEBIAN_CIBLE

**Étape 5 : Fichier config sous Linux**

Tout comme sous Windows, créer un fichier de raccourcis sur Debian Source pour simplifier les commandes ou les scripts.

- Créer ou modifier le fichier de configuration de l'utilisateur :

Bash

nano ~/.ssh/config

- Ajouter la configuration serveur cible :

Plaintext

Host glpi

HostName 10.8.0.101

User william

Port 5555

IdentityFile ~/.ssh/id_ed25519

- Sauvegarder et quitter (Ctrl+O, Ctrl+X).

**Résultat :** Dans les scripts de sauvegarde ou dans le terminal, il faut taper ssh glpi ou rsync -avz /mon/dossier/ glpi:/sauvegarde/.