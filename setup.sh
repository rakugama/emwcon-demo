#!/bin/bash
set -eu

# This should only be run once per deployment.

function sanity_checks {
    # Sanity checks
    if [ -z "$DB_SERVER" ]; then
        echo 'DB_SERVER not set, exiting.'
        exit 1
    fi
    
    if [ -z "$DB_PASS" ]; then
        echo 'DB_PASS not set, exiting.'
        exit 1
    fi
    
    if [ -z "$DB_NAME" ]; then
        echo 'DB_NAME not set, exiting.'
        exit 1
    fi
}    

function wait_for_db {
    local max_attempts=60

    echo "$(date): Waiting for DB to become available"

    for ((attempt=0; attempt<$max_attempts; attempt++)); do
        if mysql -h "$DB_SERVER" -u root -p"$DB_PASS" "$DB_NAME"; then
            echo "$(date): DB is available"
            return
        else
            sleep 1
        fi
    done
    # If we reached here, we had no luck
    echo "$(date): DB not available.  Giving up"
    exit 1
}

function run_install_and_update {
    # install.php won't operate if LocalSettings.php exists, so move it out of the way.
    if [ -f /var/www/html/LocalSettings.php ]; then
        mv /var/www/html/LocalSettings.php /var/www/html/LocalSettings.php.docker.tmp
    fi

    php /var/www/html/maintenance/install.php \
        --dbuser "root" --dbpass "$DB_PASS" --dbname "$DB_NAME" --dbserver "$DB_SERVER" \
        --lang "en" --pass "$WIKI_ADMIN_PASS" \
        "$WIKI_NAME" "$WIKI_ADMIN"
    # We don't need the LocalSettings.php file that was generated by install.php
    rm /var/www/html/LocalSettings.php
    
    # Move back the old LocalSettings if we had moved one!
    if [ -f /var/www/html/LocalSettings.php.docker.tmp ]; then
        mv /var/www/html/LocalSettings.php.docker.tmp /var/www/html/LocalSettings.php
    fi
    
    php /var/www/html/maintenance/update.php --wiki "$DB_NAME" --quick
}

sanity_checks
wait_for_db
run_install_and_update

