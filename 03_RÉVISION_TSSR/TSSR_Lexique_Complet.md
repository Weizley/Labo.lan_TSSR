## Lexique Complet TSSR
### 1\. Architecture et Fondations des Réseaux

**Modèles et Principes Fondamentaux**

**TCP/IP :** Le modèle TCP/IP (Transmission Control Protocol / Internet Protocol) est l'ensemble de règles qui permet aux ordinateurs de communiquer sur un réseau, et c'est la base même du fonctionnement d'Internet. Contrairement au modèle théorique OSI (qui a 7 couches), le TCP/IP est un modèle pratique divisé en 4 couches.  
Application (7) Données : Le contenu (HTTP, DNS…)  
Transport (4) SegmentPort : source/destination (TCP/UDP)  
Réseau (3) PaquetIP : source/destination  
Liaison (2) TrameAdresse : MAC source/destination  
Physique (1) BitsSignal : électrique/optique

**IP (Internet Protocol) :** s'occupe de l'adressage. Il met une étiquette avec l'adresse de l'expéditeur et du destinataire sur chaque paquet.

**TCP (Transmission Control Protocol) :** s'occupe de la connexion. Il vérifie que le fichier n'est pas corrompu. S'il manque un morceau, il demande au serveur de le renvoyer.

**UDP (User Datagram Protocol) :** c'est un protocole de transport de données non orienté connexion qui privilégie la vitesse à la fiabilité.

**OSI (Open Systems Interconnection) :** Modèle en 7 couches qui décrit comment les données transitent sur un réseau, de la couche physique à l'application.

**PDU (Protocol Data Unit) :** Nom des données selon la couche où elles se trouvent (segment, paquet, trame, bits).

**Encapsulation réseau :** L'encapsulation est le processus par lequel chaque couche du modèle réseau emballe les données de la couche supérieure en leur ajoutant ses propres informations (un en-tête, parfois un pied de trame), avant de les transmettre à la couche inférieure.

**La Hiérarchie des Réseaux**

**PAN (Personal Area Network) :** Réseau personnel à très courte portée (ex: Bluetooth).

**LAN (Local Area Network) :** Réseau local, typiquement un réseau d'entreprise ou domestique. C'est le périmètre où opèrent Ethernet, les switches et le DHCP.

**MAN (Metropolitan Area Network) :** Réseau à l'échelle d'une ville.

**WAN (Wide Area Network) :** Réseau étendu (Internet). C'est le monde extérieur au LAN, accessible via une IP publique et le routeur/NAT.

**VLAN (Virtual Local Area Network) :** Un VLAN est un réseau local virtuel il permet de segmenter logiquement un réseau physique en plusieurs réseaux distincts, sans avoir besoin de matériel supplémentaire.

---

### 2\. Protocoles et Équipements par Couches

**Couche 2 - Liaison (Commutation / Switch)**

**MAC (Media Access Control) :** Adresse physique unique sur 48 bits gravée en usine sur chaque carte réseau. Identifie un équipement sur le réseau local.

**ARP (Address Resolution Protocol) :** c'est un protocole réseau qui permet de faire le lien entre une adresse IP (niveau 3 du modèle OSI, logique) et une adresse MAC (niveau 2, physique/matériel) sur un réseau local.

**LLC (Logical Link Control) :** Sous-couche haute qui sert d'interface entre le matériel et les protocoles réseau (IPv4, IPv6).

**SVI (Switch Virtual Interface) :** Interface virtuelle (logique) configurée sur un commutateur Cisco et associée à un VLAN. Elle permet d'attribuer une adresse IP à ce VLAN pour assurer soit la gestion à distance de l'équipement (en Niveau 2), soit le routage inter-VLAN (en Niveau 3) en servant de passerelle par défaut.

**STP (Spanning-Tree Protocol) :** Le protocole Spanning Tree Protocol est un protocole de réseau qui a été conçu pour empêcher la formation de boucles dans les réseaux Ethernet commutés. Sans mécanisme de prévention, les paquets de données pourraient circuler en boucle indéfiniment.

