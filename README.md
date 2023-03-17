# ProjetTuteur
La mise-en-place d’un réseau d’entreprise sécurisé avec des outils open source


# Routage

### Matériel requis :
  - Raspberry pi 4B 2Go ou plus
  - Microsd 16 Go ou plus + adaptateur microSD --> USB
  - Adaptateur USB --> RJ45 compatible avec Debian
  - Un PC ou un mac connecté à Internet
  
 ### Installation du système d’exploitation :
 
  1. Téléchargez et installez Raspberry Pi Imager ( https://www.raspberrypi.com/software/ )
  2. Connectez la microsd à votre ordinateur à l’aide de l’adaptateur
  3. Ouvrir Raspberry Pi Imager :
  
- OS > Raspberry Pi OS (other) > Raspberry Pi OS LITE (64 bit)
  
- carte SD > Sélectionnez votre carte SD dans la liste
    
Cliquez sur Ecrire, il vous demandera la permission de formater la carte vous donnez votre consentement et attendez la fin de la procédure.

Débranchez et rebranchez votre périphérique et ouvrez la partition boot, vous trouverez une liste de fichiers et de dossiers, ouvrez le fichier config.txt et
à la fin du fichier, ajoutez les lignes suivantes :

    over_voltage=4
    arm_freq=1750
 
Débranchez la carte SD de votre ordinateur et insérez-la dans le bon l’emplacement sur le raspberry Pi.

### Configuration:

- Connectez votre raspberry pi ( l’interface intégrée à la carte doit être connectée au web, l’adaptateur USB --> RJ45 au switch, et enfin connectez un écran et un clavier)
- Suivez la procédure d’installation et entrez le nom d’utilisateur et le mot de passe qui vous conviennent.
- Après le redémarrage, vous serez invité à saisir vos informations d’identification, à entrer celles que vous avez configurées à l’étape précédente et à vous d'accedez
- Tout d’abord, nous allons dans le dossier système /etc et nous créons un dossier pour héberger notre script

````

cd /ect

sudo mkdir routing.script.d
		
cd routing.script.d

````

- Nous procédons au téléchargement du script
- Nous lui donnerons les permis d’exécution
- Nous installons iptables, paquet utilisé par le script pour gérer les règles du pare-feu

````

sudo wget https://github.com/Th3DarkOn3/ProjetTuteur/blob/main/Documentation/Routage/routing.sh

sudo chmod +x routing.sh

sudo apt update

sudo apt upgrade -y

sudo apt install iptables

````

 Ajout de l’exécution du script au démarrage
 
 ````
 
 sudo nano /etc/rc.local
 
 ````
 
Entrez juste au-dessus de exit les lignes suivantes
 
 ````
 
 ...
 
 ...
 
 ./etc/routing.script.d/routing.sh
 
 exit 0

````

Maintenant, ouvrez le script téléchargé et ajoutez les règles selon vos besoins

````

sudo nano /etc/routing.script.d/routing.sh

````

Comment ajouter des règles :

````
             INPUT                                                                                                 
iptables -A  FOWARD -i [Interface_input] -o [Interface_output] -p [protocole] --dport [port_utilisée] -j  ACCEPT / DROP
             OUTPUT
						 
````

INPUT = Signaux entrants dans le routeur

OUTPUT = Signaux qui sort du router

FORWARD = signaux en transit d’une interface à l’autre du routeur

Voici 3 exemples de règles

````

iptables -A INPUT -i eth1.99 -p udp --dport 53 -j ACCEPT

iptables -A OUTPUT -o eth1.99 -p udp --dport 53 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1.99 -p udp --dport 53 -j ACCEPT

````

# VLANs et routage inter-VLANs
La configuration des VLAN dans le switch change en fonction du projet et du modèle utilisé, donc je vous invite à configurer votre équipement en suivant le
manuel fourni par le fabricant.

Pour le routage entre vlans la première chose à faire est la configuration des interfaces et sous-interfaces qui dans notre cas sera fait en utilisant Netplan

````
sudo apt update

sudo apt upgrade -y

sudo apt install netplan.io

sudo nano /etc/netplan/project.vlans.yaml

````

Dans le fichier que vous avez ouvert, allez configurer les interfaces et les vlans que vous utilisez, voici un exemple de fichiers que vous pouvez utiliser comme base :

````

network:
    version: 2
    ethernets:
        eth0:
            addresses: 
                - 192.168.122.201/24
            gateway4: 192.168.122.1
            nameservers:
                addresses: [192.168.122.1]
        eth1: {}

    vlans:
        vlan.101:
            id: 101
            link: eth1
            addresses: [192.168.101.1/24]
        vlan.102:
            id: 102
            link: eth1
            addresses: [192.168.102.1/24]
	    
	    
````

# Configuration Serveur DNS

Pour configurer le DNS, nous allons utiliser dnsmasq, service avec une installation et configuration rapide :

````

sudo apt update

sudo apt upgrade -y

sudo apt install dnsmasq -y

sudo nano /etc/dnsmasq.conf

````

Appuyez sur CTRL+W pour rechercher et supprimer le signe # devant les lignes suivantes :

- domain-needed – Il s’assure que le serveur DNS ne transmet pas de noms de domaine incorrects. Ceci vérifie les noms qui n’ont pas de point et les conserve dans le réseau local.

- bogus-priv – Il empêche le serveur de transmettre des requêtes dans les plages locales d’IP aux serveurs amont. Il agit comme une fonctionnalité de sécurité qui empêche la fuite des IP locales vers les serveurs en amont.

- no-resolv – Il indique au serveur DNS d’utiliser DNSMasq pour la résolution des adresses au lieu de /etc/resolv.conf.

- cache-size=150 - remplacer le 150 par 1000

- server=/ - Supprimer cette ligne et la remplacer par la suivante

````

server=8.8.8.8

server=8.8.4.4

````

Et maintenant nous activons le service

````

sudo systemctl restart dnsmasq

sudo systemctl enable dnsmasq

````

Dnsmasq utilise le fichier Hosts comme zone inverse, donc si vous devez associer un FQDN à une adresse IP locale, vous devez le faire dans le fichier /etc/hosts

Example :

````

192.168.101.4	toto@domain.local	toto

````

# Serveur VPN

Pour le VPN, nous utiliserons OpenVPN service open source et gratuit.

Installation:

````

sudo apt update

sudo apt upgrade -y

sudo apt install openvpn -y

````

Activer OpenVPN au démarrage :

````

sudo sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/' /etc/default/openvpn ; systemctl daemon-reload

````

Se déplacer dans le dossier /etc/openvpn/:

````

cd /etc/openvpn/

````

Mise en place du pki :

````

sudo /usr/share/easy-rsa/easyrsa clean-all

sudo /usr/share/easy-rsa/easyrsa init-pki

````

Entrer yes pour démarrer l'initialisation 

Création du certificate authority dans /etc/openvpn/pki/ca.crt

````

sudo /usr/share/easy-rsa/easyrsa build-ca nopass

````

Renseigner le Common Name :

````

Using SSL: openssl OpenSSL 1.1.1k  25 Mar 2021
Generating RSA private key, 2048 bit long modulus (2 primes)
.........+++++
............................+++++
e is 65537 (0x010001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]: openvpn-host

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/pki/ca.crt

````

## Certificats Serveur

Création du certificat et de la clé privé serveur

````

sudo /usr/share/easy-rsa/easyrsa build-server-full server nopass

````

Génération des paramètres Diffie Hellman dans /etc/openvpn/pki/dh.pem

````

sudo  /usr/share/easy-rsa/easyrsa gen-dh

````

## Certificats Client

Créer un certificat client01 :

````

/usr/share/easy-rsa/easyrsa build-client-full client01 nopass

````

Ou créer 10 certificats clients en une ligne de commande :

````

for i in $(seq -w 1 10);do /usr/share/easy-rsa/easyrsa build-client-full client"$i" nopass; done

````

Éditer le fichier de configuration /etc/openvpn/server.conf :

````

sudo nano /etc/openvpn/server.conf

````

Dans le fichier

````

port 1194
proto udp
dev tun

ca /etc/openvpn/pki/ca.crt # generated keys
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key # keep secret
dh /etc/openvpn/pki/dh.pem

server 10.50.8.0 255.255.255.0 # internal tun0 connection IP
ifconfig-pool-persist ipp.txt

keepalive 10 120

comp-lzo # Compression - must be turned on at both end
persist-key
persist-tun

push "dhcp-option DNS adresse_ip_dns_locale"
push "dhcp-option DOMAIN domaine_local"
push "route adresse_ip_réseau_local masque_réseau_local"

status /var/log/openvpn-status.log

verb 3 # verbose mode

````

Activer le service OpenVPN Server :

````

sudo systemctl enable openvpn-server@.service

systemctl start openvpn@server.service

````

## Côté Routeur

Ajouter des règles au pare-feu pour autoriser la connexion au VPN

réadapter la règle suivante :

````
iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -p icmp -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tun0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

````

Copiez les fichiers suivants du serveur vers le client dans le dossier openvpn/config ( le debut du chemin du dossier change en fonction du système d’exploitation )

client 01:

- ca.crt : /etc/openvpn/pki/ca.crt
- client01.crt : /etc/openvpn/pki/issued/client01.crt
- client01.key : /etc/openvpn/pki/private/client01.key

client 02:

- ca.crt : /etc/openvpn/pki/ca.crt
- client01.crt : /etc/openvpn/pki/issued/client02.crt
- client01.key : /etc/openvpn/pki/private/client02.key

...

...

...

client 0n:

- ca.crt : /etc/openvpn/pki/ca.crt
- client01.crt : /etc/openvpn/pki/issued/client0n.crt
- client01.key : /etc/openvpn/pki/private/client0n.key

Dans le dossier "OpenVPN\config\", créez un fichier "client.ovpn" à modifier en fonction de l’adresse IP publique du serveur VPN:

````

client

dev tun

proto udp

remote OPENVPN_IP 1194

resolv-retry infinite
nobind
persist-key
persist-tun

ca ca.crt
cert client01.crt
key client01.key

comp-lzo

verb 3

````

# Serveur de fichier OpenMediaVault

- Pour installer le serveur de fichier OpenMediaVault vous pouvez vous référer au Projet Github de OpenMediaVault Plugin Developers, attention le script d’installation ne fonctione que sur Raspberry Pi OS LITE (64 bit): https://github.com/OpenMediaVault-Plugin-Developers/installScript

- Pour configurer le serveur de fichier OpenMediaVault vous pouvez suivre la vidéo suivante :
https://youtu.be/19SP7Zv-1g8

# Serveur DHCP

### Connectez vous en ssh  a votre serveur de fichier

````
ssh username@[VotreAddresseIP]
````

### Attribué une ip fix a votre serveur de fichier 

Editez le fichier config.yaml

````
sudo vim /etc/netplan/config.yaml
````

````
network:
	version: 2
	renderer: networkd
	ethernets:
		eth0:
			addresses:
				- 172.16.1.250/24
			gateway4: 172.16.1.1
			nameservers:
				addresses: [172.16.1.1, 8.8.8.8]
````

### Installation et configuration du service dnsmasq qui va jouer le role de DHCP 

Installer dnsmasq

````
sudo apt install dnsmasq
````

Le fichier dnsmasq.conf est générer dans /etc/ en étant déja préremplie. Nous allons le mettre de coté et en éditer un nouveau

````
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
````

Puis nous allons partir d'un nouveau fichier vièrge


````
sudo vim /etc/dnsmasq.conf
````

Et y rentrer la configuration suivante

````
log-dhcp
dhcp-range=172.16.1.100,172.16.1.200,12h
dhcp-option=option:netmask,255.255.255.0
dhcp-option=option:router,172.16.1.1,8.8.8.8
````
