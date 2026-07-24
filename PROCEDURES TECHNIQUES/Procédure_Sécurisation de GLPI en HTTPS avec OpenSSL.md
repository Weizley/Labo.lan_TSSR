**FICHE DE PROCEDURE : Sécurisation de GLPI en HTTPS avec OpenSSL**

**Objectif :** Chiffrer les flux HTTP (port 80) vers HTTPS (port 443) sur un serveur Debian hébergeant GLPI 10 à l'aide d'un certificat auto-signé.

**Étape 1 : Génération du certificat et de la clé privée (Le rôle d'OpenSSL)**

Utiliser l'outil **OpenSSL** pour créer simultanément la clé privée RSA (le secret du serveur) et le certificat public (contenant la clé publique qui sera envoyée aux navigateurs).

Bash

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/glpi.key -out /etc/ssl/certs/glpi.crt

- **Important :** Au niveau du _Common Name_, renseigner l'adresse IP du serveur Debian.

**Étape 2 : Configuration du serveur Web (Apache2)**

Il faut maintenant indiquer à Apache d'utiliser les "briques" de chiffrement générées par OpenSSL et adapter la racine du site (sécurité GLPI 10).

- Modifier le fichier de configuration SSL par défaut d'Apache :

Bash

sudo nano /etc/apache2/sites-available/default-ssl.conf

- Ajuster le DocumentRoot et renseigner les chemins vers ton certificat et ta clé OpenSSL :

Plaintext

DocumentRoot /var/www/html/glpi/public

&lt;Directory /var/www/html/glpi/public&gt;

Require all granted

RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-f

RewriteRule ^(.\*)\$ index.php \[QSA,L\]

&lt;/Directory&gt;

SSLEngine on

SSLCertificateFile /etc/ssl/certs/glpi.crt

SSLCertificateKeyFile /etc/ssl/private/glpi.key

- Sauvegarder et quitter (Ctrl+O, Ctrl+X).

**Étape 3 : Sécurisation des sessions dans PHP**

Pour empêcher que les cookies de session de GLPI ne transitent de manière non sécurisée.

- Ouvrir le fichier de configuration PHP (adapter 8.4 selon la version de ton système, et vérifier si tu utilises apache2 ou fpm) :

Bash

sudo nano /etc/php/8.4/apache2/php.ini

- Chercher (Ctrl+W) la directive suivante, enlever le point-virgule ; pour l'activer, et la passer à on :

Plaintext

session.cookie_secure = on

- Sauvegarder et quitter.

**Étape 4 : Activation des modules et redémarrage des services**

Activer les fonctionnalités requises dans Apache et appliquer l'ensemble des modifications.

Bash

\# 1. Activation du module SSL et du module de réécriture d'URL

sudo a2enmod ssl

sudo a2enmod rewrite

\# 2. Activation du site SSL (VirtualHost 443)

sudo a2ensite default-ssl.conf

\# 3. Validation de la syntaxe Apache

sudo apache2ctl configtest

\# 4. Redémarrage des services pour appliquer les changements

sudo systemctl restart apache2

**Étape 5 : Validation**

- Ouvrir un navigateur et saisir : <https://10.8.0.101>
- **Résultat attendu :** Une alerte de sécurité s'affiche. Après avoir accepté l'avertissement, l'interface de GLPI s'affiche et toutes les alertes de sécurité concernant le dossier /public et les cookies sécurisés ont disparu.