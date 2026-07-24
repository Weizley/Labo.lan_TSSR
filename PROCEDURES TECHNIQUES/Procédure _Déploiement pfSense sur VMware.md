**FICHE DE PROCEDURE : Déploiement de pfSense sur VMware Workstation en Environnement de Lab**

**Objectif :** Isoler un réseau de commodité (Lab) derrière un pare-feu virtuel pfSense, en assurant le routage NAT et la distribution des flux DNS/DHCP en collaboration avec un contrôleur de domaine Active Directory.
---

**Étape 1 : Architecture Réseau & Plan d'Adressage**

Avant toute manipulation dans l'hyperviseur, la cartographie logicielle des réseaux virtuels (vSwitches/VMnets) doit être définie :

| **Nom Réseau (VMware)** | **Rôle**                   | **Type de Connexion**                             | **Plage IP / Sous-réseau**          |
| ----------------------- | -------------------------- | ------------------------------------------------- | ----------------------------------- |
| **VMnet0**              | **WAN** (Patte publique)   | **Ponté (Bridged)** sur la carte active de l'hôte | DHCP (Attribué par la box internet) |
| **VMnet8**              | **LAN** (Réseau privé Lab) | **Hôte uniquement / Personnalisé**                | 10.8.0.0 /24                        |

**Matrice des flux et adressage statique :**

- **pfSense (LAN) :** 10.8.0.2 (Passerelle par défaut du Lab)
- **Serveur AD (SRV-AD01) :** 10.8.0.10 (Rôles AD, DNS principal, DHCP)
---

**Étape 2 : Configuration de l'Éditeur Réseau Virtuel (VMware)**

- Ouvrir **Virtual Network Editor** (en mode Administrateur).
- Configurer le **VMnet0** :
  - Sélectionner **Ponté (Bridged)**.
  - **Important :** Ne pas laisser sur _Automatique_. Sélectionner explicitement le contrôleur physique actif du PC hôte (ex: _Intel Wi-Fi_ ou _Realtek Ethernet_).
- Configurer le **VMnet8** :
  - Sélectionner **Hôte uniquement** (Host-only).
  - **Décocher** l'option _"Utiliser le service DHCP virtuel de VMware"_. C'est le serveur Windows qui gérera ce rôle.
---

**Étape 3 : Création et Paramétrage du Matériel de la VM pfSense**

- Créer une nouvelle machine virtuelle (Typique).
- Allouer les ressources minimales requises :
  - **RAM :** 2 Go
  - **CPU :** 2 vCPUs
  - **Disque :** 10 Go (Contrôleur SCSI)
- Configurer les interfaces réseau (**Crucial**) :
  - **Carte réseau 1 (WAN) :** Associer à **Personnalisé : VMnet0**.
  - **Carte réseau 2 (LAN) :** Cliquer sur _Add... > Network Adapter_, puis associer à **Personnalisé : VMnet8**.
- Dans l'onglet CD/DVD, monter l'ISO de l'installateur Netgate/pfSense et cocher _Connect at power on_.
---

**Étape 4 : Phase d'Installation de l'OS (FreeBSD)**

- Démarrer la VM. Accepter la licence (Copyright) et sélectionner **Install**.
- Sélectionner le système de fichier **ZFS** (recommandé) ou _UFS_, puis valider le partitionnement par défaut (_Auto ZFS > Stripe > Sélectionner le disque virtuel_).
- Procéder à l'installation. À la fin, lorsque l'assistant propose d'ouvrir un Shell, sélectionner **No**.
- Cliquer sur **Reboot**.
- **Action immédiate TSSR :** Au redémarrage de la VM, détacher l'ISO dans les options de VMware (décocher _Connected_) pour éviter de booter en boucle sur l'installateur.
---

**Étape 5 : Configuration Initiale en Console (Clavier QWERTY)**

