## FICHE DE PROCÉDURE : Mise en œuvre d'un Cluster Hyper-V Haute Disponibilité avec Stockage iSCSI

**Objectif :** Créer une infrastructure virtualisée redondante (Cluster de basculement) permettant la migration à chaud (Live Migration) et la reprise après sinistre (Failover) de machines virtuelles.

**Environnement cible :** 1 Contrôleur de domaine/Serveur de stockage (SRV-AD01), 2 Nœuds Hyper-V (SRV-HyperV1 et SRV-HyperV2).

**Version :** v2.0 (Intégration du cloisonnement des flux réseau)

---

**Étape 1 : Préparation du Stockage iSCSI (sur SRV-AD01)**

L'assistant graphique Windows pouvant présenter des latences de rafraîchissement, la méthode PowerShell est privilégiée pour garantir la création des disques.

- Sur le second disque physique de SRV-AD01, créez un volume NTFS configuré avec une lettre de lecteur (ex: E:).
- Ouvrez **PowerShell en mode Administrateur** et exécutez les commandes suivantes pour créer le dossier et les disques virtuels iSCSI (.vhdx) :

PowerShell

\# Création du dossier racine

New-Item -ItemType Directory -Path "E:\\iSCSIVirtualDisks"

\# Création du disque de Témoin (Quorum)

New-IscsiVirtualDisk -Path "E:\\iSCSIVirtualDisks\\Disque-Quorum.vhdx" -Size 1GB

\# Création du disque pour les Machines Virtuelles (CSV)

New-IscsiVirtualDisk -Path "E:\\iSCSIVirtualDisks\\Disque-VMs.vhdx" -Size 19GB

- Via le **Gestionnaire de serveur** -> **Services de fichiers et de stockage** -> **iSCSI**, créez une cible (Target) iSCSI et associez-y les **IQN** (identifiants iSCSI) de vos deux nœuds SRV-HyperV1 et SRV-HyperV2 pour leur autoriser l'accès simultané aux deux disques.

---

**Étape 2 : Configuration et Cloisonnement des Réseaux (Sur chaque Nœud)**

Pour garantir la performance et la sécurité du cluster, il est indispensable d'isoler les flux (production, stockage et inter-nœuds).

**1\. Renommage des cartes dans Windows**

Sur **chaque nœud** (SRV-HyperV1 et SRV-HyperV2), ouvrez les connexions réseau (ncpa.cpl) et renommez vos trois cartes réseau physiques ainsi :

- **Ethernet** : Dédiée à la gestion administrative du serveur, aux flux Active Directory et à l'accès au réseau de l'entreprise.
- **Stockage** : Dédiée exclusivement au trafic de stockage entre le nœud et le serveur de stockage (SRV-AD01).
- **Heartbeat** : Dédiée aux communications internes du cluster (signaux de vie inter-nœuds et flux de Live Migration).

**2\. Configuration du plan d'adressage IP**

Configurez les propriétés TCP/IPv4 de vos cartes selon la matrice stricte ci-dessous.

- _Règle d'or TSSR :_ **Seule la carte LAN-Prod doit posséder une Passerelle par défaut et des serveurs DNS.** Les cartes SAN-iSCSI et Heartbeat ne doivent avoir **que** l'adresse IP et le masque (pas de passerelle, pas de DNS), et l'IPv6 doit y être décoché.

| **Carte Réseau** | **IP Nœud 1 (SRV-HyperV1)** | **IP Nœud 2 (SRV-HyperV2)** | **Masque de sous-réseau** | **Spécificités de configuration**            |
| ---------------- | --------------------------- | --------------------------- | ------------------------- | -------------------------------------------- |
| **Ethernet**     | _10.8.0.102_                | _10.8.0.104_                | 255.255.255.0             | Avec Passerelle + DNS pointant vers SRV-AD01 |
| **Stockage**     | 192.168.10.1                | 192.168.10.2                | 255.255.255.0             | **Sans** Passerelle, **Sans** DNS            |
| **Heartbeat**    | 10.0.0.1                    | 10.0.0.2                    | 255.255.255.0             | **Sans** Passerelle, **Sans** DNS            |

---

**Étape 3 : Connexion et Initialisation du Stockage (sur les Nœuds)**

**Sur le Nœud 1 (SRV-HyperV1) :**

- Lancez l'**Initiateur iSCSI**, renseignez l'IP de stockage de SRV-AD01 et connectez-vous à la cible.
- Ouvrez la **Gestion des disques** (diskmgmt.msc).
- Passez les deux nouveaux disques détectés **En ligne**, initialisez-les en **GPT**.
- Formatez-les en **NTFS** avec des noms explicites :
  - Le disque de 1 Go -> Nommé Quorum
  - Le disque de 19 Go -> Nommé Stockage-VMs

**Sur le Nœud 2 (SRV-HyperV2) :**

- Connectez l'**Initiateur iSCSI** à la même cible.
- Ouvrez la **Gestion des disques** et passez simplement les deux disques **En ligne** (les volumes NTFS créés sur le Nœud 1 seront automatiquement reconnus).

---

**Étape 4 : Validation et Création du Cluster**

