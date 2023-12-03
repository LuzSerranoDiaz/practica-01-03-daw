#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -x

# Actualizamos la lista de repositorios
dnf update -y

# Instalar Apache
dnf install httpd -y

# Instalamos MariaDB (equivalente a MySQL en Fedora)
dnf install mariadb-server -y

# Instalación de PHP
dnf install php php-mysqlnd php-opcache php-gd php-curl php-mbstring -y

# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/httpd/conf.d

# Reiniciamos el servicio de Apache
systemctl restart httpd

# Copiamos el archivo de prueba de PHP
cp ../php/index.php /var/www/html

# Cambiamos el usuario y el propietario del directorio /var/www/html
chown -R apache:apache /var/www/html
