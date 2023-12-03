# practica-01-03-daw
# Creacion de instancia en OpenStack

![instancias](https://github.com/LuzSerranoDiaz/Practica-01-02daw/assets/125549381/cb6ec693-303b-4bea-b9ea-75ae71bdee5f)
(se me olvido hacer una captura a la maquina y ya la borré, disculpa por las molestias)
Se crea una instancia de Ubuntu 23.04 con sabor m1.medium para que no haya errores con la memoria ram.

![clave](https://github.com/LuzSerranoDiaz/Practica-01-02daw/assets/125549381/41dd7bcc-a631-4323-a825-813bd2620d8a)

Se utiliza el par de claves ya utilizado.

![SecurityGroup](https://github.com/LuzSerranoDiaz/Practica-01-02daw/assets/125549381/649d64bb-5727-49a7-8932-cee79d389bf4)

Se añaden excepciones en el grupo de seguridad para los puertos 22(SSH), 80(HTTP) y 443(HTTPS), y ICMP.

En este documento se presentará los elementos para instalar LAMP, junto otras herramientas y modificaciones.

## Install_lamp.sh
```bash
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
```
En este script se realiza la instalación de LAMP en la última version de **fedora server** junto con la modificación del archivo 000-default.conf, para que las peticiones que lleguen al puerto 80 sean redirigidas al index encontrado en /var/www/html
### Como ejecutar Install_lamp.sh
1. Abre un terminal
2. Concede permisos de ejecución
 ```bash
 chmod +x install_lamp.sh
 ```
 o
 ```bash
 chmod 755 install_lamp.sh
 ```
 3. Ejecuta el archivo
 ```bash
 sudo ./install_lamp.sh
 ```
## .env
```bash
DB_NAME=lamp_db
DB_USER=lamp_user
DB_PASS=lamp_pass
```
## 000-default.conf
```
ServerSignature Off
ServerTokens Prod

<VirtualHost *:80>
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
</VirtualHost>
```
## Deploy.sh
```bash
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
```
Realizamos los pasos premeditarios
1. Para ver los comandos que realizamos y parar en error
2. Importar el archivo .env
3. Actualizar e instalar los paquetes necesarios para realizar este script
4. Iniciar y habilitar los servicios apache y MariaDB
```bash

# Borrar instalaciones anteriores
sudo rm -rf /tmp/iaw-practica-lamp

# Clonamos el repositorio de la aplicación
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp

#Mover el codigo fuente a la ubicacion de apache
sudo mv /tmp/iaw-practica-lamp/src/* /var/www/html
```
1. Se borran las instalaciones anteriores de la aplicacion para que no intervengan
2. Se descarga la aplicacion proporcionada en el directorio `/tmp/iaw-practica-lamp`
3. Se mueve el codigo fuente necesario del directorio temporal a la ruta `/var/www/html` para que pueda ser ejecutado
```bash
# Configuración de config.php
sudo sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sudo sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sudo sed -i "s/password_here/$DB_PASS/" /var/www/html/config.php

 #Importamos el script SQL de la base de datos
sudo mysql -u root < /tmp/iaw-practica-lamp/db/database.sql

```
1. Con el comando `sed` se modifica el archivo `config.php` para que contenga los datos proporcionados en el archivo `env`
2. Se importa el script SQL del archivo `database.sql` que crea la base de datos
```bash

# Creamos el usuario de la base de datos y le asignamos privilegios
sudo mysql -u root <<< "DROP USER IF EXISTS $DB_USER@'%'"
sudo mysql -u root <<< "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASS'"
sudo mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%'"
```
Con el comando `mysql` se crea el usuario utilizando sentencias sql directas junto a `<<<`
1. Se elimina el usuario si ya existe
2. Se crea el usuario junto a su contraseña
3. Se le dan todos los permisos al usuario sobre la base de datos
```bash

semanage fcontext -a -t httpd_sys_script_exec_t "/var/www/html(/.*)?"
```
* Con el comando `semanage` administramos las politicas de seguridad.
* `fcontext`: se utiliza para gestionar los contextos de archivos junto al parametro `-a` añade una nueva entrada al archivo y `-t` establece el tipo de contexto al valor. 
* `"/var/www/html(/.*)?"`: especifica donde aplicar el contexto.
```bash
restorecon -Rv /var/www/htmlpractica01/scripts/deploy.sh
```
* Con el comando `restorecon` restauramos los contextos de seguridad del archivo seleccionado.
