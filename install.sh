#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "📦 Instalador automático do bot"

# Nome padrão da pasta
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

# Link do ZIP do bot (verifique se este link é válido)

wget --no-check-certificate 'https://drive.google.com/uc?export=download&id=1FrY9D1ntW_aksEcJ-0zU8sPahhBmkm-v' -O bot.zip

# Baixar o ZIP
echo "⬇️ Baixando o bot..."

# Verificar se o ZIP foi baixado
if [ ! -f bot.zip ]; then
  echo "❌ Falha ao baixar bot.zip"
  exit 1
fi

# Instalar unzip se necessário
if ! command -v unzip >/dev/null 2>&1; then
    echo "🔹 Instalando unzip..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y unzip
    elif [[ "$OSTYPE" == "android"* ]]; then
        pkg install -y unzip
    else
        echo "⚠ Instale manualmente o 'unzip' no seu sistema."
        exit 1
    fi
fi

# Extrair
echo "📂 Extraindo arquivos..."
unzip -o bot.zip -d .
rm -f bot.zip

# Solicitar links ao usuário
echo ""
read -p "Digite o link para config.json: " LINK_CONFIG
read -p "Digite o link para menu.json: " LINK_MENU

# Criar links.json
cat > links.json <<EOL
{
  "config": "$LINK_CONFIG",
  "menu": "$LINK_MENU"
}
EOL

# Baixar config.json e menu.json
if [ -n "$LINK_CONFIG" ]; then
  echo "⬇️ Baixando config.json..."
  curl -L -o config.json "$LINK_CONFIG"
fi

if [ -n "$LINK_MENU" ]; then
  echo "⬇️ Baixando menu.json..."
  curl -L -o menu.json "$LINK_MENU"
fi

echo ""
echo "✅ Bot instalado com sucesso na pasta '$BOT_NAME'!"
echo "📌 Arquivos dentro da pasta do bot:"
ls -l
echo ""
echo "📌 Para rodar o bot, digite:"
echo "cd $BOT_DIR"
echo "node index.js"
echo ""
echo "🚀 Pronto para uso!"