**Switch :** Le rôle principal d'un switch dans un réseau local et de filtrer et d'acheminer le trafic vers le(s) bon(s) destinataire(s). Il achemine les données en se basant sur les adresses MAC des PC.  
Switch = couche 2 = MAC = connecte des machines dans un réseau

---

### Couche 3 - Réseau (Routage / Routeur)

**IP (Internet Protocol - Général) :** Protocole d'adressage logique qui permet d'identify les équipements et de router les paquets entre réseaux.

**IPv4 (Internet Protocol version 4 ) :** Version la plus utilisée d'IP. Adresse sur 32 bits, écrite en 4 octets décimaux séparés par des points (ex : 192.168.1.10).

**CIDR (Classless Inter-Domain Routing) :** Notation qui indique le nombre de bits réservés au réseau (ex : /24). Remplace la notation par classes.

**ICMP (Internet Control Message Protocol - Diagnostic) :** Protocole de diagnostic réseau utilisé par les commandes ping et traceroute.

**NAT (Network Address Translation) :** Mécanisme qui traduit des adresses IP privées en adresse IP publique (et inversement) pour permettre l'accès à Internet.

**SNAT (Source NAT) :** Variante du NAT qui modifie l'adresse IP source d'un paquet (cas classique : accès Internet depuis un réseau local).

**DNAT (Destination NAT) :** Variante du NAT qui modifie l'adresse IP destination. Utilisé pour la redirection de port (port forwarding).

**PAT (Port Address Translation) :** Aussi appelé NAT Overload. Permet à plusieurs machines de partager une seule IP publique grâce aux numéros de ports.

**Default Gateway (Passerelle par défaut) :** c'est l'adresse IP du routeur qui permet de sortir du LAN vers le WAN.

**Routeur :** Le rôle principal d'un routeur dans un réseau informatique est d'acheminer les données vers le(s) bon(s) destinataire(s). Il achemine les données en se basant sur les adresses IP.  
Routeur = couche 3 = IP = connecte des machines entre des réseaux

---

### Couche 7 - Configuration, Infrastructure & Services Application

**DHCP (Dynamic Host Configuration Protocol) :** Protocole qui attribue automatiquement une configuration réseau (IP, masque, passerelle, DNS) aux équipements qui se connectent.

**DORA (Discover, Offer, Request, Acknowledge) :** Les 4 étapes du processus DHCP pour qu'un client obtienne une adresse IP.

**DNS (Domain Name System) :** Système qui traduit les noms de domaine (google.com) en adresses IP. L'annuaire d'Internet.

**TLD (Top Level Domain) :** Domaine de premier niveau dans la hiérarchie DNS (ex : .com, .fr, .org).

**SNMP (Simple Network Management Protocol) :** protocole standard de l'industrie pour la surveillance et la gestion des équipements réseau.

**Un redirecteur DNS :** permet de transmettre les requêtes DNS qu'il ne peut pas résoudre localement vers d'autres serveurs DNS, généralement de niveau supérieur.

**Le rôle Active Directory Domain Service (ADDS) :** service qui permet la gestion des comptes utilisateurs (identités) et authentifications, des droits d'accès, etc. pour des ressources réseaux.

**Le rôle Domain Name Service (DNS - Windows) :** service qui permet de résoudre des noms d'hôtes en fonction d'adresses IP (et inversement), de centraliser des informations de noms, etc.

**Le rôle Dynamic Host Configuration Protocol (DHCP - Windows) :** service qui permet d'attribuer, aux périphériques réseaux, des paramètres TCP/IP (Adresse IP, masque, passerelle, IP du serveur DNS, etc.).

**Windows Deployment Services (WDS) :** outil de déploiement réseau développé par Microsoft pour installer et déployer des systèmes d'exploitation Windows sur plusieurs ordinateurs au sein d'un réseau local. C'est une solution souvent utilisée dans les entreprises ou les environnements informatiques où la gestion centralisée des installations de Windows est nécessaire

