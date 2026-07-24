## FICHE DE PROCÉDURE: Déploiement d'un OS via WDS / PXE

**Environnement :** Maquette VMware Workstation

**Domaine cible :** labo.lan

**Objectif** : L'objectif de cette procédure est d'automatiser le déploiement de systèmes d'exploitation Windows 10 sur des postes clients vierges à travers le réseau.
Cette méthode s'appuie sur le mécanisme de **Boot PXE** et centralise les rôles nécessaires (AD DS, DNS, DHCP, WDS) sur un unique serveur d'infrastructure.

---

**Étape 1 : Architecture de la Maquette**

**Serveur d'infrastructure (ad01)**

- **Système :** Windows Server
- **Rôles :** AD DS, DNS, DHCP, WDS
- **Adresse IP :** 10.0.8.10 /24
- **Passerelle / DNS :** 10.0.8.2

**Poste Client**

- **Système :** Aucun (Machine vierge, disque virtuel non initialisé)
- **Mode d'amorce :** Network Boot / PXE ( firmware réseau )

**Environnement Réseau**

- **Commutateur virtuel :** Connecté sur un segment isolé (ex: _LAN Segment_ ou _VMnet_ dédié sous VMware) afin de confiner les flux DHCP de test et d'éviter toute perturbation sur le réseau de production ou la box internet.

---

**Étape 2 : Procédure Technique**

**Installation et Initialisation du rôle WDS**

- Sur AD01, ouvrir le **Gestionnaire de serveur** > **Ajouter des rôles et fonctionnalités**.
- Sélectionner et installer le rôle **Services de déploiement Windows (WDS)** en conservant les services de rôle par défaut (_Serveur de déploiement_ et _Serveur de transport_).
- Ouvrir la console **WDS** depuis les outils d'administration.
- Faire un clic droit sur le serveur AD01.labo.lan > **Configurer le serveur**.
- Choisir l'option **Intégré à Active Directory** et spécifier le dossier racine (ex: C:\\RemoteInstall).
- **Configuration de la cohabitation DHCP / WDS :** Puisque le service DHCP est hébergé sur la même machine (10.0.0.0/24), cocher impérativement les deux options suivantes pour éviter le conflit sur le port UDP 67 :
  - _Ne pas écouter sur les ports DHCP (port 67)_
  - _Configurer les options DHCP pour Proxy DHCP_
- À l'étape **Réponse PXE**, sélectionner _Répondre à tous les ordinateurs clients (connus et inconnus)_.

---

**Étape 3 : Gestion et Conversion des Images (.esd vers .wim)**

L'assistant graphique WDS requiert obligatoirement le format .wim. Si l'ISO officielle de Windows utilise un format compressé .esd, procéder à la conversion via PowerShell (en mode Administrateur).

PowerShell

\# 1. Analyser le fichier source pour identifier l'index de la version "Pro"

dism /Get-WimInfo /WimFile:D:\\sources\\install.esd

\# 2. Exporter l'image sélectionnée (ex: Index 6) vers un fichier d'installation .wim standard

dism /Export-Image /SourceImageFile:D:\\sources\\install.esd /SourceIndex:6 /DestinationImageFile:C:\\Temp\\install.wim /Compress:max /CheckIntegrity

**Importation dans la console WDS :**

- **Image de démarrage :** Clic droit sur _Images de démarrage_ > _Ajouter_. Sélectionner le fichier environnement de pré-installation **D:\\sources\\boot.wim**.
- **Image d'installation :** Clic droit sur _Images d'installation_ > _Ajouter un groupe d'images_ (Nom : Windows 10). Clic droit sur le groupe > _Ajouter_. Sélectionner le fichier fraîchement converti **C:\\Temp\\install.wim**.

**Étape 4 : Phase d'Amorce et Déploiement Client**

---

- S'assurer du raccordement de la VM cliente sur le segment réseau de AD01.
- Démarrer la VM cliente. La carte réseau effectue sa requête de découverte et obtient une configuration IP depuis l'étendue DHCP du serveur 10.0.8.10.
- Dès l'apparition de l'invite à l'écran, appuyer immédiatement sur la touche **F12** pour valider le démarrage PXE.
- La VM télécharge le fichier de boot via TFTP et charge l'environnement Windows PE.
- À l'invite de connexion, renseigner le compte administrateur du domaine (ex: LABO\\Administrateur) pour monter le partage réseau des images.
- Sélectionner l'OS Windows 10 Pro, valider le partitionnement du disque virtuel et laisser l'installation s'exécuter.
- **Point de vigilance au reboot :** Lors du premier redémarrage automatique de la machine cliente, **ne pas appuyer sur F12**. Laisser la machine booter de manière classique sur son disque dur local pour finaliser l'assistant de configuration initial (OOBE).