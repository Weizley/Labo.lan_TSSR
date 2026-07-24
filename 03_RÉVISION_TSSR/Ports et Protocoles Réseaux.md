## Ports et Protocoles Réseaux

En réseau, si l'adresse IP permet d'identifier une machine (comme une adresse postale identifie un immeuble), le numéro de port permet d'identifier l'application ou le service spécifique à qui distribuer les données (comme un numéro de bureau ou de boîte aux lettres dans cet immeuble).

---

**1\. Services d'Infrastructure Réseau**

| **Port**    | **Protocole** | **Service / Nom** | **Description & Rôle TSSR**                                                                                                                  |
| ----------- | ------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **53**      | UDP / TCP     | DNS               | Traduit les noms de domaine en IP. Le TCP est utilisé pour les réplications/transferts de zone.                                              |
| **67 / 68** | UDP           | DHCP              | 67 côté serveur, 68 côté client. Assure l'attribution dynamique des configurations IP.                                                       |
| **123**     | UDP           | NTP               | Network Time Protocol. Synchronisation ultra-précise de l'horloge sur le réseau (indispensable pour Active Directory, Kerberos et les logs). |

---

**2\. Administration, Accès à Distance & Supervision**

| **Port**        | **Protocole** | **Service / Nom** | **Description & Rôle TSSR**                                                                                                                                 |
| --------------- | ------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **22**          | TCP           | SSH               | Accès sécurisé en ligne de commande. Remplace Telnet (23) qui circulait en clair.                                                                           |
| **514**         | UDP / TCP     | Syslog            | Centralisation des journaux d'événements et logs système des serveurs, pare-feux et switchs vers un serveur SIEM ou Syslog (crucial pour la cybersécurité). |
| **3389**        | TCP           | RDP               | Remote Desktop Protocol. Prise en main graphique des environnements Windows Server.                                                                         |
| **5900**        | TCP           | VNC               | Contrôle à distance graphique multiplateforme.                                                                                                              |
| **8022 / 8443** | TCP           | HTTPS Admin       | Fréquemment assignés aux interfaces d'administration web (pfSense, Proxmox, VMware).                                                                        |
| **161 / 162**   | UDP           | SNMP              | Supervision de l'état de santé des équipements réseaux (Zabbix, Centreon).                                                                                  |

---

**3\. Services Web et Bases de Données**

| **Port** | **Protocole** | **Service / Nom** | **Description & Rôle TSSR**                                        |
| -------- | ------------- | ----------------- | ------------------------------------------------------------------ |
| **80**   | TCP           | HTTP              | Flux web standard non sécurisé.                                    |
| **443**  | TCP           | HTTPS             | Flux web chiffré via SSL/TLS. Standard incontournable.             |
| **1433** | TCP           | Microsoft SQL     | Port par défaut du SGBD Microsoft SQL Server.                      |
| **3306** | TCP           | MySQL / MariaDB   | Port par défaut des bases de données de l'écosystème Linux (LAMP). |
| **5432** | TCP           | PostgreSQL        | Système de gestion de base de données relationnelle open-source.   |

---

**4\. Partage de Fichiers et Stockage**

| **Port**    | **Protocole** | **Service / Nom** | **Description & Rôle TSSR**                                                        |
| ----------- | ------------- | ----------------- | ---------------------------------------------------------------------------------- |
| **20 / 21** | TCP           | FTP               | 21 pour les commandes, 20 pour la data. Non sécurisé.                              |
| **22**      | TCP           | SFTP              | Transfert de fichiers sécurisé encapsulé dans un tunnel SSH.                       |
| **445**     | TCP           | SMB               | Partage de fichiers/imprimantes Windows (remplace le port historique NetBIOS 139). |
| **2049**    | TCP / UDP     | NFS               | Network File System. Partage de fichiers natif et optimisé sous Linux/Unix.        |

---

**5\. Messagerie Électronique**

| **Port**      | **Protocole** | **Service / Nom**  | **Description & Rôle TSSR**                                               |
| ------------- | ------------- | ------------------ | ------------------------------------------------------------------------- |
| **25**        | TCP           | SMTP               | Transfert de courriels de serveur à serveur.                              |
| **465 / 587** | TCP           | SMTPS / Submission | Envoi sécurisé de courriels depuis un client de messagerie (ex: Outlook). |
| **110**       | TCP           | POP3               | Récupération des mails avec téléchargement local (obsolète).              |
| **995**       | TCP           | POP3S              | Version sécurisée et chiffrée de POP3.                                    |
| **143**       | TCP           | IMAP               | Consultation et synchronisation des e-mails directement sur le serveur.   |
| **993**       | TCP           | IMAPS              | Version chiffrée d'IMAP (fortement recommandée).                          |

---

**6\. Annuaires d'Entreprise & Authentification**

| **Port** | **Protocole** | **Service / Nom** | **Description & Rôle TSSR**                                                      |
| -------- | ------------- | ----------------- | -------------------------------------------------------------------------------- |
| **389**  | TCP / UDP     | LDAP              | Requêtes et authentification sur un annuaire centralisé (Active Directory).      |
| **636**  | TCP           | LDAPS             | LDAP sécurisé via SSL/TLS.                                                       |
| **88**   | TCP / UDP     | Kerberos          | Gestion de l'authentification par tickets au sein d'un domaine Active Directory. |

---

Principe du moindre privilège : Par défaut, sur un pare-feu d'entreprise ou sur les règles système (iptables/Windows Firewall), tout doit être FERMÉ (Deny All). Le rôle du technicien est d'ouvrir uniquement les ports strictement nécessaires à la production et de privilégier systématiquement les versions chiffrées (ex: 443 au lieu de 80, 22 au lieu de 23, 993 au lieu de 143).  
<br/>Analyse de flux : L'utilisation d'outils comme Nmap permet de scanner les ports ouverts d'une machine afin de cartographier la surface d'attaque et corriger les failles potentielles.

Focus Syslog (514) & NTP (123) : En supervision et cybersécurité, il est indispensable que toutes les machines soient à la même heure (NTP) afin de pouvoir corréler chronologiquement les logs envoyés (Syslog) vers un serveur central lors d'une analyse forensique suite à un incident.