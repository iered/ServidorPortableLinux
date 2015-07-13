#!/bin/sh

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

#IP=`/sbin/ifconfig wlan0 2>/dev/null|awk '/Direc. inet:/ {print $2}'|sed 's/inet://'`

IP=$(wlan_o_eth)
		
IPANT=`mysql -u root -pAdm1n1str@d0r bdblog -e "select option_value from wp_options limit 1;" |awk '/http:/ {print $1}'|sed 's/http:\/\///'|sed 's/\/blog//'`

Q1="UPDATE wp_options SET option_value = REPLACE ( option_value, '$IPANT', '$IP' );"
Q2="UPDATE wp_posts SET guid = REPLACE ( guid, '$IPANT', '$IP' );"
Q3="UPDATE wp_posts SET post_content = REPLACE ( post_content, '$IPANT', '$IP' );"
Q4="UPDATE wp_postmeta SET meta_value = REPLACE ( meta_value, '$IPANT', '$IP' );"
#Q5="UPDATE wp_blogs SET domain = REPLACE (domain, '$IPANT', '$IP' );"
Q6="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}${Q6}"
mysql -u root -pAdm1n1str@d0r bdblog -e "$SQL"