**BOOT PXE (Preboot eXecution Environment) :** technologie utilisée pour démarrer des ordinateurs via le réseau local plutôt que depuis un disque dur local ou un autre support de stockage. Elle permet à un ordinateur de récupérer automatiquement un système d'exploitation ou un environnement de démarrage via le réseau.

**Équipements et Connectivité Matérielle**

**NIC (Network Interface Card) :** La carte réseau physique (Ethernet ou Wi-Fi) de l'ordinateur.

**PoE (Power over Ethernet) :** technologie qui permet d'alimenter électriquement un appareil (caméra IP, borne Wi-Fi) directement via le câble RJ45.

**SFP (Small Form-factor Pluggable) :** les petits modules (transceivers) que l'on insère dans les switchs pour y connecter de la fibre optique.

---

### 3\. Administration Système et Services Active Directory

**Active Directory :** c'est est une base de données centralisée et un ensemble de services qui permettent de gérer les ressources d'un réseau informatique (utilisateurs, ordinateurs, imprimantes, serveurs). C'est le "répertoire" qui centralise la sécurité et l'administration d'un parc Windows.  
Les trois rôles piliers :  
• Identification & Authentification : Il vérifie l'identité des utilisateurs (identifiant/mot de passe) via le protocole Kerberos.  
• Autorisation : Il définit qui a accès à quoi (droits sur des dossiers, accès VPN, etc.).  
• Administration centralisée : Il permet de configurer des milliers de postes de travail en une seule action grâce aux GPO (Group Policy Objects).

