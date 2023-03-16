# ProjetTuteur
La mise-en-place d’un réseau d’entreprise sécurisé avec des outils open source


# Routage

### Matériel requis :
  - Raspberry pi 4B 2Go ou plus
  - Microsd 16 Go ou plus + adaptateur micros --> USB
  - Adaptateur USB --> RJ45 compatible avec Debian
  - Un PC ou un mac connecté à Internet
  
 ### Installation du système d’exploitation :
 
  1. Téléchargez et installez Raspberry Pi Imager ( https://www.raspberrypi.com/software/ )
  2. Connectez la microsd à votre ordinateur à l’aide de l’adaptateur
  3. Ouvrir Raspberry Pi Imager :
  
- OS > Raspberry Pi OS (other) > Raspberry Pi OS LITE (64 bit)
  
- carte SD > Sélectionnez votre carte SD dans la liste
    
Cliquez sur Ecrire, il vous demandera la permission de formater la carte vous donnez votre consentement et attendez la fin de la procédure.

Débranchez et rebranchez votre périphérique et ouvrez la partition boot, vous trouverez une liste de fichiers et de dossiers ouvrire config.txt et
à la fin du fichier, ajoutez les lignes suivantes :

    over_voltage=4
    arm_freq=1750
 
Débranchez la carte SD de votre ordinateur et insérez-la dans le bon l’emplacement sur le raspberry Pi.

### Configuration:

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

Voici 3 exemples de règles

````

iptables -A INPUT -i eth1.99 -p udp --dport 53 -j ACCEPT

iptables -A OUTPUT -o eth1.99 -p udp --dport 53 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1.99 -p udp --dport 53 -j ACCEPT

````
