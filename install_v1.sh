#!/bin/sh

# funcion para obtener la ip del equipo, ya sea que este conectado a una interface
# cableado o inalambrica. En caso de no estar conectado a ninguna red, se le asigna
# la direccion local 127.0.0.1
function wlan_o_eth()
{
    ETH=`/sbin/ifconfig eth0 2>/dev/null|awk '/Direc. inet:/ {print $2}'|sed 's/inet://'`
    WLAN=`/sbin/ifconfig wlan0 2>/dev/null|awk '/Direc. inet:/ {print $2}'|sed 's/inet://'`
    VACIO=''
    LOCAL='127.0.0.1'
    
    if [ "$ETH" = "$VACIO" ];
    then
        #echo "$VACIO"
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

	echo "INSTALANDO PAQUETES ..."
	dpkg -i packages/*.deb
	#la segunda vez para que instale bien mysql (no resuelve bien las dependencias)
	dpkg -i packages/*.deb
	#se habilita el modulo mcrypt de php, lo necesita phpmyadmin/mysql
	php5enmod mcrypt
	service apache2 reload
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
		#echo "COPIANDO ARCHIVOS DE APACHE2 ..."
		cp archivos_config/apache2/sites_available/* /etc/apache2/sites-available/
		#cp archivos_config/apache2/conf.d/* /etc/apache2/conf.d/

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
	#4.1) LimeSurvey:
		echo "COPIANDO Y CONFIGURANDO LIMESURVEY ..."
		cp apps/encuestas/encuestas.tgz /var/www/html/
		tar -zxvf /var/www/html/encuestas.tgz -C /var/www/html/
		
	#4.1) Wikimedia:
		#FALTA CONFIGURACIONES ADICIONES, COMO AUTORIZACION PARA NUEVOS USUARIOS.
		echo "COPIANDO Y CONFIGURANDO MEDIAWIKI ..."
		cp apps/wiki/wiki.tgz /var/www/html/
		tar -zxvf /var/www/html/wiki.tgz -C /var/www/html/
		
	#4.1) Wikipedia:
	#4.1) Wordpress:
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
		chown servidor.servidor /var/www/html/init_blog.sh
		chmod 755 /var/www/html/init_blog.sh
		cp archivos_config/lxsession/autostart /home/servidor/.config/lxsession/Lubuntu/autostart
		chown servidor.servidor /home/servidor/.config/lxsession/Lubuntu/autostart

	#4.1) Etherpad:
		echo "COPIANDO Y CONFIGURANDO ETHERPAD ..."
		cp apps/pad/pad.tgz /var/www/html/
		tar -zxvf /var/www/html/pad.tgz -C /var/www/html/
		#para que inicie automaticamente el servicio de etherped
		#en el inicio del sistema
		cp archivos_config/rc_local/rc.local /etc/

	#4.2) Archivos
		mkdir /var/www/html/archivos
		chown servidor.servidor /var/www/html/archivos/ -R
		exit
		ln -s /var/www/html/archivos/ /home/servidor/archivos
		sh /var/www/html/pad/bin/run.sh & #lanzar por primera vez el servidor de etherpad com usuario servidor

#5) 

#6)
	echo "FIN SCRIPT INSTALACION Y CONFIGURACION SERVIDOR PORTABLE"
	#echo "POR FAVOR VAYA A ...."

#genisoimage -o /home/linuxlookup/example.iso /source/directory/



#scrip para generar index-php de wordpress
#config wiki (creaion de usuarios)
#script en inicio de sesion para etherpad ()
#probar usar apt en lugar de dpkg []
#config el dir de archivos [OK]

#wikipedia [opcional]
