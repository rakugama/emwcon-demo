FROM "docker-registry.wikimedia.org/dev/stretch-php72-fpm-apache2-blubber"

USER "root"
ENV HOME="/root"
RUN groupadd -o -g "65533" -r "somebody" && useradd -l -o -m -d "/home/somebody" -r -g "somebody" -u "65533" "somebody" && mkdir -p "/var/www/html" && chown "65533":"65533" "/var/www/html" && mkdir -p "/opt/lib" && chown "65533":"65533" "/opt/lib"
RUN groupadd -o -g "900" -r "runuser" && useradd -l -o -m -d "/home/runuser" -r -g "runuser" -u "900" "runuser"
USER "somebody"
ENV HOME="/home/somebody"
WORKDIR "/var/www/html"

COPY --chown=65533:65533 ["./core", "./"]
RUN composer update --no-dev
RUN mkdir -p /tmp/php
COPY --chown=65533:65533 [".htaccess", "LocalSettings.php", "./"]
COPY --chown=65533:65533 ["./setup.sh", "/var/config/setup.sh"]
