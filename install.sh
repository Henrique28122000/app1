#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "📦 Instalador automático do bot"

# Nome da pasta do bot
BOT_NAME="meu_bot"
read -p "Digite o nome da pasta do bot (pressione Enter para '$BOT_NAME'): " INPUT_NAME
if [ -n "$INPUT_NAME" ]; then
  BOT_NAME="$INPUT_NAME"
fi

# Criar pasta e entrar nela
mkdir -p "$BOT_NAME"
cd "$BOT_NAME" || exit
BOT_DIR=$(pwd)
echo "➡ Pasta do bot: $BOT_DIR"

# ID do arquivo no Google Drive
FILE_ID="1ARuFHF_Dzg73NQsqMo0ltoMXguvWTK6D"
FILE_NAME="bot.zip"

# Função para baixar do Google Drive (arquivos grandes)
download_from_gdrive() {
  echo "⬇️ Baixando bot do Google Drive..."
  CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
    "https://docs.google.com/uc?export=download&id=${FILE_ID}" -O- | \
    sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
  
  wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILE_ID}" \
    -O ${FILE_NAME}
  rm -f /tmp/cookies.txt
}

# Baixar o ZIP
download_from_gdrive

# Verificar se unzip está instalado
if ! command -v unzip >/dev/null 2>&1; then
  echo "🔹 Instalando unzip..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y unzip
  elif [[ "$OSTYPE" == "android"* ]]; then
    pkg install -y unzip
  else
    echo "⚠ Instale manualmente o 'unzip'."
    exit 1
  fi
fi

# Extrair o ZIP
echo "📂 Extraindo bot..."
unzip -o bot.zip -d .
rm -f bot.zip

# Instalar Node.js se não existir
if ! command -v node >/dev/null 2>&1; then
  echo "🔹 Node.js não encontrado, instalando..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif [[ "$OSTYPE" == "android"* ]]; then
    pkg install -y nodejs
  else
    echo "⚠ Instale Node.js manualmente."
    exit 1
  fi
else
  echo "✅ Node.js já instalado"
fi

# Rodar npm install
if [ -f "package.json" ]; then
  echo "📦 Instalando dependências npm..."
  npm install
fi

# Solicitar links ao usuário e criar links.json
read -p "Digite o link para config.json: " LINK_CONFIG
read -p "Digite o link para menu.json: " LINK_MENU

cat > links.json <<EOL
{
  "config": "$LINK_CONFIG",
  "menu": "$LINK_MENU"
}
EOL

echo ""
echo "✅ Bot instalado com sucesso na pasta '$BOT_NAME'!"
echo "📌 Para rodar o bot:"
echo "cd $BOT_DIR"
echo "node index.js"
echo "🚀 Pronto para uso!"