**Structure logique (Active Directory) :** L'AD organise le réseau de manière hiérarchique pour simplifier la gestion :  
• Forêt : Le conteneur de plus haut niveau (regroupe tout l'annuaire).  
• Arbre : Un regroupement de domaines partageant un nom racine commun.  
• Domaine : L'unité de base (ex: entreprise.local).  
• Unité d'Organisation (OU) : Des dossiers pour ranger les utilisateurs et ordinateurs par service (ex: "Comptabilité", "RH").

**Le Contrôleur de Domaine :** c'est le serveur physique ou virtuel qui héberge et fait tourner les services Active Directory. Il centralise la gestion de la sécurité et des ressources.

**GPO - Group Policy Object :** Une stratégie de groupe (est un ensemble de règles permettant de gérer et de configurer, de manière centralisée, les paramètres d'ordinateurs et d'utilisateurs dans un environnement Windows. Elle agit comme un outil d'administration pour automatiser les tâches répétitives, standardiser les paramètres et sécuriser les postes de travail ainsi que les comptes utilisateurs.

**LDAP :** L'annuaire LDAP (Lightweight Directory Access Protocol) est un protocole utilisé pour accéder et gérer des informations d'annuaire, telles que des noms d'utilisateur, des mots de passe et d'autres données d'identification en centralisant les informations d'identification et d'accès des utilisateurs dans un répertoire facilement accessible et sécurisé.

---

### 4\. Cybersécurité et Réglementation

**Mécanismes de Filtrage, Proxy et Accès Sécurisés**

**VPN (Virtual Private Network) :** Crée un tunnel sécurisé et chiffré entre deux points à travers un réseau public (Internet).

**ACL (Access Control List) :** Liste de règles sur un routeur ou un pare-feu pour autoriser ou bloquer certains trafics.

**DMZ (Demilitarized Zone) :** Un sous-réseau isolé qui contient les serveurs exposés à Internet (web, mail) pour protéger le réseau interne de l'entreprise.

**SSL/TLS :** Le SSL (Secure Sockets Layer) et son successeur plus moderne, le TLS (Transport Layer Security), sont des protocoles de sécurité conçus pour instaurer une communication chiffrée entre un client (votre navigateur) et un serveur (un site web).

**OpenSSH (Open Secure Shell) :** est une suite d'outils informatiques permettant d'établir des communications chiffrées et sécurisées sur un réseau informatique, en utilisant le protocole SSH.

**DNSSec :** (Domain Name System Security Extensions) est une extension du DNS qui vise à sécuriser les enregistrements DNS en ajoutant des mécanismes de signature numérique pour protéger contre les attaques telles que la falsification des données DNS (DNS spoofing) et la redirection malveillante. Il garantit l'authenticité et l'intégrité des données DNS, renforçant ainsi la sécurité du système de noms de domaine.

**Proxy (Général & Filtrage) :** Un serveur proxy est un intermédiaire entre un ou plusieurs clients et un serveur distant. Il est utile pour filtrer les accès Internet, mettre en cache des contenus ou centraliser les logs. Un proxy classique doit être configuré sur chaque poste client (adresse, port) afin de pouvoir être utilisé.

**Proxy transparent :** Un proxy transparent est invisible pour le client : le trafic est redirigé automatiquement (via pare-feu ou routeur) sans configuration explicite sur le poste.

**Reverse Proxy :** Un reverse proxy se place côté serveur et il se positionne entre les clients Internet et les serveurs applicatifs (serveurs web). Il intercepte les connexions externes (frontend) avant de les rediriger vers un ou plusieurs serveurs internes (backends). Il offre plusieurs avantages comme : masquer l'architecture interne, répartir la charge, mettre en cache des contenus statiques et renforcer la sécurité.

**Gouvernance Cyber (Piliers et Outils)**

**DIC :** Disponibilité, Intégrité et Confidentialité sont les trois piliers de la sécurité des données.

**IDS :** Les systèmes de détection d'intrusions surveillent en continu le trafic réseau, les systèmes et les applications pour détecter les activités suspectes ou malveillantes.

**IPS :** Les systèmes de prévention des intrusions surveillent le trafic réseau à la recherche d'activités malveillantes. Les IPS sont capables de bloquer automatiquement le trafic suspect ou malveillant pour prévenir les attaques en temps réels.

**SIEM (Security Information and Event Management) :** est une plateforme centralisant et analysant les événements de sécurité provenant de l'ensemble du système d'information pour détecter les incidents.

**SOAR (Security Orchestration, Automation and Response) :** plateforme automatisant les processus de réponse aux incidents et orchestrant les différents outils de sécurité.

**Cadre Légal et Institutions Référentes**

**PSSI :** (Politique de Sécurité des Systèmes d'Information) est la stratégie de sécurité d'une entreprise. Cette stratégie est détaillée dans un document regroupant les règles de sécurité et le plan d'action, qui serviront à maintenir le niveau de sécurité de l'information.

**RGPD :** (Règlement Général sur la Protection des Données) Un règlement européen (loi) entré en vigueur en 2018. Il Encadre le traitement des données personnelles. Il donne aux citoyens le contrôle sur leurs données et responsabilise les entreprises (obligation de sécuriser les données, de collecter le strict minimum, de signaler les fuites, etc.).

**CNIL :** (Commission Nationale de l'Informatique et des Libertés). L'autorité administrative publique française (le "gendarme" des données). Veille au respect du RGPD et de la vie privée en France. Elle informe les professionnels, contrôle les systèmes informatiques, reçoit les plaintes des usagers et peut infliger de lourdes sanctions financières en cas de non-conformité.

**L'ANSSI :** (Agence Nationale de la Sécurité des Systèmes d'Information) L'autorité nationale française en matière de cybersécurité (rattachée au Secrétariat général de la défense et de la sécurité nationale). Sécurise les réseaux de l'État et des infrastructures critiques (hôpitaux, énergie, transports) Elle analyse les cybermenaces, coordonne la cyberdéfense en cas d'attaque majeure et émet des recommandations de sécurité.

---

### 5\. Stockage, Virtualisation et Haute Disponibilité

**Infrastructures de Stockage**

**SAN :** Storage Area Network est un réseau informatique distinct et haute performance dont l'unique but est de relier des serveurs à des baies de stockage

**iSCSI :** Internet Small Computer System Interface. Protocole réseau qui permet de transporter des commandes de stockage SCSI (mode bloc) à travers un réseau Ethernet standard (TCP/IP). Il permet à un serveur d'utiliser un disque dur distant situé sur un SAN comme s'il était branché en local.

**LUN :** (Logical Unit Number) : unité de stockage d'une baie de disques

**HBA (Host Bus Adapter) :** adaptateur de stockage qui (une fois configuré) permettra l'accès à un ou plusieurs espaces disques

**RAID :** Redundant Array of Independent Disks. Technologie de stockage combinant plusieurs disques durs physiques en une seule unité logique pour garantir la tolérance aux pannes (redondance) et/ou améliorer les performances.

**Environnement Virtuel (Hyperviseurs)**

**Hyperviseur de Type 1 (Bare Metal) :** Logiciel de virtualisation installé directement sur le matériel physique (la couche matérielle), sans système d'exploitation intermédiaire (ex: VMware ESXi, Proxmox VE). Il offre des performances et une sécurité maximales pour les serveurs de production.

**Hyperviseur de Type 2 (Hosted) :** Logiciel de virtualisation qui s'exécute comme une application au-dessus d'un système d'exploitation hôte existant (ex: VMware Workstation Pro, Oracle VirtualBox). Principalement utilisé pour les maquettes de techniciens et environnements de test.

**Nested Virtualization (Virtualisation imbriquée) :** Fonctionnalité permettant d'exécuter un hyperviseur à l'intérieur d'une machine virtuelle elle-même hébergée par un hyperviseur (ex: Proxmox dans VMware Workstation). Idéal pour les maquettes d'études.

**VHD / VMDK :** C'est un fichier virtuel sur l'hôte. C'est le choix par défaut pour 99% des VMs (souple, gère les snapshots et les migrations faciles).

**Pass-through / RDM :** C'est un accès direct à un disque physique par la VM. On ne l'utilise que pour des cas très spécifiques (clusters applicatifs pointus ou très grosses bases de données).

**SCVMM :** (System Center Virtual Machine Manager) : C'est une solution logicielle de Microsoft qui centralise la gestion, l'administration et le déploiement d'une infrastructure de virtualisation à l'échelle de l'entreprise. Là où le Gestionnaire Hyper-V administre les serveurs de manière isolée, SCVMM fédère l'ensemble des hôtes physiques (Hyper-V et VMware), des réseaux et des systèmes de stockage au sein d'une console unique.

**Haute Disponibilité et Résilience Économique**

**HA :** haute disponibilité est un objectif dans la gestion d'infrastructure. Cet objectif vise à garantir que les services et applications seront toujours disponibles même en cas de défaillance matérielle ou de problèmes logiciels.

**La répartition de la charge :** (load balancing) est une technique visant à distribuer de façon équitable la charge de travail entre plusieurs serveurs ou nœuds. L'objectif est d'optimiser l'utilisation des ressources pour garantir des performances élevées.

**PCA (Plan de Continuité d'Activités) :** vise à garantir la continuité de la productivité de l'entreprise en cas d'incidents majeurs, en appliquant un ensemble de mesures.

**PRA (Plan de Reprise d'Activités) :** se concentre sur l'application de processus de rétablissement rapide de la productivité après une interruption.

---

### 6\. Supervision et Services Généraux

**ICMP (Internet Control Message Protocol - Commande) :** Le protocole utilisé par la commande ping pour tester la connectivité.

**QoS (Quality of Service) :** est un ensemble de mécanismes réseau permettant d'identifier, de classifier et de prioriser certains flux de données critiques (comme la voix ou la vidéo) par rapport à d'autres (comme le téléchargement) afin de garantir les performances de bande passante, de latence et de gigue, même en cas de congestion du réseau.

**API :** application programming interface est une interface logicielle qui permet de connecter un logiciel ou un service à un autre logiciel ou service afin d'échanger des données et des fonctionnalités.

**PMAD :** Prise en main à distance, partage la session de l'utilisateur (interactif).

**RDP :** Remote Desktop Access, Ouvre une nouvelle session ou verrouille l'écran local.

**SLA :** Service Level Agreement. C'est un document contractuel qui définit la qualité de service attendue entre un prestataire (le service informatique ou un fournisseur externe) et un client (une direction métier ou une autre entreprise).

**GTI :** Garantie de Temps d'Intervention

**GLPI :** Gestionnaire Libre de Parc Informatique, est une solution open-source de gestion des services informatiques et de la gestion de parc informatique.

**BYOD (Bring Your Own Device) :** C'est une approche de travail qui permet aux employés d'utiliser leurs appareils personnels, tels que des smartphones, des tablettes ou des ordinateurs portables, pour accéder aux ressources informatiques de l'entreprise.

**VDI (Virtual Desktop Infrastructure) :** c'est une technologie qui permet de centraliser les bureaux virtuels d'une organisation sur des serveurs situés dans un data center. Au lieu de faire travailler chaque utilisateur sur un PC physique, la VDI héberge les bureaux virtuellement, permettant ainsi aux utilisateurs d'y accéder depuis n'importe quel appareil connecté à Internet.

---

### 7\. Téléphonie d'Entreprise et Communications Unifiées (VoIP/ToIP)

**Concepts Fondamentaux**

**VoIP (Voice over IP) :** Technologie qui permet de transmettre la voix numérisée sous forme de paquets de données IP sur un réseau informatique (LAN ou WAN/Internet).

**ToIP (Telephony over IP) :** Concept qui englobe toute l'infrastructure de téléphonie construite sur un réseau IP (incluant la VoIP, mais aussi les postes IP, la gestion des numéros, l'interconnexion aux opérateurs et les services comme la messagerie vocale).

**IPBX (Internet Protocol Private Branch Exchange) :** Autocommutateur téléphonique privé basé sur le protocole IP (matériel ou logiciel/VM). Il gère l'établissement des appels internes et externes, le routage, les extensions et les règles de messagerie au sein de l'entreprise (ex: 3CX, Asterisk).

**Centrex / Cloud PBX :** Externalisation du système de téléphonie (IPBX) chez un opérateur ou hébergeur Cloud. L'entreprise n'a aucun serveur de téléphonie physique en local, les téléphones se connectent directement via Internet.

---

### 8\. Protocoles et Codecs

**SIP (Session Initiation Protocol) :** Protocole de signalisation standard de niveau application (couche 7) utilisé pour établir, gérer et fermer les sessions multimédias (appels voix, vidéo, messagerie instantanée) dans un réseau IP. (Utilise généralement les ports UDP/TCP 5060 et 5061).

**RTP (Real-time Transport Protocol) :** Protocole de la couche transport utilisé pour acheminer le flux audio ou vidéo lui-même en temps réel, une fois la session établie par le protocole SIP. Il s'appuie sur UDP pour minimiser la latence.

**Trunk SIP (Lien SIP) :** Service fourni par un opérateur télécom permettant de raccorder l'IPBX de l'entreprise au réseau téléphonique public (RTC) via une connexion Internet, remplaçant ainsi les anciennes lignes analogiques ou Numéris (T0/T2).

**Codec audio (ex: G.711, G.729) :** Algorithme de compression/décompression utilisé pour numériser la voix. Le G.711 offre une excellente qualité sans compression (consomme ~64 kbps par appel), tandis que le G.729 compresse fortement la voix pour économiser la bande passante (~8 kbps).

**Équipements et Interconnexions**

**Passerelle VoIP (Gateway VoIP) :** Équipement matériel servant de pont pour convertir les signaux de la téléphonie traditionnelle (analogique ou lignes T0/T2 Numéris) en paquets IP (SIP/VoIP), et inversement.

**Softphone :** Logiciel installé sur un ordinateur, une tablette ou un smartphone qui simule un téléphone physique et permet de passer des appels via l'IPBX de l'entreprise.

---

### 9\. Compléments TSSR

**Continuité et Redondance**

**RTO (Recovery Time Objective) :** Durée maximale acceptable durant laquelle une infrastructure ou un service informatique peut rester indisponible après un sinistre ou une panne.

**RPO (Recovery Point Objective) :** Quantité maximale de données perdues acceptable mesurée en unités de temps. Détermine la fréquence minimale obligatoire des sauvegardes.

**DHCP Failover (Basculement DHCP) :** Mécanisme permettant à deux serveurs DHCP de partager la gestion d'une même plage d'adresses IP pour assurer la haute disponibilité de l'adressage automatique.

**DNS Split-Brain (Split-Horizon) :** Configuration DNS utilisant deux zones distinctes pour un même nom de domaine : une zone interne pour le LAN (IP privées) et une externe pour le WAN (IP publiques) 
pour des raisons de sécurité.

---

### 10\. Cybersécurité

**Kerberos :** Protocole d'authentification par tickets utilisé par Microsoft Active Directory pour valider de manière sécurisée l'identité des utilisateurs sans faire circuler les mots de passe sur le réseau.

**Syslog :** Protocole standard (port UDP/TCP 514) permettant de centraliser les journaux d'événements et logs générés par les serveurs, switchs, routeurs et pare-feux.

**Principe du moindre privilège :** Règle de sécurité consistant à attribuer à un utilisateur ou processus uniquement les droits strictement nécessaires à l'accomplissement de ses tâches, réduisant ainsi la surface d'attaque et les risques de compromission.

**Chiffrement Symétrique / Asymétrique :** Le chiffrement symétrique utilise une seule clé secrète pour chiffrer/déchiffrer (rapide, ex: AES). Le chiffrement asymétrique utilise une paire de clés (publique pour chiffrer, privée pour déchiffrer, ex: SSH, RSA).

**WPA3 (Wi-Fi Protected Access 3) :** Standard moderne de sécurité sans fil introduisant un chiffrement individualisé des données et une protection contre les attaques par force brute via le protocole SAE.

**APT (Advanced Persistent Threat) :** groupe d'attaquants sophistiqués bénéficiant de ressources importantes et menant des campagnes prolongées contre des cibles spécifiques.

**Ransomware :** est un logiciel malveillant qui chiffre les données d'une victime et exige le paiement d'une rançon pour fournir la clé de déchiffrement. Les variantes modernes combinent souvent chiffrement et vol de données pour exercer une double pression sur les victimes.

**WAF (Web Application Firewall) :** est un dispositif de sécurité conçu pour analyser, filtrer et bloquer le trafic HTTP/HTTPS à destination et en provenance d'une application web. Contrairement à un pare-feu traditionnel qui travaille au niveau réseau (Couches 3 et 4), le WAF opère au niveau de la couche Application (Couche 7). Il est généralement placé en frontal des serveurs web, souvent sous forme de Reverse Proxy.

**PAM (Privileged Access Management) :** ensemble des processus et technologies permettant de contrôler, surveiller et sécuriser les accès aux comptes disposant de privilèges élevés au sein d'un système d'information.

---

### 11\. Cloud

**On-Premise (Sur site) :** L'infrastructure informatique est entièrement hébergée et gérée localement dans les locaux de l'entreprise. L'entreprise est responsable de l'intégralité de la chaîne, depuis le matériel physique jusqu'aux systèmes d'exploitation, données et applications.

**IaaS (Infrastructure as a Service) :** Le fournisseur gère l'infrastructure physique. Le client reste maître de l'OS et des applications. L'entreprise cliente reste responsable de l'installation et de la gestion de l'OS, des configurations réseau logiques, des données et des applications.

**PaaS (Platform as a Service) :** Principalement dédié aux développeurs. Le fournisseur gère l'infrastructure, l'OS et les middlewares. L'entreprise cliente n'a pas à gérer l'administration système ni les mises à jour de l'infrastructure ; sa seule responsabilité réside dans le déploiement du code applicatif et la gestion des données.

**SaaS (Software as a Service) :** Le fournisseur cloud délivre une application logicielle complète et prête à l'emploi, généralement accessible directement via un navigateur web. le rôle de l'entreprise se limite à l'utilisation du service, à sa configuration de base et à la gestion des accès utilisateurs.