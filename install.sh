#!/bin/bash

echo "📦 Instalador automático do bot"

# Nome padrão da pasta
BOT_NAME="meu_bot"
read -p "Digite o nome da pasta do bot (pressione Enter para '$BOT_NAME'): " INPUT_NAME
if [ ! -z "$INPUT_NAME" ]; then
  BOT_NAME="$INPUT_NAME"
fi

# Criar pasta e entrar nela
mkdir -p "$BOT_NAME"
cd "$BOT_NAME" || exit

# Link do ZIP do bot
BOT_ZIP_URL="https://github.com/Henrique28122000/app1/raw/refs/heads/main/cenira.zip"

# Baixar o ZIP
echo "⬇️ Baixando o bot..."
curl -L -o bot.zip "$BOT_ZIP_URL"

# Verificar se unzip está instalado
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

# Remover o ZIP
rm -f bot.zip

# Solicitar links ao usuário
echo ""
read -p "Digite o link para config.json: " LINK_CONFIG
read -p "Digite o link para menu.json: " LINK_MENU

# Criar links.json dentro da pasta atual
cat > links.json <<EOL
{
  "config": "$LINK_CONFIG",
  "menu": "$LINK_MENU"
}
EOL

echo ""
echo "✅ Bot instalado com sucesso na pasta '$BOT_NAME'!"
echo "📌 Para rodar o bot, digite:"
echo "cd $BOT_NAME"
echo "node index.js"
echo ""
echo "🚀 Pronto para uso!"
