## FICHE DE PROCÉDURE : Mise en place d’un partage de fichiers NFS

**Objectif :** Configurer un partage réseau persistant entre un serveur Debian et un client Ubuntu.

---

**1. Architecture du Labo**

- **Serveur :** 10.8.0.101
- **Client :** 10.8.0.102
- **Protocole :** NFSv4

---

**Configuration du Serveur (Debian)**

**Étape 1 : Installation du service**

sudo apt update

sudo apt install nfs-kernel-server -y

---

**Étape 2 : Création de l'arborescence**

sudo mkdir -p /export/shared

sudo chown nobody:nogroup /export/shared

sudo chmod 777 /export/shared

---

**Étape 3 : Configuration des droits (Exports)**

Éditer le fichier /etc/exports : sudo nano /etc/exports Ajouter les lignes suivantes :

Plaintext

/export         10.8.0.101(rw,sync,no\_subtree\_check,fsid=0)

/export/shared  10.8.0.102(rw,sync,all\_squash,no\_subtree\_check)

**Étape 4 : Application de la configuration**

sudo exportfs -rav

sudo systemctl restart nfs-kernel-server

**3. Configuration du Client** 

**Étape 1 : Installation des outils**

sudo apt update

sudo apt install nfs-common -y

**Étape 2 : Création du point de montage**

sudo mkdir -p /mnt/nfs/shared

**Étape 3 : Montage manuel et test**

sudo mount -t nfs 10.8.0.101:/shared /mnt/nfs/shared

df -h | grep shared

---

**Étape 4 : Automatisation au démarrage (FSTAB)**

Éditer le fichier /etc/fstab : sudo nano /etc/fstab Ajouter cette ligne à la fin :

Plaintext

10\.0.8.101:/shared  /mnt/nfs/shared  nfs  defaults,user,\_netdev  0  0

---

**4. Vérification et Diagnostic**

- **Vérifier la disponibilité du serveur (depuis le client) :** showmount -e 10.8.0.101
- **Vérifier les statistiques NFS :** nfsstat -s
- **Tester les droits d'écriture :** touch /mnt/nfs/shared/test\_nom.txt

---

**5. Notes Techniques** 

- **fsid=0 :** Définit le dossier racine du serveur NFS pour simplifier le chemin côté client.
- **all\_squash :** Mappe tous les utilisateurs distants sur l'utilisateur anonyme (nobody) pour garantir l'accès sans conflit d'identifiants.
- **\_netdev :** Empêche le système de tenter le montage tant que le réseau n'est pas opérationnel au démarrage.

