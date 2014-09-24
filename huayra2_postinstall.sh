#!/bin/bash
echo AGREGANDO REPOSITORIO DE COMUNIDAD...
cd ~
wget -c comunidadhuayra.org/ich.deb
sudo dpkg -i ich.deb
rm ich.deb
echo MONTANDO DATOS...
if [ ! -f /etc/fstab ]; then
        zenity --info --text "No existe /etc/fstab"
        exit 1
fi

if ! command -v blkid > /dev/null ; then
        zenity --info --text "No existe blkid"
        exit 1
fi

#chequear si hay una partición con label=datos y si no salir
blkid -L DATOS >> /dev/null
if [ ! $? -eq 0 ]; then
        zenity --info --text "No hay una partición con label DATOS"
        exit 1
fi

DATOS_DEV=`blkid -L DATOS | head -n 1`
if [ $? -eq 0 ]; then

    DATOS_UUID=`blkid $DATOS_DEV|awk '{print $3}' | cut -d '=' -f 2 | sed -e 's/"//g'`


    grep "$DATOS_DEV" /etc/fstab > /dev/null
    if [ ! $? -eq 0 ]; then
            grep "$DATOS_UUID" /etc/fstab > /dev/null
            if [ ! $? -eq 0 ]; then
                grep "LABEL=DATOS" /etc/fstab > /dev/null
                if [ ! $? -eq 0 ]; then
                    echo "LABEL=DATOS /media/DATOS vfat defaults,umask=0,errors=remount-ro 0 1" >> /etc/fstab
                    echo "Se agregó la partición de DATOS a /etc/fstab"
                fi
            fi

    fi

    if [ ! -f /media/DATOS ]; then
            mkdir -p /media/DATOS
            mount /media/DATOS
            echo "Se ha montado la partición DATOS"
    fi
fi

#
if [ -f /etc/fstab ]; then
  sed -i".backup" '/usb/d' /etc/fstab
else
  echo "No existe /etc/fstab"
fi

#
if [ ! -e /media/DATOS ]; then
        echo "La partición DATOS no existe o no está montada"
        exit 0
fi

if [ ! -e "/media/DATOS/Mis Cosas" ]; then
		mkdir "/media/DATOS/Mis Cosas" 
        echo "Creando carpeta Mis Cosas"
fi

