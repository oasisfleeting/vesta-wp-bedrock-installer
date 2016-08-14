#!/bin/bash

wget https://github.com/roots/bedrock/archive/master.zip
unzip master.zip
rm -f master.zip

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

sudo mv wp-cli.phar /usr/local/bin/wp

cp .env.example .env
wp dotenv salts regenerate


EXPECTED_SIGNATURE=$(wget https://composer.github.io/installer.sig -O - -q)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]
then
    chmod +x composer-setup.php
    php composer-setup.php --install-dir=$HOME --filename=composer
    RESULT=$?
    rm composer-setup.php
    echo $RESULT
else
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

composer update

cd $HOME
wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash
source $HOME/wp-completion.bash
source $HOME/.profile