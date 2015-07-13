#!/bin/bash

#1) iniciar este script de forma automatica
	#capturamos el usuario del sistema que ejecuta el script
	USUARIO=$(whoami)

#2) Ejecutar el script install.sh que contiene todo el proceso del servidor portable
        /usr/bin/sudo -s sh install_v2.sh $USUARIO

#lanzar por primera vez el servidor de etherpad com usuario del sistema
sh /var/www/html/pad/bin/run.sh & 

exit