À l'écran d'accueil textuel (Menu 0 à 16), l'interface LAN est souvent configurée par défaut sur 192.168.1.1. Il faut la réassigner dans le plan du Lab.

- Saisir le choix **2** (_Set interface(s) IP address_).
- Sélectionner l'interface **LAN** (généralement le choix 2 ou l'interface em1).
- Entrer la nouvelle adresse IPv4 : **10.8.0.2** _(Note QWERTY : le point se fait avec la touche . ou ; selon le terminal)_.
- Entrer le masque en notation CIDR : **24** (équivalent à 255.255.255.0).
- **Passerelle (Upstream gateway) :** Valider par **Entrée** (laisser vide, pfSense est sa propre passerelle LAN).
- **IPv6 :** Valider par **Entrée** (None).
- **Serveur DHCP interne :** À la question Do you want to enable the DHCP Server on LAN?, saisir **n** (No).
- **Protocole Web :** À la question Do you want to revert to HTTP?, saisir **n** (conserver le HTTPS).
---

**Étape 6 : Configuration Post-Installation via le WebGUI**

Depuis le navigateur du serveur **SRV-AD01** (configuré préalablement en 10.8.0.10 /24, passerelle 10.8.0.2), naviguer vers <https://10.8.0.2>. Saisir les identifiants d'usine : admin / pfsense.

L'assistant _Setup Wizard_ se lance automatiquement :

**1\. Paramètres Généraux (DNS globaux)**

- **Primary DNS Server :** 10.8.0.10 (Adresse de l'Active Directory local).
- **Secondary DNS Server :** 1.1.1.1 ou 8.8.8.8 (DNS public de secours).
- **DNS Override :** **Décocher** _"Allow DNS server list to be overridden by DHCP on WAN"_. _(Évite que la box internet n'écrase la priorité du DNS AD)_.

**2\. Configuration de l'interface WAN**

- **Selected Type :** **DHCP**.
- **RFC 1918 / Bogon Networks :** Tout en bas de la page, **décocher** _"Block private networks"_ et _"Block bogon networks"_. _(Indispensable en environnement de lab ou maquette, sinon pfSense bloque les flux provenant de la box domestique)_.

**3\. Finalisation**

- Passer les étapes LAN (déjà configuré en console).
- Modifier impérativement le mot de passe de l'administrateur système (admin).
- Cliquer sur **Reload**.
---

**Étape 7 : Interconnexion et Validation de l'Infrastructure**

Pour garantir le fonctionnement nominal de la chaîne de communication, l'architecture doit valider la cinématique suivante : Client >Serveur AD (DNS local) > pfSense (Redirigeur) >Internet.

\[ INTERNET \]

│

\[ Box Internet \]

│ (VMnet0 - Ponté)

\[ pfSense (WAN: DHCP) \]

\[ pfSense (LAN: 10.8.0.2) \]

│ (VMnet8 - Hôte uniquement)

├──────────────────────────────┐

│ │

\[ SRV-AD01 (10.8.0.10) \] \[ Clients Win10/Linux \]

\- DNS Principal (127.0.0.1) - IP: 10.8.0.X (DHCP)

\- Redirigeur -> 10.8.0.2 - Passerelle: 10.8.0.2

\- Serveur DHCP - DNS: 10.8.0.10

**Sur le Contrôleur de Domaine (Windows Server) :**

- Dans les propriétés de la carte IPv4 : Configuration DNS fixée sur 127.0.0.1 (pas de DNS secondaire).
- Dans la console **Gestionnaire DNS** : Propriétés du serveur > Onglet **Redirigeurs** (Forwarders) > Ajouter l'IP du pfSense : **10.8.0.2**. Ignorez l'erreur de résolution si elle apparaît (due au blocage ICMP/inverse initial).
- Dans la console **DHCP** : Vérifier que l'option d'étendue **003 Routeurs** distribue bien 10.8.0.2 et que l'option **006 Serveurs DNS** distribue 10.8.0.10.