for i in Descargas Música Documentos Imágenes Videos Vídeos; do
	case $i in
		Descargas) 
			if [ -e /home/alumno/$i ]; then
				echo "Moviendo carpeta $i"
				if [ -e "/media/DATOS/Mis Cosas/Descargas" ]; then
					mv -f /home/alumno/$i/* "/media/DATOS/Mis Cosas/Descargas/"
				else
					mv -f /home/alumno/$i "/media/DATOS/Mis Cosas/Descargas"
				fi;             
        	fi;
		;;
		Música)
			if [ -e /home/alumno/$i ]; then
                echo "Moviendo carpeta $i"
				if [ -e "/media/DATOS/Mis Cosas/Mi música" ]; then
					mv -f /home/alumno/$i/* "/media/DATOS/Mis Cosas/Mi música/"
				else
					mv -f /home/alumno/$i "/media/DATOS/Mis Cosas/Mi música"
				fi; 
        	fi;
		;;
		Documentos)
			if [ -e /home/alumno/$i ]; then
                echo "Moviendo carpeta $i"
				if [ -e "/media/DATOS/Mis Cosas/Mis documentos" ]; then
					mv -f /home/alumno/$i/* "/media/DATOS/Mis Cosas/Mis documentos/"
				else
					mv -f /home/alumno/$i "/media/DATOS/Mis Cosas/Mis documentos"
				fi;
        	fi;
		;;
		Imágenes)
			if [ -e /home/alumno/$i ]; then
                echo "Moviendo carpeta $i"
				if [ -e "/media/DATOS/Mis Cosas/Mis imágenes" ]; then
					mv -f /home/alumno/$i/* "/media/DATOS/Mis Cosas/Mis imágenes/"
				else
					mv -f /home/alumno/$i "/media/DATOS/Mis Cosas/Mis imágenes"
				fi;
        	fi;
		;;
		Videos)
			if [ -e /home/alumno/$i ]; then
                echo "Moviendo carpeta $i"
				if [ -e "/media/DATOS/Mis Cosas/Mis vídeos" ]; then
					mv -f /home/alumno/$i/* "/media/DATOS/Mis Cosas/Mis vídeos/"
				else
					mv -f /home/alumno/$i "/media/DATOS/Mis Cosas/Mis vídeos"
				fi;
        	fi;
		;;
		Vídeos)
			if [ -e /home/alumno/$i ]; then
                echo "Moviendo carpeta $i"
				if [ -e "/media/DATOS/Mis Cosas/Mis vídeos" ]; then
					mv -f /home/alumno/$i/* "/media/DATOS/Mis Cosas/Mis vídeos/"
				else
					mv -f /home/alumno/$i "/media/DATOS/Mis Cosas/Mis vídeos"
				fi;
        	fi;
		;;
	  esac
done

ln -s "/media/DATOS/Mis Cosas/Descargas/" /home/alumno/Descargas
ln -s "/media/DATOS/Mis Cosas/Mi música/" /home/alumno/Música
ln -s "/media/DATOS/Mis Cosas/Mis documentos/" /home/alumno/Documentos
ln -s "/media/DATOS/Mis Cosas/Mis imágenes/" /home/alumno/Imágenes
ln -s "/media/DATOS/Mis Cosas/Mis vídeos/" /home/alumno/Videos
chown -R alumno:alumno /home/alumno/Descargas /home/alumno/Música /home/alumno/Documentos /home/alumno/Imágenes /home/alumno/Videos

echo "Symlinks creados en la carpeta Home del alumno"
#
cp -r /usr/share/huayra-postinstall-pci/alumno/.config/* /home/alumno/.config
cp -r /usr/share/huayra-postinstall-pci/alumno/.local/* /home/alumno/.local
echo "Agregando elementos de menú al usuario alumno"
cp -r /usr/share/huayra-postinstall-pci/alumno/.config/* /etc/skel/.config
cp -r /usr/share/huayra-postinstall-pci/alumno/.local/* /etc/skel/.local
echo "Agregando elementos de menú al skel de usuarios"
#
echo ESCONDIENDO PARTICIONES DE SISTEMA...
if [ ! -f /etc/udev/rules.d/99-hide-disks.rules ]; then
        touch /etc/udev/rules.d/99-hide-disks.rules
fi

grep 'sda2' /etc/udev/rules.d/99-hide-disks.rules > /dev/null
if [ ! $? -eq 0 ]; then
    echo 'KERNEL=="sda2", ENV{UDISKS_PRESENTATION_HIDE}=1"' >> /etc/udev/rules.d/99-hide-disks.rules
fi

grep 'sda5' /etc/udev/rules.d/99-hide-disks.rules > /dev/null
if [ ! $? -eq 0 ]; then
    echo 'KERNEL=="sda5", ENV{UDISKS_PRESENTATION_HIDE}=1"' >> /etc/udev/rules.d/99-hide-disks.rules
fi
#
echo INSTALANDO FLASH...
update-flashplugin-nonfree --install
#
apt-get update
apt-get install -y intel-classmate-drivers
apt-get install -y intel-classmate-function-keys
apt-get install -y intel-pvr-support
#
echo CREANDO ENLACE CDPEDIA A DATOS...
ln -s /media/DATOS/cdpedia /usr/share/cdpedia 
echo RESETENDO TDAgent...
/etc/theftdeterrent/initINI.sh
echo ACTUALIZANDO TDAgent...
sed -i 's/ServerAddress=/ServerAddress=tdserver/g' /etc/theftdeterrent/TDAgent.ini
sed -i 's/PromptDays=5/PromptDays=56/g' /etc/theftdeterrent/TDAgent.ini
#sed -i 's/PromptTimes=15/PromptTimes=15/g' /etc/theftdeterrent/TDAgent.ini
sed -i 's/Heartbeat_Interval=10/Heartbeat_Interval=1/g' /etc/theftdeterrent/TDAgent.ini
echo COPIANDO ENLACES
cp -R /media/USBBOOT/shorcouts/* /home/alumno/Escritorio/
chmod 777 -R /home/alumno/Escritorio/*.desktop
chmod +x -R /home/alumno/Escritorio/*.desktop
echo FINALIZADO!!! 
