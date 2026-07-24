**FICHE DE PROCÉDURE: Mise en œuvre et déploiement de postes via FOG**

**Objectif :** Automatiser le déploiement d'un système d'exploitation Windows 10 à l'aide de la solution Open Source FOG Project, en s'appuyant sur l'infrastructure existante (Active Directory, DNS, DHCP).

**Étape 1 : Contexte et architecture du lab**

L'environnement de test est segmenté sur le commutateur virtuel privé **VMnet8** (DHCP local VMware désactivé). Il est composé des machines suivantes :

- **SRV-AD01 (Windows Server) :** 10.8.0.10 - Contrôleur de domaine, serveur DNS et unique serveur DHCP du segment.
- **SRV-FOG (Debian 13) :** 10.8.0.105 - Serveur de gestion et de stockage FOG (NFS, TFTP, Apache/PHP, MariaDB).
- **MASTER-W10 (Windows 10) :** Machine de référence destinée à la capture de l'image.
- **PC-CLIENT-01 (Vierge) :** Machine cible destinée à recevoir l'image déployée.

**Étape 2 : Configuration et installation du serveur FOG**

**2.1. Téléchargement des sources**

Connexion SSH ou locale sur la machine SRV-FOG :

Bash

sudo apt update && sudo apt install git -y

cd /opt

sudo git clone <https://github.com/FOGProject/fogproject.git>

cd fogproject/bin

**2.2. Exécution du script d'installation**

Bash

sudo ./installfog.sh

**Réponses indispensables aux invites du script (Mode aligné sur l'infrastructure AD01) :**

- _Installation type :_ N (Normal Server)
- _IP Address :_ 10.8.0.105 (Valider la détection)
- _Interface :_ ens32 (Valider la détection)
- _Router Address (Gateway) :_ 10.8.0.2
- _DNS Server Address :_ 10.8.0.10 (Adresse IP de AD01)
- _Use FOG for DHCP service :_ N (**IMPÉRATIF :** Le rôle DHCP doit rester l'exclusivité d'AD01)
- _HTTPS Support :_ N (Option désactivée pour simplifier la chaîne PXE iPXE/UEFI en environnement de test)

**2.3. Initialisation de la base de données**

Lorsque le script marque une pause :

- Naviguer sur <http://10.8.0.105/fog/management>.
- Cliquer sur **Install/Update Now** pour initialiser le schéma MariaDB.
- Retourner sur le terminal Linux et appuyer sur Entrée pour finaliser l'installation.

**Étape 3 : Configuration du serveur DHCP Windows (SRV-AD01)**

Afin de rediriger les requêtes d'amorçage réseau vers le serveur FOG, les options d'étendue DHCP doivent être paramétrées sur SRV-AD01.

- Ouvrir la console **DHCP** (dhcpmgmt.msc).
- Naviguer dans **Étendue \[10.8.0.0\]** >**Options d'étendue**.
- **Nettoyage préalable :** Supprimer impérativement l'**Option 060 (PXEClient)** héritée d'anciennes infrastructures (ex: WDS) afin d'éviter tout conflit de redirection.
- Ajouter/Vérifier les options suivantes :
  - **Option 066 (Nom d'hôte du serveur de démarrage) :** 10.8.0.105 (IP de SRV-FOG).
  - **Option 067 (Nom du fichier de démarrage) :** ipxe.efi (Adapté aux micrologiciels cibles configurés en mode **UEFI**).

**Étape 4 : Préparation et généralisation du master (windows 10)**

**4.1. Optimisations de l'OS**

Sur la machine MASTER-W10 :

- Installer les applications globales requises et exécuter les mises à jour de sécurité.
- Réaliser un nettoyage de disque approfondi pour réduire le volume de l'image.
- Exécuter un Sysrep
- Valider. La machine s'éteint. **Ne pas rallumer la machine sur son disque dur.**

_Note : Réaliser un Snapshot sous VMware Workstation à cette étape pour faciliter les rollbacks._

**Étape 5 : Capture de l'image master via l'interface web FOG**

**5.1. Création de la définition de l'image**

- Aller sur l'interface FOG >Onglet **Images** > **Create New Image**.
- _Image Name :_ Win10-Master-TSSR
- _Image Type :_ **Single Disk - Resizable** _(Permet à FOG d'ajuster dynamiquement la taille des partitions à la baisse lors des déploiements sur des disques cibles plus petits)._

**5.2. Enregistrement du Host Master**

- Onglet **Hosts** \> **Create New Host**.
- _Host Name :_ Master-W10
- _Host MAC Address :_ Renseigner précisément la clé MAC de la VM
- _Host Image :_ Assigner Win10-Master

**5.3. Planification et exécution de la capture**

- Sur la fiche de Master-W10, naviguer dans **Basic Tasks** >**Capture**. Valider la création de la tâche.
- **Règle d'exploitation :** S'assurer que la tâche est visible et active dans l'onglet global **Tasks** (icône de liste). En cas de boot manqué de la VM, la tâche doit être recréée car elle s'annule automatiquement.
- Démarrer la VM MASTER-W10 et forcer le boot **PXE/Network** (via F12 ou l'option _Power On to Firmware_ de VMware).
- Le processus s'exécute automatiquement via l'utilitaire **Partclone** (liaison de stockage NFS). À la fin du transfert, la machine s'éteint.

**Étape 6 : Déploiement automatisé (méthode par enregistrement)**

Cette méthode est privilégiée en production pour maîtriser le nommage des machines clientes en amont.

- Récupérer l'adresse MAC de la nouvelle machine virtuelle vierge (PC-CLIENT-01).
- Dans l'interface Web FOG >**Hosts** >**Create New Host**.
- _Host Name :_ PC-CLIENT-01
- _Host MAC Address :_ Saisir l'adresse MAC de la VM cible.
- _Host Image :_ Sélectionner l'image capturée Win10-Master-TSSR.
- Cliquer sur **Add**, puis basculer dans l'onglet **Basic Tasks** >**Deploy**. Valider.
- Démarrer la machine PC-CLIENT-01 en mode **PXE / Réseau**.
- L'utilitaire **Partclone** intercepte le démarrage et déploie le système d'exploitation.

**Étape 7 : Vérifications**

Au redémarrage post-déploiement, le système Windows 10 exécute sa phase de spécialisation (générée par le Sysprep).

- Finaliser l'assistant de première configuration OOBE.
- Vérifier la bonne configuration réseau de la machine (attribution d'une IP dynamique cohérente par AD01).
- Modifier le nom de l'ordinateur en PC-CLIENT-01 et procéder à la **jonction au domaine Active Directory**.
- **Validation finale :** S'assurer de la possibilité d'ouvrir une session utilisateur du domaine et valider la présence de l'objet ordinateur dans le conteneur _Computers_ d'Active Directory sur SRV-AD01.