- Sur l'un des nœuds, ouvrez le **Gestionnaire du trafic de basculement**.
- Cliquez sur **Valider la configuration...**, ajoutez vos deux nœuds et exécutez tous les tests.

**Note:** Le rapport doit être vierge de toute erreur rouge (les avertissements jaunes sur le réseau sont tolérés en environnement de labo).

- Cliquez sur **Créer le cluster** :
  - Nommez le cluster (ex: CLUSTER-HYPERV).
  - _Attention :_ Décochez l'option _"Ajouter la totalité du stockage éligible"_ pour mapper les disques manuellement et éviter les conflits d'attribution.

---

**Étape 5 : Résolution de l'erreur d'inscription DNS (CNO)**

Si le nœud affiche l'erreur d'accès refusé pour la zone DNS (ex: labo.lan) :

- Connectez-vous sur le contrôleur de domaine et ouvrez la console **DNS** (dnsmgmt.msc).
- Dans la zone de recherche directe labo.lan, localisez l'enregistrement **A** correspondant au nom du cluster.
- Faites un Clic droit -> **Propriétés** -> Onglet **Sécurité**.
- Cliquez sur **Ajouter**, modifiez le bouton **Types d'objets...** pour cocher **Ordinateurs**.
- Saisissez le nom de l'objet ordinateur du cluster (**CNO**), validez et accordez-lui le **Plein contrôle**.
- Dans le Gestionnaire de cluster, faites un clic droit sur la ressource de nom de réseau -> **Plus d'actions** -> **Inscrire DNS** pour forcer la mise à jour.

---

**Étape 6 : Configuration du Quorum, du CSV et Rôles Réseau**

**1\. Configuration du Témoin de disque (Quorum) :**

- Clic droit sur le **nom du cluster** -> **Plus d'actions** -> **Configurer les paramètres de quorum du cluster...**
- Sélectionnez **Sélectionner le témoin de quorum** (Option avancée) -> **Configurer un témoin de disque**.
- Cochez la case correspondant au disque de **1 Go**. À la fin de l'assistant, son statut devient réglementairement **"Disque témoin"**.

**2\. Configuration de l'Espace Partagé (CSV) :**

- Allez dans **Stockage** -> **Disques**.
- Faites un clic droit sur le disque de **19 Go** (qui est en _Stockage disponible_) et sélectionnez **Ajouter aux volumes partagés de cluster**.
- Le disque bascule sous le statut **Volume partagé de cluster** et devient accessible sur les deux nœuds via le chemin universel : C:\\ClusterStorage\\Volume1.

**3\. Affectation des rôles dans le Gestionnaire de Cluster :**

- Déroulez l'onglet **Réseaux** du cluster. Le service WSFC a détecté automatiquement trois réseaux basés sur vos plages IP.
- Identifiez-les et renommez-les pour correspondre à vos cartes réseau physiques (Réseau Ethernet, Réseau Heartbeat, Réseau Stockage).
- Faites un clic droit sur chaque réseau -> **Propriétés** pour fixer la politique du cluster :
  - **Réseau Ethernet :** Cochez _"Autoriser la communication réseau du cluster"_ **ET** _"Autoriser les clients à se connecter"_.
  - **Réseau Heartbeat :** Cochez _"Autoriser la communication réseau du cluster"_ et **décochez** l'accès client.
  - **Réseau Stockage :** Cochez **"Ne pas autoriser la communication réseau du cluster sur ce réseau"** (ce flux est réservé au protocole iSCSI).

**4\. Optimisation de la Migration Dynamique (Live Migration) :**

- Dans l'onglet **Réseaux** du cluster, cliquez sur **Paramètres de migration dynamique** (dans le volet Actions à droite).
- Décochez le réseau LAN et **cochez uniquement le Réseau Heartbeat**. Le transfert de la RAM des VMs se fera exclusivement sur ce segment privé.

---

**Étape 7 : Déploiement et Tests de Haute Disponibilité**

**Création de la VM :**

- Dans le Gestionnaire de cluster, clic droit sur **Rôles** -> **Configurer le rôle...** -> Choisissez **Machine virtuelle**.
- Lors de la configuration, modifiez impérativement l'emplacement des fichiers pour pointer vers l'espace CSV : C:\\ClusterStorage\\Volume1\\.
- Pour valider la mécanique pure du cluster sans dépendance réseau tierce, ne connectez pas de commutateur virtuel (carte réseau sur "Non connecté").
- Démarrez la VM.

**Test de Maintenance (Migration dynamique / Live Migration) :**

- Clic droit sur la VM en cours d'exécution -> **Déplacer** -> **Migration dynamique** -> **Sélectionner le nœud...**
- Sélectionnez le second nœud. La VM bascule d'un hôte physique à l'autre à chaud, sans interruption de service.

**Test de Tolérance aux Pannes (Failover) :**

- Repérez le nœud propriétaire actuel de la VM.
- Depuis l'hyperviseur physique (ex: VMware Workstation), effectuez un **Power Off** brutal de ce nœud pour simuler une panne électrique.
- Connectez-vous sur le nœud survivant : le cluster détecte la rupture de Heartbeat, s'appuie sur le vote du disque de Quorum pour conserver la majorité, s'approprie le stockage CSV et redémarre automatiquement la machine virtuelle.