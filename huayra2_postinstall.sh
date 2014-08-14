#!/bin/sh
echo AGREGANDO REPOSITORIO DE COMUNIDAD...
cd ~
wget -c comunidadhuayra.org/ich.deb
sudo dpkg -i ich.deb
rm ich.deb
echo ACTUALIZANDO FUENTES...
apt-get clean
apt-get update
echo INSTALANDO DRIVERS INTEL
sudo apt-get install -y intel-classmate-drivers
sudo apt-get install -y intel-classmate-function-keys
sudo apt-get install -y intel-pvr-support
echo MONTANDO DATOS...
mkdir /media/DATOS
mount /dev/sda4 /media/DATOS
mount /dev/sdb4 /media/DATOS
echo CREANDO ESTRUCTURA DE DIRECTORIO EN DATOS...
mkdir /media/DATOS/Mis\ Cosas
mkdir /media/DATOS/Mis\ Cosas/Descargas
mkdir /media/DATOS/Mis\ Cosas/Mi\ música
mkdir /media/DATOS/Mis\ Cosas/Mis\ documentos
mkdir /media/DATOS/Mis\ Cosas/Mis\ imágenes
mkdir /media/DATOS/Mis\ Cosas/Mis\ vídeos
echo EJECUTANDO POST-INSTALL...
sudo apt-get install -y huayra-postinstall-pci
echo CREANDO ENLACE CDPEDIA A DATOS...
ln -s /media/DATOS/cdpedia /usr/share/cdpedia 
echo RESETENDO TDAgent...
/etc/theftdeterrent/initINI.sh
echo ACTUALIZANDO TDAgent...
sed -i 's/ServerAddress=/ServerAddress=tdserver/g' /etc/theftdeterrent/TDAgent.ini
sed -i 's/PromptDays=5/PromptDays=56/g' /etc/theftdeterrent/TDAgent.ini
#sed -i 's/PromptTimes=15/PromptTimes=15/g' /etc/theftdeterrent/TDAgent.ini
sed -i 's/Heartbeat_Interval=10/Heartbeat_Interval=1/g' /etc/theftdeterrent/TDAgent.ini
echo FINALIZADO!!! 
