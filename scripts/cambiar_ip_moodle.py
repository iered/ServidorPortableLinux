import sys
import os.path
import commands

def help():
    print("Usar: python cambiar_ip_moodle.py [ruta del archivo config.php de moodle]")
    print("La ruta deberia ser:  /var/www/html/cursos/config.php")

if __name__ == "__main__":
    ruta_archivo = sys.argv[1]
    #print(ruta_archivo)
    if os.path.isfile(ruta_archivo) and os.path.exists(ruta_archivo):
        s = commands.getoutput("/sbin/ifconfig").split()[6][5:]
        #print(s)
        archivo = open(ruta_archivo, 'r')
        archivo_salida = open("/tmp/nuevo_config.php", 'w')
        for linea in archivo:
            if 'CFG->wwwroot' in linea:
                nueva_linea = "$CFG->wwwroot = 'http://" + s + "/cursos';\n";
                archivo_salida.write(nueva_linea)
            else:
                archivo_salida.write(linea)
        archivo.close()
        archivo_salida.close()
    else:
        print("No se pude hallar el archivo de configuracion de moodle")
        print("La ruta deberia ser:  /var/www/html/cursos/config.php")

#tener en cuenta si es coneccion wlan o eth0
