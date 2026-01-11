#!/bin/bash

# USO:
# sudo ./deploy.sh dominio.com https://site.com/site.zip

set -e

DOMINIO=$1
ZIPURL=$2

if [ -z "$DOMINIO" ] || [ -z "$ZIPURL" ]; then
  echo "Uso: sudo ./deploy.sh dominio.com https://site.com/site.zip"
  exit 1
fi

WEBROOT="/var/www/$DOMINIO"

echo "== Atualizando sistema =="
sed -i '/cdrom/d' /etc/apt/sources.list
apt update -y && apt upgrade -y

echo "== Instalando pacotes =="
apt install -y nginx mariadb-server unzip curl software-properties-common \
ca-certificates certbot python3-certbot-nginx

echo "== PHP 8.1 =="
add-apt-repository ppa:ondrej/php -y
apt update -y
apt install -y php8.1 php8.1-fpm php8.1-cli php8.1-mysql php8.1-curl \
php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-intl php8.1-bcmath

echo "== phpMyAdmin =="
apt install -y phpmyadmin

systemctl enable nginx mariadb php8.1-fpm
systemctl restart nginx mariadb php8.1-fpm

echo "== Criando estrutura do site =="
mkdir -p $WEBROOT/public
cd /tmp
rm -f site.zip
wget -O site.zip "$ZIPURL"
unzip -oq site.zip -d $WEBROOT/public

chown -R www-data:www-data $WEBROOT
chmod -R 755 $WEBROOT

# =========================
# DETECTA ROOT CORRETO
# =========================
ROOT="$WEBROOT/public"
if [ -d "$WEBROOT/public/api" ]; then
  ROOT="$WEBROOT/public/api"
fi

echo "== Root detectado: $ROOT =="

# =========================
# phpMyAdmin (symlink seguro)
# =========================
ln -sfn /usr/share/phpmyadmin "$ROOT/phpmyadmin"
chown -R www-data:www-data /usr/share/phpmyadmin

echo "== NGINX vhost =="
cat > /etc/nginx/sites-available/$DOMINIO <<EOF
server {
    listen 80;
    server_name $DOMINIO;

    root $ROOT;
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

ln -sfn /etc/nginx/sites-available/$DOMINIO /etc/nginx/sites-enabled/$DOMINIO

nginx -t
systemctl reload nginx

echo "== SSL Let's Encrypt (se DNS estiver pronto) =="
certbot --nginx -d $DOMINIO \
  --non-interactive --agree-tos -m admin@$DOMINIO || \
echo "SSL não emitido (DNS ainda não propagado)"

echo "=============================="
echo "SITE:        http://$DOMINIO"
echo "phpMyAdmin:  http://$DOMINIO/phpmyadmin"
echo "=============================="
