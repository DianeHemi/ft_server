#! /bin/bash

service nginx restart
service php7.3-fpm start
service mysql restart

echo ""
echo "Open localhost : https://localhost/"
echo "Access phpMyAdmin : https://localhost/phpMyAdmin/"
echo "Access Wordpress : https://localhost/wordpress/"
echo "Access Wordpress - back : https://localhost/wordpress/wp-admin/"
echo "User : admin - psw : admin"