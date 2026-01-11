#!/bin/bash

# USO:
# ./deploy.sh dominio.com https://site.com/site.zip

DOMINIO=$1
ZIPURL=$2

if [ -z "$DOMINIO" ] || [ -z "$ZIPURL" ]; then
  echo "Uso: ./deploy.sh dominio.com https://site.com/site.zip"
  exit 1
fi

set -e

echo "== Atualizando sistema =="
sed -i '/cdrom/d' /etc/apt/sources.list
apt update && apt upgrade -y

echo "== Instalando pacotes =="
apt install -y nginx mariadb-server unzip curl software-properties-common \
ca-certificates certbot python3-certbot-nginx

echo "== PHP 8.1 =="
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.1 php8.1-fpm php8.1-cli php8.1-mysql php8.1-curl \
php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-intl php8.1-bcmath

systemctl enable nginx mariadb php8.1-fpm
systemctl start nginx mariadb php8.1-fpm

echo "== Criando estrutura do site =="
WEBROOT="/var/www/$DOMINIO"
mkdir -p $WEBROOT/public
cd /tmp
wget -O site.zip $ZIPURL
unzip site.zip -d $WEBROOT/public

chown -R www-data:www-data $WEBROOT
chmod -R 755 $WEBROOT

echo "== NGINX vhost =="
cat > /etc/nginx/sites-available/$DOMINIO <<EOF
server {
    listen 80;
    server_name $DOMINIO www.$DOMINIO;

    root $WEBROOT/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
ln -sf /etc/nginx/sites-available/$DOMINIO /etc/nginx/sites-enabled/


nginx -t
systemctl reload nginx

echo "== SSL Let's Encrypt =="
certbot --nginx -d $DOMINIO -d $DOMINIO --non-interactive --agree-tos -m admin@$DOMINIO

echo "== PRONTO =="
echo "Site disponível em: https://$DOMINIO"
