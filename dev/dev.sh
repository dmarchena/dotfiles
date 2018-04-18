#!/bin/bash
CURRENT_DIR="$(dirname "$0")"
#SCRIPT_NAME=$(basename "$0")
SCRIPT_NAME="dev"
source "$CURRENT_DIR/config.sh"


###############################################################################
# ARGUMENTOS
###############################################################################

# Texto de ayuda de los argumentos
###############################################################################
read -r -d '' HELP << EOH
-----------------------------------------------------------
  AYUDA
-----------------------------------------------------------

./$SCRIPT_NAME [-cp|-copyfrom ORIGEN][-n|--new] NOMBRE

  sin flags		Abrir el workspace cuya carpeta es NOMBRE
  
  -c|--copy		Crear un nuevo workspace llamado NOMBRE a partir 
    			de uno ya existente ORIGEN y abrirlo

  -h|--help		Mostrar la ayuda

  -l|--list		Mostrar un listado de los workspaces disponibles
  
  -n|--new		Crear un nuevo workspace básico llamado NOMBRE y 
    			abrirlo
EOH

# Recuperar argumentos
# https://stackoverflow.com/a/14203146
###############################################################################
POSITIONAL=()
while [[ $# -gt 0 ]] 
do
	key="$1"
	case $key in
	    -h|--help)
			echo "$HELP"
			exit 0
			;;
	    -l|--list)
			#printf "Estos son los workspaces del DEV disponibles:\n\n"
			ls -d $WS_BASHPATH/*/ | while read path; do WKS="$(basename "$path")"; if [ $WKS != "copiame" ] && [ ${WKS:0:1} != "_" ]; then echo "$WKS"; fi; done;
			exit 0
			;;
	    -cp|--copy)
		    WS_COPY_FROM="$2"
		    shift # past argument
		    shift # past value
		    ;;
	    -w|--workspace)
		    WS_DIRNAME="$2"
		    shift # past argument
		    shift # past value
		    ;;
	    -n|--new)
		    WS_NEW=true
		    shift # past argument
		    ;;
	    *)    # unknown option
		    POSITIONAL+=("$1") # save it in an array for later
		    shift # past argument
		    ;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# error start.sh
###############################################################################
if [[ -z $WS_DIRNAME ]] && [[ -z $1 ]]
	then
	    echo "Es obligatorio pasar la carpeta del workspace por parametro"
	    echo "Usa -h o --help para ver la ayuda"
	    exit 1
fi

# error start.sh -w WORKSPACE1 WORKSPACE2
###############################################################################
if [[ -n $1 ]]
	then
		if [[ -n $WS_DIRNAME ]] 
			then
				echo "Has especificado dos workspaces: $WS_DIRNAME y $1"
	    		echo "Usa -h o --help para ver la ayuda"
				exit 2
		else
			WS_DIRNAME="$1"
		fi
fi

# -cp / --copyfrom
###############################################################################
if [[ -n $WS_COPY_FROM ]] 
	then 
		if [ -d "$WS_BASHPATH/$WS_DIRNAME" ] 
			then 
				echo "El workspace '$WS_DIRNAME' ya existe. No es posible usar el flag -cp o --copyfrom."
				exit 4
		elif [ ! -d "$WS_BASHPATH/$WS_COPY_FROM" ]
			then
				echo "El workspace '$WS_COPY_FROM' no existe. No es posible generar '$WS_DIRNAME'."
				exit 5
		fi
	echo "Creando nuevo workspace '$WS_DIRNAME' a partir de '$WS_COPY_FROM'"
	cp -R "$WS_BASHPATH/$WS_COPY_FROM" "$WS_BASHPATH/$WS_DIRNAME"
fi

# -n / --new
###############################################################################
if [ "$WS_NEW" == "true" ]
	then 
		if [ -d "$WS_BASHPATH/$WS_DIRNAME" ]
			then
				echo "El workspace '$WS_DIRNAME' ya existe. No es posible usar el flag -n o --new."
				exit 6
		else
			echo "Creando nuevo workspace '$WS_DIRNAME'"
		    cp -R "$WS_BASHPATH/copiame" "$WS_BASHPATH/$WS_DIRNAME"
		fi
fi

# Por defecto: Si no existe el workspace preguntar para crearlo
###############################################################################
if [ ! -d "$WS_BASHPATH/$WS_DIRNAME" ] 
	then
	  	# Control will enter here if $DIRECTORY doesn't exist.
		read -r -p "El workspace no existe. ¿Quieres crear uno con ese nombre? [y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
			then
				echo "Creando nuevo workspace '$WS_DIRNAME'"
			    cp -R "$WS_BASHPATH/copiame" "$WS_BASHPATH/$WS_DIRNAME"
		else
		    exit 0
		fi
fi


###############################################################################
# REEMPLAZAR RUTAS A LOS PROPERTIES DE LOS SERVIDORES
# source replace-properties.sh "$WS_DIRNAME"
###############################################################################

WS_PROPERTIES_PATH="$WS_PATH_REGEX\/$WS_DIRNAME\/conf/properties"

# FULL SERVER
###############################################################################
echo "Configurando el servidor Was85 para usar los properties del workspace..."

FULL_FILE="$DEV_BASHPATH/TOOLS/WebSphere/AppServer/profiles/AppSrv01/config/cells/localhost/nodes/localhost/servers/server1/server.xml"
FULL_REPLACE="<classpath>$WS_PROPERTIES_PATH<\/classpath>"

# Sustituir los properties iniciales del DEV (caso inicial)
FULL_REGEX_DEV="<classpath>$DEV_PATH_REGEX[^<]*\/properties<\/classpath>"
sed -i "s|$(echo "$FULL_REGEX_DEV")|$FULL_REPLACE|g" $FULL_FILE
# Sustituir los properties al nuevo workspace (cambio de workspace)
FULL_REGEX_WS="<classpath>$WS_PATH_REGEX\/[^<]*\/properties<\/classpath>"
sed -i "s|$(echo "$FULL_REGEX_WS")|$FULL_REPLACE|g" $FULL_FILE

# LIBERTY SERVER
###############################################################################
echo "Configurando el servidor Liberty para usar los properties del workspace..."

LIBERTY_FILE="$DEV_BASHPATH/TOOLS/WebSphere/Liberty/usr/servers/libertyLocal/server.xml"
LIBERTY_REPLACE="<folder dir=\"$WS_PROPERTIES_PATH\"\/>"

# Sustituir los properties iniciales del DEV (caso inicial)
LIBERTY_REGEX_DEV="<folder dir=\"$DEV_PATH_REGEX[^>]*\/properties\"\/>"
sed -i "s|$(echo "$LIBERTY_REGEX_DEV")|$LIBERTY_REPLACE|g" $LIBERTY_FILE
# Sustituir los properties al nuevo workspace (cambio de workspace)
LIBERTY_REGEX_WS="<folder dir=\"$WS_PATH_REGEX\/[^>]*\/properties\"\/>"
sed -i "s|$(echo "$LIBERTY_REGEX_WS")|$LIBERTY_REPLACE|g" $LIBERTY_FILE


###############################################################################
# REEMPLAZAR CONFIGURACION DE APACHE
# source replace-apache.sh "$WS_DIRNAME"
###############################################################################

# Sustituir el httpd del dev8 para que xampp importe directamente el shared externo

DEV8_HTTPD="$DEV_BASHPATH/TOOLS/xampp/apache/conf/httpd.conf"
DEV8_REGEX="^Include $DEV_PATH_REGEX\\\\TOOLS\\\\apache-2\\.2\\.21\\\\httpd\\.conf"
DEV8_REPLACE="Include $WS_PATH_REGEX\/_shared\/apache\/httpd.conf"
sed -i "s|$(echo "$DEV8_REGEX")|$DEV8_REPLACE|g" $DEV8_HTTPD

# Sustituir las siguientes lineas especificas de workspace
# 	WebSpherePluginConfig "D:/DEV-WS/[nombreWS]/conf/apache/plugin-cfg.xml"
# 	Include D:/DEV-WS/[nombreWS]/conf/apache/httpd.conf
# 	
# Por las del workspace a utilizar
echo "Configurando el apache del workspace..."

WS_SHARED_HTTPD="$WS_BASHPATH/_shared/apache/httpd.conf"
WS_APACHE_BASEPATH_REGEX="$WS_PATH_REGEX\/[^\/][^\/]*\/conf\/apache\/"
WS_APACHE_BASEPATH="$WS_PATH_REGEX\/$WS_DIRNAME\/conf\/apache\/"
sed -i "s|$(echo "$WS_APACHE_BASEPATH_REGEX")|$WS_APACHE_BASEPATH|g" $WS_SHARED_HTTPD


###############################################################################
# RESETEAR M2
# Evitar conflictos con EAR y JAR generados en otros workspaces
###############################################################################

echo "Eliminando la carpeta 'vg' del m2 del DEV-WAS8"
rm -rf $M2_VG_BASHPATH


###############################################################################
# ARRANCAR EL DEV
###############################################################################

# Start xampp
runas /user:admapl $DEV_BASHPATH/TOOLS/xampp/xampp-control.exe

# Start ECLIPSE
echo "Arrancando Eclipse con el workspace \"$WS_DIRNAME\"..."
$DEV_BASHPATH/VG2017/eclipse/eclipse.exe -data "$WS_BASHPATH/$1" &

echo "Egun on! ¡Venga a currar!"
exit 0