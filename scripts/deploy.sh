#!/bin/bash

set -ex

source .env

# Actualizamos e instalamos los paquetes necesarios
sudo dnf update
sudo dnf install -y git httpd mariadb-server mariadb php php-mysqlnd

# Iniciamos y habilitamos los servicios Apache y MariaDB
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Borrar instalaciones anteriores
sudo rm -rf /tmp/iaw-practica-lamp

# Clonamos el repositorio de la aplicación
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp

#Mover el codigo fuente a la ubicacion de apache
sudo mv /tmp/iaw-practica-lamp/src/* /var/www/html

# Configuración de config.php
sudo sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sudo sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sudo sed -i "s/password_here/$DB_PASS/" /var/www/html/config.php

# Modificamos el nombre de la base de datos
sudo sed -i "s/username_here/$DB_USER/" /var/www/html/config.php

 #Importamos el script SQL de la base de datos
sudo mysql -u root < /tmp/iaw-practica-lamp/db/database.sql

# Creamos el usuario de la base de datos y le asignamos privilegios
sudo mysql -u root <<< "DROP USER IF EXISTS $DB_USER@'%'"
sudo mysql -u root <<< "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASS'"
sudo mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%'"

sudo semanage fcontext -a -t httpd_sys_script_exec_t "/var/www/html(/.*)?"

sudo restorecon -Rv /var/www/htmlpractica01/scripts/deploy.sh