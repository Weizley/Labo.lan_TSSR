**FICHE DE PROCEDURE : Sécurisation d'un serveur Debian 13**

**Objectif :** Durcissement d'un serveur d\'infrastructure Linux (Debian
13) **Application :** Serveur GLPI (Environnement de Laboratoire /
Production)
---

Cette procédure décrit les étapes indispensables pour sécuriser l\'accès
local et réseau d\'un serveur Debian 13 hébergeant un service GLPI, tout
en garantissant la continuité des services d\'infrastructure
interconnectés (Cluster Proxmox VE, Quorum, partage NFS, VPN Wireguard).

**Prérequis & règles de sécurité**

Disposer d\'un accès avec les privilèges sudo ou root.
---

**Étape 1 : sécurisation avant modification (sauvegarde & instantané)**

Avant toute action technique sur le pare-feu ou les comptes, il est
obligatoire de créer des points de restauration.

**1.1. Instantané de l\'infrastructure (Hyperviseur)**

1.  Se connecter sur l\'interface de l\'hyperviseur (VMware
    Workstation).

2.  Sélectionner la machine virtuelle hébergeant le GLPI.

3.  Créer un **Snapshot (Instantané)**

**1.2. Sauvegarde locale des fichiers de configuration**

Sur le terminal de la Debian, exécuter la commande suivante pour
archiver le répertoire contenant l\'ensemble des configurations du
système :

Bash

sudo tar -czf sauvegardepro.tar.gz /etc

*Vérification de la création de l\'archive :* ls -lh
sauvegardepro.tar.gz
---

**Étape 2 : gestion des comptes et sécurisation des droits critiques**

**2.1. Vérification des droits du fichier de mots de passe**

Le fichier /etc/shadow contient les empreintes des mots de passe. Ses
droits doivent être limités au maximum (640 ou rw-r\-\-\-\--).

Bash

ls -l /etc/shadow

*Résultat attendu :* -rw-r\-\-\-\-- 1 root shadow \[\...\] /etc/shadow

**2.2. Verrouillage des comptes obsolètes ou temporaires**

Pour interdire l\'accès à un compte utilisateur dormant (ex:
test_stagiaire) sans supprimer ses données, appliquer un verrouillage
(*Lock*) du mot de passe :

Bash

sudo usermod -L test_stagiaire

*Vérification :* Exécuter sudo tail -n 5 /etc/shadow. Un point
d\'exclamation (!) doit apparaître au début du hachage du mot de passe
de l\'utilisateur, invalidant toute authentification.
---

**Étape 3 : durcissement réseau et configuration du pare-feu (ufw)**

**3.1. Audit des ports en écoute**

Identifier les services actifs sur la machine avant restriction :

Bash

sudo ss -tuln

\# Ou l\'alternative :

sudo netstat -tuln

**3.2. Initialisation des politiques par défaut d\'UFW**

Installer le paquet si nécessaire (sudo apt install ufw -y), puis
définir le blocage par défaut :

Bash

sudo ufw default deny incoming

sudo ufw default allow outgoing

**3.3. Définition des règles d\'autorisation (Flux métiers)**

Exécuter les commandes suivantes pour autoriser uniquement les flux
indispensables :

Bash

\# Accès Web GLPI (HTTP & HTTPS)

sudo ufw allow 80/tcp

sudo ufw allow 443/tcp

\# Administration distante (OpenSSH)

sudo ufw allow 22/tcp

\# Tunnel VPN (Wireguard)

sudo ufw allow 51820/udp

\# Interconnexion Cluster Proxmox VE (Quorum / NFS)

sudo ufw allow from 10.8.0.12

sudo ufw allow from 10.8.0.13

**3.4. Activation et validation**

Activer le pare-feu :

Bash

sudo ufw enable

Vérifier la bonne application des règles :

Bash

sudo ufw status
---

**Procédure de repli (rollback)**

En cas de coupure des flux critiques, d\'isolement du serveur ou de
dysfonctionnement du cluster de virtualisation :

1.  Taper immédiatement en console locale : sudo ufw disable.

2.  Si le système est instable ou inaccessible, restaurer l\'instantané
    (*Revert to Snapshot*) depuis l\'hyperviseur VMware/Proxmox pour
    revenir à l\'état initial (Étape 1).
