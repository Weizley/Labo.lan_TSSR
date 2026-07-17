**PROCEDURE TECHNIQUE : Mise en œuvre d'un Cluster Proxmox VE en Haute Disponibilité (HA) avec Arbitrage et Stockage Partagé**

**Objectif :** Créer une infrastructure virtualisée redondante (Cluster de basculement) permettant la migration à chaud (Live Migration) et la reprise après sinistre (Failover) de machines virtuelles.

**1\. Présentation de l'Architecture**

L'objectif de cette procédure est de mettre en place un cluster à haute disponibilité résilient à la panne d'un hyperviseur, tout en évitant le phénomène de _Split-Brain_ propre aux architectures à deux nœuds.

**Éléments de l'infrastructure :**

- **pve1** (Hyperviseur principal) : Proxmox VE
- **pve2** (Hyperviseur secondaire) : Proxmox VE
- **srv-infra** (10.8.0.101) : VM Linux (Debian) jouant le double rôle de **QDevice** (arbitre de Quorum) et de **Serveur NFS** (stockage partagé).

**2\. Prérequis Systèmes & Réseau**

- Les deux nœuds Proxmox doivent être configurés avec le dépôt **No-Subscription** (gratuit) pour permettre l'installation des paquets nécessaires (corosync-qdevice).
- La virtualisation imbriquée (_Nested Virtualization_) doit être activée sur les VM Proxmox au niveau de VMware.
- Toutes les machines doivent être dans le même plan d'adressage IP (Réseau 10.8.0.0/24) et s'interconnecter sans pare-feu bloquant.

**3\. Étape 1 : Création du Cluster Proxmox**

- Sur l'interface Web de **pve1**, aller dans **Datacenter -> Cluster**, puis cliquer sur **Create Cluster**.
- Nommer le cluster (ex: Cluster-TSSR) et valider.
- Une fois créé, cliquer sur **Join Information** et copier le token d'identification.
- Sur l'interface Web de **pve2**, aller dans **Datacenter -> Cluster**, cliquer sur **Join Cluster**, coller le token et renseigner le mot de passe root de pve1.
- _Vérification :_ Les deux nœuds doivent apparaître en vert dans l'arborescence gauche.

**4\. Étape 2 : Configuration du Stockage Partagé (NFS)**

Le mécanisme de basculement HA nécessite un stockage centralisé pour que les deux nœuds accèdent au disque dur de la VM.

**Sur la VM Linux (10.8.0.101) :**

Bash

\# Installation du serveur NFS

sudo apt update && sudo apt install nfs-kernel-server -y

\# Création et attribution des droits du répertoire partagé

sudo mkdir -p /mnt/proxmox-shared

sudo chown -R nobody:nogroup /mnt/proxmox-shared

sudo chmod 777 /mnt/proxmox-shared

\# Déclaration de l'export réseau dans le fichier d'exports

echo "/mnt/proxmox-shared 10.8.0.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports

\# Redémarrage du service

sudo systemctl restart nfs-kernel-server

**Sur l'interface Proxmox (Datacenter) :**

- Aller dans **Datacenter -> Storage -> Add -> NFS**.
- **ID :** nfs-partage | **Server :** 10.8.0.101 | **Export :** /mnt/proxmox-shared.
- **Content :** Sélectionner _Disk image_ et _Container_. Cliquer sur **Add**.
- _Migration du disque de la VM :_ Aller sur la VM -> **Hardware** -> Sélectionner le disque -> **Disk Action -> Move Storage** -> Choisir nfs-partage (Cocher _Delete source_).

**5\. Étape 3 : Déploiement de l'Arbitre de Quorum (QDevice)**

Pour obtenir un nombre impair de votes (\$2 \\text{ nœuds PVE} + 1 \\text{ arbitre} = 3 \\text{ votes}\$) et maintenir la majorité absolue (Quorum) à 2 voix en cas de perte d'un nœud.

**Sur la VM Linux (10.8.0.101) :**

Bash

\# Installation du démon de quorum réseau

sudo apt install corosync-qnetd -y

_Note : Veiller à ce que le fichier /etc/ssh/sshd_config autorise temporairement l'accès SSH en Root (PermitRootLogin yes) pour l'échange de clés._

**Sur les nœuds Proxmox (pve1 et pve2) :**

Bash

\# Installation du client qdevice

apt update && apt install corosync-qdevice -y

**Initialisation depuis le nœud maître (pve1) :**

Bash

\# Liaison du cluster à l'arbitre externe

pvecm qdevice setup 10.8.0.101

_Saisir 'yes' pour valider l'empreinte SSH, puis entrer le mot de passe root de la machine Linux._

**Ajout de la VM dans les ressources HA :**

- Sur l'interface Web, aller dans **Datacenter -> HA -> Resources -> Add**.
- Sélectionner le **VMID** de la machine virtuelle cible.
- Définir le **Requested State** sur **Started**.
- Valider. Une icône de recyclage apparaît sur la VM, confirmant sa prise en charge par le gestionnaire HA.

**7\. Procédure de Recette (Validation des Tests)**

| **Type de Test**            | **Action**                                                      | **Résultat Attendu**                                                                                                                       | **Statut** |
| --------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ---------- |
| **Migration à chaud**       | Clic droit sur la VM -> _Migrate_ de pve1 vers pve2 (à chaud).  | La VM change d'hôte sans aucune coupure réseau (0 ping perdu).                                                                             | **OK**     |
| **Bascule HA (Crash-Test)** | Coupure électrique brutale (_Power Off_) de pve1 depuis VMware. | Le QDevice maintient le quorum. pve2 détecte la perte, attend la fin du cycle de sécurité (~60-120s) puis redémarre automatiquement la VM. | **OK**     |
