# [Download image]
FROM debian:buster
MAINTAINER Diane Champdavoine

# [Environment variables]
ENV AUTOINDEX=on
ENV DEBIAN_FRONTEND=noninteractive

# [Download packages]
RUN apt-get update && apt-get install -y \
	apt-utils \
	gettext-base \
	mariadb-server \
	nginx \
	openssl \
	php7.3-common \
	php7.3-fpm \
	php7.3-mysql \
	php7.3-mbstring \
	wget \
	&& rm -rf /var/lib/apt/lists/*

# [Configuration SSL certificate]
RUN openssl req -x509 -nodes -days 365 -subj "/C=FR/ST=Paris/O=42/CN=dchampda" -addext "subjectAltName=DNS:localhost" -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt;

# [Configuration nginx]
COPY /srcs/nginx/nginx.conf /tmp
COPY /srcs/php/www.conf /etc/php/7.3/fpm.pool.d/
RUN cp /tmp/nginx.conf /etc/nginx/sites-available/localhost \
	&& ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/ \
	&& mkdir /var/www/localhost \
	&& rm /etc/nginx/sites-available/default \
	&& rm /etc/nginx/sites-enabled/default \
	&& chown www-data:www-data /var/www/* \
	&& chmod 755 /var/www/*

# [Configuration phpmyadmin]
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
	&& tar -zxvf phpMyAdmin-5.0.2-all-languages.tar.gz \
	&& mv  phpMyAdmin-5.0.2-all-languages /var/www/localhost/phpMyAdmin \
	&& rm -f /var/www/localhost/phpMyAdmin/config.sample.inc.php \
	&& rm -f phpMyAdmin-5.0.2-all-languages.tar.gz
COPY /srcs/php/config.inc.php /var/www/localhost/phpMyAdmin/

# [Configuration wordpress]
RUN wget https://wordpress.org/latest.tar.gz \
	&& tar -xvzf latest.tar.gz \
	&& mv /wordpress/ /var/www/localhost/ \
	&& rm -f latest.tar.gz \
	&& rm -f /var/www/localhost/wordpress/wp-config-sample.php
COPY /srcs/wordpress/wp-config.php /var/www/localhost/wordpress/

# [Configuration mysql]
COPY /srcs/mysql/mariadb_user_creation.sql /usr/share/mysql/
COPY /srcs/wordpress/wordpress_db.sql /var/www/localhost/wordpress/
RUN service mysql start \
	&& mysql -u root < /usr/share/mysql/mariadb_user_creation.sql \
	&& mysql wordpress_db -u root < /var/www/localhost/wordpress/wordpress_db.sql

# [Prepare to launch]
COPY /srcs/launch.sh .
CMD envsubst $'AUTOINDEX' < /tmp/nginx.conf > /etc/nginx/sites-available/localhost \
	&& bash ./launch.sh \
	&& tail -f /dev/null

EXPOSE 80 443