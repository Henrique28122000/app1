#!/bin/bash

echo "📦 Instalador automático do bot (Node.js + links.json)"

# Nome da pasta principal onde será baixado o ZIP
BOT_NAME="meu_bot"
read -p "Digite o nome da pasta do bot (pressione Enter para '$BOT_NAME'): " INPUT_NAME
if [ -n "$INPUT_NAME" ]; then
  BOT_NAME="$INPUT_NAME"
fi

# Criar pasta principal e entrar nela
mkdir -p "$BOT_NAME"
cd "$BOT_NAME" || exit
BASE_DIR=$(pwd)
echo "➡ Pasta principal: $BASE_DIR"

# URL do arquivo ZIP
FILE_URL="https://rendfacilinvert.online/menu/bot.zip"
FILE_NAME="bot.zip"

# Baixar o ZIP
echo "⬇️ Baixando o bot..."
curl -L -o "$FILE_NAME" "$FILE_URL"

# Instalar unzip se necessário
if ! command -v unzip >/dev/null 2>&1; then
  echo "🔹 Instalando unzip..."
  if [ -f /system/build.prop ]; then
    pkg update -y
    pkg install -y unzip
  else
    sudo apt update
    sudo apt install -y unzip
  fi
fi

# Extrair o ZIP
echo "📂 Extraindo bot..."
unzip -o "$FILE_NAME"
rm -f "$FILE_NAME"

# Detectar a pasta que contém package.json ou index.js
BOT_DIR=$(find . -type f \( -name "package.json" -o -name "index.js" \) -exec dirname {} \; | head -n 1)
if [ -z "$BOT_DIR" ]; then
  BOT_DIR="$BASE_DIR"
fi
echo "➡ Pasta do bot detectada: $BOT_DIR"

# Entrar na pasta do bot
cd "$BOT_DIR" || exit

# Instalar Node.js se necessário
if ! command -v node >/dev/null 2>&1; then
  echo "🔹 Instalando Node.js..."
  if [ -f /system/build.prop ]; then
    pkg install -y nodejs
  elif [ -f /etc/debian_version ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
  else
    echo "⚠️ Sistema não identificado. Instale Node.js manualmente."
    exit 1
  fi
else
  echo "✅ Node.js já instalado: $(node -v)"
fi

# Criar links.json **dentro da pasta do bot**
read -p "Digite o link para config.json: " LINK_CONFIG
read -p "Digite o link para menu.json: " LINK_MENU

cat > links.json <<EOL
{
  "config": "$LINK_CONFIG",
  "menu": "$LINK_MENU"
}
EOL

echo ""
echo "✅ Bot instalado com sucesso na pasta '$BOT_DIR'!"
echo "📌 Para rodar o bot:"
echo "cd $BOT_DIR"
echo "node index.js"
echo "🚀 Pronto para uso!"
