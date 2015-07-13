#!/bin/bash

USUARIO=$1

# funcion para obtener la ip del equipo, ya sea que este conectado a una interface
# cableado o inalambrica. En caso de no estar conectado a ninguna red, se le asigna
# la direccion local 127.0.0.1
wlan_o_eth()
{
    ETH=`/sbin/ifconfig eth0 2>/dev/null|awk '/Direc. inet:/ {print $2}'|sed 's/inet://'`
    WLAN=`/sbin/ifconfig wlan0 2>/dev/null|awk '/Direc. inet:/ {print $2}'|sed 's/inet://'`
    VACIO=''
    LOCAL='127.0.0.1'
    
    if [ "$ETH" = "$VACIO" ];
    then
        #echo "$VACIO"export DEBIAN_FRONTEND=noninteractive
        if [ "$WLAN" = "$VACIO" ];
        then
            echo "$LOCAL"
        else
            echo "$WLAN"
        fi
    else
        echo "$ETH"
    fi
}

#INICIAR COMO USUARIO NORMAL Y QUE PIDA CLAVE DE ROOT

#1) iniciar este script de forma automatica
	#YA

#2) instalar todos los paquetes .deb
	#- abrir una terminal o ventana en pytgk y que muestre el proceso!!!
		#- Esto se ya se hizo en instalar.sh
	#- pedir contresenia de root
	#sudo -s
	#- evitar que pida las configuraciones
	export DEBIAN_FRONTEND=noninteractive
	echo "CONFIGURANDO CONTRASENIA MYSQL ..."
	echo "mysql-server-5.5 mysql-server/root_password password Adm1n1str@d0r" | debconf-set-selections
	echo "mysql-server-5.5 mysql-server/root_password_again password Adm1n1str@d0r" | debconf-set-selections

	# MySQL application password for phpmyadmin:
	echo "CONFIGURANDO CONTRASENIAS PHPMYADMIN ..."
	echo "phpmyadmin phpmyadmin/app-password-confirm password Adm1n1str@d0r" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password Adm1n1str@d0r" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/password-confirm password Adm1n1str@d0r" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/setup-password password Adm1n1str@d0r" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/dbconfig-upgrade boolean true" | debconf-set-selections

## Tratar con apt para corregir errores de instalacion ##

	echo "...PROCESO DE ACTUALIZACIÓN E INSTALACIÓN DE  PAQUETES..."
	#Tener en cuenta que source lista esta vacio	
	mkdir /media/aptoncd
	mount -t iso9660 paquetes-DVD1.iso /media/aptoncd -o loop
	cp /etc/apt/sources.list /etc/apt/sources.list.BACKUP
	echo "deb file:/media/aptoncd ./" > /etc/apt/sources.list
	apt-get update
	echo " ---------- "
	echo "ACTUALIZANDO PAQUETES ..."
	echo " ---------- "
	apt-get -o Debug::pkgProblemResolver=yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes -fuy upgrade
	
	echo " ---------- "
	echo "INSTALANDO PAQUETES "
	echo " ---------- "
	apt-get -o Debug::pkgProblemResolver=yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes -fuy install  pdfmod libreoffice libreoffice-l10n-es libreoffice-help-es myspell-es gimp inkscape audacity aptoncd vlc gparted apache2 apache2-utils apache2-mpm-prefork apache2-mpm-worker apache2-mpm-event libapache2-mod-apparmor libapache2-mod-auth-mysql libapache2-mod-php5filter php5 php5-fpm mcrypt php5-mcrypt mysql-server phpmyadmin freemind pdftk apt-show-versions openssh-server openssh-client nmap nast chromium-browser chromium-browser-l10n openshot openshot-doc fbreader gnome-screenshot gnome-system-monitor lubuntu-restricted-extras wine icedtea-plugin p7zip-full p7zip-rar pavucontrol curl nodejs
	
	umount /media/aptoncd 
	rm -rf /media/aptoncd

	cp /etc/apt/sources.list.BACKUP /etc/apt/sources.list

	#se habilita el modulo mcrypt de php, lo necesita phpmyadmin/mysql
	php5enmod mcrypt
	service apache2 reload

