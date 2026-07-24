**FICHE DE PROCÉDURE : Mise en place d\'unVPN point à point wireguard
(debian to windows)**

**Objectifs :** L\'objectif de cette procédure est de sécuriser les flux
d\'administration entre un poste client Windows et un serveur Debian en
mettant en œuvre un tunnel VPN de type \"Point à Point\" basé sur le
protocole **WireGuard**.

**1.Informations d\'adressage (Lab) :**

-   **Réseau LAN physique :** 10.8.0.0/24

-   **IP LAN Serveur Debian :** 10.8.0.101

-   **Sous-réseau dédié au VPN :** 10.9.0.0/24

-   **IP Virtuelle (Tunnel) Serveur :** 10.9.0.1/24

-   **IP Virtuelle (Tunnel) Client :** 10.9.0.2/32

-   **Port d\'écoute UDP :** 51820

**2. Configuration du Serveur VPN (Debian)**

**Étape 2.1 : Installation des paquets**

Mettre à jour les dépôts et installer les outils WireGuard nécessaires :

Bash

sudo apt update

sudo apt install wireguard iptables -y

**Étape 2.2 : Activation du routage IPv4 (IP Forwarding)**

Pour que le trafic puisse transiter à travers le serveur Debian vers
d\'autres sous-réseaux, le routage doit être activé au niveau du noyau
Linux.

1.  Créer un fichier de configuration persistant pour le noyau :

Bash

sudo nano /etc/sysctl.d/wireguard.conf

2.  Ajouter la directive suivante :

Plaintext

net.ipv4.ip_forward=1

3.  Appliquer immédiatement la modification sans redémarrer :

Bash

sudo sysctl -p /etc/sysctl.d/wireguard.conf

**Étape 2.3 : Génération du couple de clés du serveur**

Générer la clé privée et la clé publique du serveur dans le répertoire
sécurisé de WireGuard :

Bash

cd /etc/wireguard/

umask 077

wg genkey \| tee privatekey \| wg pubkey \> publickey

-   Pour afficher la clé privée nécessaire au fichier de configuration :
    cat privatekey

-   Pour afficher la clé publique à fournir au client Windows : cat
    publickey

**Étape 2.4 : Création du fichier de configuration wg0.conf**

1.  Créer et éditer le fichier :

Bash

sudo nano /etc/wireguard/wg0.conf

2.  Insérer la configuration suivante :

Ini, TOML

\[Interface\]

Address = 10.9.0.1/24

ListenPort = 51820

PrivateKey = \<INSÉRER_LA_CLÉ_PRIVÉE_DU_SERVEUR\>

SaveConfig = false

\[Peer\]

\# Identité du client Windows

PublicKey = \<INSÉRER_LA_CLÉ_PUBLIQUE_GÉNÉRÉE_PAR_WINDOWS\>

AllowedIPs = 10.9.0.2/32

**3. Configuration du Client VPN (Windows)**

**Étape 3.1 : Installation**

1.  Télécharger et installer le client officiel WireGuard depuis le site
    officiel (wireguard.com).

2.  Ouvrir l\'application et cliquer sur la flèche à côté de \"Ajouter
    un tunnel\" **Ajouter un tunnel vide\...**

**Étape 3.2 : Configuration du fichier client**

WireGuard génère automatiquement un couple de clés privées/publiques dès
l\'ouverture de la fenêtre.

1.  **Copier la \"Clé publique\" affichée en haut** pour l\'intégrer
    dans le fichier wg0.conf du serveur Debian (Étape 2.4).

2.  Compléter l\'encadré de texte avec la configuration suivante :

Ini, TOML

\[Interface\]

PrivateKey = \<GÉNÉRÉE_AUTOMATIQUEMENT_PAR_WINDOWS\>

Address = 10.9.0.2/32

\[Peer\]

\# Identité du serveur Debian

PublicKey = \<INSÉRER_LA_CLÉ_PUBLIQUE_DU_SERVEUR_DEBIAN\>

Endpoint = 10.8.0.101:51820

AllowedIPs = 10.9.0.0/24, 10.8.0.0/24

*La directive AllowedIPs côté client force le système d\'exploitation
Windows à router le réseau du tunnel (10.9.0.0/24) ET le réseau LAN
physique (10.8.0.0/24) à travers le VPN.*

**4. Initialisation et Validation du Tunnel**

**Étape 4.1 : Démarrage des services**

-   **Sur Debian :** Activer et démarrer l\'interface virtuelle wg0 :

Bash

sudo wg-quick up wg0

*(Pour automatiser le lancement au démarrage du serveur : sudo systemctl
enable wg-quick@wg0)*

-   **Sur Windows :** Dans l\'interface WireGuard, sélectionner le
    tunnel et cliquer sur **Activer**.

**Étape 4.2 : Commandes de vérification et de diagnostic (Recette)**

Pour valider le bon fonctionnement de l\'infrastructure, exécuter les
tests suivants :

1.  **Vérification de l\'état du tunnel (Côté Serveur) :**

Bash

sudo wg show

*Le statut doit afficher le pair (peer) avec la mention latest handshake
indiquant le nombre de secondes depuis la dernière communication
réussie.*

2.  **Test de connectivité ICMP (Côté Client) :** Ouvrir une invite de
    commandes Windows (cmd) et tester l\'IP virtuelle du serveur ainsi
    qu\'une IP du LAN physique

DOS

ping 10.9.0.1

ping 10.8.0.10 (Routage asymétrique sur Pfsense pour que le ping
fonctionne)

**5. Règle d\'or pour le maintien en condition opérationnelle (MCO)**

**Alerte Configuration :** Ne jamais modifier manuellement le fichier
/etc/wireguard/wg0.conf sur Debian lorsque l\'interface est active si la
directive SaveConfig = true est utilisée. Si des modifications doivent
être apportées, toujours couper l\'interface au préalable via la
commande sudo wg-quick down wg0. Dans cette procédure, l\'option a été
passée à false pour éviter les écrasements accidentels de clés.
