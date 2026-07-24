**FICHE DE PROCEDURE : Création d'une DMZ et Déploiement d'un Serveur Web Nginx sous Debian**

**Objectif :** Étendre l'infrastructure de filtrage pfSense en créant une troisième zone étanche (DMZ) pour héberger un serveur Web public Nginx, tout en garantissant l'isolation du réseau privé (LAN).

**Étape 1 : Cartographie et Plan d'Adressage mis à jour**

Pour cette extension, un nouveau réseau virtuel est créé afin de cloisonner la DMZ :

| **Zone Réseau** | **Commutateur (VMware)** | **Adresse Réseau** | **IP Passerelle (pfSense)** | **IP Machine(s)**           |
| --------------- | ------------------------ | ------------------ | --------------------------- | --------------------------- |
| **DMZ**         | **VMnet2 (Hôte un.)**    | **172.16.0.0 /24** | **172.16.0.2**              | **172.16.0.50 (SRV-WEB01)** |

**Étape 2 : Provisionnement Matériel de la DMZ dans VMware**

**1\. Configuration du vSwitch / Réseau Virtuel**

- Ouvrir le **Virtual Network Editor** en mode Administrateur.
- Cliquer sur **Add Network** et sélectionner **VMnet2**.
- Configurer l'option sur **Host-only (Hôte uniquement)**.
- **Décocher** la case _"Utiliser le service DHCP virtuel de VMware"_.
- Appliquer et valider par **OK**.

**2\. Ajout de l'interface sur la VM pfSense**

- Éteindre proprement la VM pfSense.
- Accéder aux paramètres de la VM (_Edit virtual machine settings_).
- Cliquer sur **Add...** > **Network Adapter** > _Finish_.
- Sélectionner cette nouvelle interface (_Network Adapter 3_) et l'assigner à **Custom : VMnet2**.
- Valider et démarrer le pare-feu pfSense.

**Étape 3 : Activation et Assignation de l'interface dans pfSense**

- Depuis le poste d'administration du LAN, se connecter au WebGUI (<https://10.8.0.2>).
- Naviguer vers **Interfaces > Assignments**.
- Dans la section _Available network ports_, repérer la nouvelle interface réseau (ex: em2) et cliquer sur **\+ Add**.
- Cliquer sur le lien bleu de l'interface créée (généralement nommée **OPT1**).
- Configurer les paramètres comme suit :
  - **Enable :** Cochez la case _Enable interface_.
  - **Description :** Saisir **DMZ**.
  - **IPv4 Configuration Type :** Sélectionner **Static IPv4**.
- Dans la section _Static IPv4 Configuration_ :
  - **IPv4 Address :** Saisir **172.16.0.2** et sélectionner le masque **24** (équivalent à 255.255.255.0).
- Laisser la passerelle upstream sur _None_.
- Cliquer sur **Save** en bas de page, puis sur **Apply Changes** en haut.

**Étape 4 : Politique de Sécurité et Règles de Filtrage (Firewalling)**

Par défaut, pfSense applique un blocage implicite (_Deny All_). L'objectif TSSR est d'isoler le LAN de la DMZ tout en permettant à la DMZ d'aller sur Internet.

- Naviguer vers **Firewall > Rules** et cliquer sur l'onglet **DMZ**.
- **Créer la Règle 1 (Blocage de sécurité vers le LAN) :**
  - Cliquer sur **Add**
  - **Action :** Block
  - **Protocol :** Any _(Crucial pour bloquer aussi bien le TCP, l'UDP que l'ICMP/Ping)_.
  - **Source :** DMZ net
  - **Destination :** LAN net _(Piège TSSR : ne pas choisir LAN address, mais bien LAN net)_.
  - **Description :** Sécurité : Isolation DMZ vers LAN
  - Cliquer sur **Save**.
- **Créer la Règle 2 (Autorisation vers Internet) :**
  - Cliquer sur **Add**
  - **Action :** Pass
  - **Protocol :** Any
  - **Source :** DMZ net
  - **Destination :** Any
  - **Description :** Flux : Autoriser DMZ vers Internet
  - Cliquer sur **Save**.
- Appliquer la configuration avec le bouton **Apply Changes**.

**Étape 5 : Déploiement et Configuration du Serveur Debian Nginx**

**1\. Provisionnement et Réseau de la VM Debian**

- Créer une VM Debian (1 ou 2 vCPUs, 2 Go RAM).
- Assigner sa carte réseau dans VMware sur le réseau personnalisé **VMnet2**.
- Démarrer la VM et procéder à la configuration réseau statique (hors DHCP) :

Ouvrir le fichier des interfaces réseau :

Bash

nano /etc/network/interfaces

Adapter la configuration de l'interface principale (ex: ens33 ou eth0) :

Plaintext

auto ens33

iface ens33 inet static

address 172.16.0.50

netmask 255.255.255.0

gateway 172.16.0.2

dns-nameservers 1.1.1.1 8.8.8.8

_Note : Le DNS pointe obligatoirement vers un résolveur public extérieur, car les serveurs de la DMZ n'ont pas l'autorisation d'interroger le contrôleur de domaine interne 10.8.0.10._

Appliquer les modifications réseau :

Bash

systemctl restart networking

**2\. Installation de Nginx**

S'assurer du privilège root, puis exécuter la mise à jour et l'installation du serveur Web :

Bash

apt update && apt upgrade -y

apt install nginx -y

Vérifier le statut du service :

Bash

systemctl status nginx

**Étape 6 : Tests de Recette Technique (Validation TSSR)**

Exécuter les diagnostics de validation depuis le terminal du serveur Debian (172.16.0.50) pour certifier la conformité de la maquette :

Bash

\# 1. Validation de la Gateway DMZ

ping -c 4 172.16.0.2

\--> Statut attendu : Réponse positive (Couche 3 fonctionnelle).

\# 2. Validation de l'isolation du LAN (Règle de sécurité pfSense)

ping -c 4 10.8.0.10

\--> Statut attendu : 100% de paquets perdus (Échec du ping). L'infrastructure est sécurisée.

\# 3. Validation de la résolution DNS et de l'accès WAN

ping -c 4 google.fr

\--> Statut attendu : Résolution IP instantanée et réponse positive (Internet fonctionnel).

**Validation finale depuis le LAN :**

Depuis le navigateur du contrôleur de domaine Windows Server (10.8.0.10), saisir l'URL <http://172.16.0.50>. La page d'accueil Nginx doit apparaître, confirmant le droit de transit légitime du LAN vers la DMZ.