##  instalar flasf plugin y fuentes de windows de forma manual sin la instalacion por dpkg ##
http://archive.canonical.com/pool/partner/a/adobe-flashplugin/adobe-flashplugin_20150623.1.orig.tar.gz

## habilitar modulo de mysql para funciones de limesurvey ###

	#- HAY NECESIDAD DE VERIFICAR LOS PUERTOS DE MYSQL, APACHE2
		# netstat -natup | grep mysqld (script en python)
	#-

#3) copiar /reemplazar los archivos de configuracion de los principales servicios
	#3.1) APT: reemplazar las listas de los repositorios (si es offline ... es necesario esto??)
	#3.2) phpmyadmin
		#No hay necesdidad de copiar archivos SI debconf-set-selections funciona
	#3.3) mysql - Restaurar toda la BD (Creo problemas), PROBANDO backup y restauracion base por base; 
		#para hacer al backup se uso: mysqldump -p --all-databases > all_databases.sql (X)
		#para hacer al backup se uso: mysqldump -u root -h localhost -pAdm1n1str@d0r bdmoodle > moodle_database.sql
		mysql -u root -pAdm1n1str@d0r -e "CREATE DATABASE bdmoodle;"
		mysql -u root -pAdm1n1str@d0r bdmoodle < archivos_config/mysql/moodle_database.sql
		Q1="GRANT ALL ON bdmoodle.* TO 'umoodle'@'localhost' IDENTIFIED BY 'Adm1n1str@d0r';"
		Q2="FLUSH PRIVILEGES;"
		SQL="${Q1}${Q2}"
		mysql -u root -pAdm1n1str@d0r -e "$SQL"

		mysql -u root -pAdm1n1str@d0r -e "CREATE DATABASE bdblog;"
		mysql -u root -pAdm1n1str@d0r bdblog < archivos_config/mysql/blog_database.sql
		Q1="GRANT ALL ON bdblog.* TO 'ublog'@'localhost' IDENTIFIED BY 'Adm1n1str@d0r';"
		Q2="FLUSH PRIVILEGES;"
		SQL="${Q1}${Q2}"
		mysql -u root -pAdm1n1str@d0r -e "$SQL"


		mysql -u root -pAdm1n1str@d0r -e "CREATE DATABASE bdwiki;"
		mysql -u root -pAdm1n1str@d0r bdwiki < archivos_config/mysql/wiki_database.sql
		Q1="GRANT ALL ON bdwiki.* TO 'uwiki'@'localhost' IDENTIFIED BY 'Adm1n1str@d0r';"
		Q2="FLUSH PRIVILEGES;"
		SQL="${Q1}${Q2}"
		mysql -u root -pAdm1n1str@d0r -e "$SQL"

		mysql -u root -pAdm1n1str@d0r -e "CREATE DATABASE bdencuesta;"
		mysql -u root -pAdm1n1str@d0r bdencuesta < archivos_config/mysql/encuesta_database.sql
		Q1="GRANT ALL ON bdencuesta.* TO 'uencuesta'@'localhost' IDENTIFIED BY 'Adm1n1str@d0r';"
		Q2="FLUSH PRIVILEGES;"
		SQL="${Q1}${Q2}"
		mysql -u root -pAdm1n1str@d0r -e "$SQL"

		mysql -u root -pAdm1n1str@d0r -e "CREATE DATABASE pad;"
		mysql -u root -pAdm1n1str@d0r pad < archivos_config/mysql/pad_database.sql
		Q1="GRANT ALL ON pad.* TO 'pad'@'localhost' IDENTIFIED BY 'pad';"
		Q2="FLUSH PRIVILEGES;"
		SQL="${Q1}${Q2}"
		mysql -u root -pAdm1n1str@d0r -e "$SQL"

	#3.4) php5
		echo ""
		echo "COPIANDO ARCHIVOS DE PHP ..."
		cp archivos_config/php/php.ini /etc/php5/apache2/

	#3.5) apache2
		echo "COPIANDO ARCHIVOS DE APACHE2 ..."
		cp archivos_config/apache2/sites_available/* /etc/apache2/sites-available/
		#cp archivos_config/apache2/conf.d/* /etc/apache2/conf.d/

	#3.6) phpmyadmin
		echo "COPIANDO ARCHIVOS DE PHPMYADMIN ..."
		cp archivos_config/phpmyadmin/config.inc.php /etc/phpmyadmin
		#VERIFICAR SI AHORA CON APT-GET SE ISNTALA BIEN LA BD DE PHPMYADMIN

#4) copiar las apps a su ubicacion correspondiente
	#4.1) Moodle:
		#4.1.1) cambiar ip del archivo conf de Moodle (ejecutar script de python)
		echo "COPIANDO Y CONFIGURANDO MOODLE ..."
		cp apps/moodle/cursos.tgz /var/www/html/
		tar -zxvf /var/www/html/cursos.tgz -C /var/www/html/
		cp apps/moodle/datos_cursos.tgz /var/www/
		tar -zxvf /var/www/datos_cursos.tgz -C /var/www/
		#python scripts/cambiar_ip_moodle.py /var/www/html/cursos/config.php
		#mv /tmp/nuevo_config.php /var/www/html/cursos/config.php
		#rm /tmp/nuevo_config.php
		#que pasa si se reinicia el equipo?????????
		chown www-data.www-data /var/www/html/cursos/config.php

	#4.2) LimeSurvey:
		echo "COPIANDO Y CONFIGURANDO LIMESURVEY ..."
		cp apps/encuestas/encuestas.tgz /var/www/html/
		tar -zxvf /var/www/html/encuestas.tgz -C /var/www/html/
		
	#4.3) Wikimedia:
		#FALTA CONFIGURACIONES ADICIONES, COMO AUTORIZACION PARA NUEVOS USUARIOS.
		echo "COPIANDO Y CONFIGURANDO MEDIAWIKI ..."
		cp apps/wiki/wiki.tgz /var/www/html/
		tar -zxvf /var/www/html/wiki.tgz -C /var/www/html/
		
	#4.4) Wordpress:

	## plugin de wordpress para no conectarse a internet ##
	## solucionar problemas de enlaces y carga de imagenes y archivos ##

		echo "COPIANDO Y CONFIGURANDO WORDPRESS"
		#ASEGURARSE QUE LUBUNTU ESTE EN ESPANOL
		#IP=`/sbin/ifconfig eth0 2>/dev/null|awk '/Direc. inet:/ {print $2}'|sed 's/inet://'`
		IP=$(wlan_o_eth)
		IPANT=`mysql -u root -pAdm1n1str@d0r bdblog -e "select option_value from wp_options limit 1;" |awk '/http:/ {print $1}'|sed 's/http:\/\///'|sed 's/\/blog//'`

		mysql -u root -pAdm1n1str@d0r bdblog -e "UPDATE wp_options SET option_value = REPLACE ( option_value, '$IPANT', '$IP' );"
		mysql -u root -pAdm1n1str@d0r bdblog -e "UPDATE wp_posts SET guid = REPLACE ( guid, '$IPANT', '$IP' );"
		mysql -u root -pAdm1n1str@d0r bdblog -e "UPDATE wp_posts SET post_content = REPLACE ( post_content, '$IPANT', '$IP' );"
		mysql -u root -pAdm1n1str@d0r bdblog -e "UPDATE wp_postmeta SET meta_value = REPLACE ( meta_value, '$IPANT', '$IP' );"
		mysql -u root -pAdm1n1str@d0r bdblog -e "UPDATE wp_blogs SET domain = REPLACE (domain, '$IPANT', '$IP' );"
		
		cp apps/blog/blog.tgz /var/www/html/
		tar -zxvf /var/www/html/blog.tgz -C /var/www/html/
		cp archivos_config/apache2/sites_available/000-default.conf /etc/apache2/sites-available/

		a2enmod rewrite
		service apache2 reload
		
		#copiar script para cambio de ip del blog
		cp scripts/init_blog.sh /var/www/html
		chown $USUARIO.$USUARIO /var/www/html/init_blog.sh
		chmod 755 /var/www/html/init_blog.sh
		
		# copiar archivo de configuracion para iniciar el script del blog y kiwix-serve de wikipedia
		cp archivos_config/lxsession/autostart $HOME/.config/lxsession/Lubuntu/autostart
		chown $USUARIO.$USUARIO $HOME/.config/lxsession/Lubuntu/autostart

	#4.5) Etherpad:
		echo "COPIANDO Y CONFIGURANDO ETHERPAD ..."
		cp apps/pad/pad.tgz /var/www/html/
		tar -zxvf /var/www/html/pad.tgz -C /var/www/html/
		#para que inicie automaticamente el servicio de etherped
		#en el inicio del sistema
		cp archivos_config/rc_local/rc.local /etc/

	#4.6) kiwix - wikipedia
		echo "COPIANDO Y CONFIGURANDO KIWIX - WIKIPEDIA..."
		mkdir /var/www/html/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014
		#cp ../recursos/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014.zip /var/www/html/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014
		#cd /var/www/html/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014
		unzip ../recursos/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014.zip -d /var/www/html/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014/
		chown $USUARIO.$USUARIO /var/www/html/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014 -R
		chmod go+rx /var/www/html/kiwix-0.9-rc2+wikipedia_es_all_nopic_02_2014/kiwix-linux -R
		#enlace en el Escritorio para que se ejecute kiwix
		## cd /media/servidor/UUI/servidorportable_linux
		## cp scripts/start_kiwix.sh $HOME/Escritorio
		## chmod ugo+rx $HOME/Escritorio/start_kiwix.sh

	#4.7) Archivos
		echo "COPIANDO Y CONFIGURANDO ARCHIVOS ..."
		mkdir /var/www/html/archivos
		chown $USUARIO.$USUARIO /var/www/html/archivos/ -R

		#cambiar a un home generico
		ln -s /var/www/html/archivos/ $HOME/Escritorio
		
	#4.8) REA en archivos
		echo "COPIANDO Y CONFIGURANDO REA ..."
		#cp ../recursos/REA_v2.zip /var/www/html/archivos
		#cd /var/www/html/archivos
		unzip ../recursos/REA_v2.zip -d /var/www/html/archivos/
		chown $USUARIO.$USUARIO /var/www/html/archivos/REA -R

		#lanzar por primera vez el servidor de etherpad com usuario servidor
		#AHORA este comando se lanza en instalar.sh
		#sh /var/www/html/pad/bin/run.sh & 
	
#5 copiar otros archivos del sistema: fuentes, flashplayer, 
	#5.1) flashplayer
	sh archivos_config/flash_plugin_20150623/install_flash.sh

	#5.2) fuentes microsoft: arial, verdana, etc
	echo "INSTALANDO FUENTES"
	tar -zxvf archivos_config/fuentes/msttcorefonts.tgz -C /usr/share/fonts/truetype/
	tar -zxvf archivos_config/fuentes/var-lib-msttcorefonts.tgz -c /var/lib/
	fc-cache -f -v

#6)
	echo "FIN SCRIPT INSTALACION Y CONFIGURACION SERVIDOR PORTABLE"
	echo "POR FAVOR REINICIE EL EQUIPO"

	#reboot

#genisoimage -o /home/linuxlookup/example.iso /source/directory/

exit
