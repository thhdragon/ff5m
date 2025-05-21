#!/bin/bash

# Run
# bash <(wget --cache=off -q -O - https://github.com/dra1ex/ff5m/raw/refs/heads/main/telegram/telegram.sh)

apt update 
apt upgrade -y
apt install docker.io docker-compose docker sudo -y

useradd -m -G docker ff5m
chsh ff5m -s /bin/bash

systemctl enable docker
systemctl restart docker

cd ~ff5m

cat > install.sh <<EOF
#!/bin/bash
read -p "Enter the name of the directory where the bot will be stored [tg-bot-1]: " bot_name
if [ "\${bot_name}" == "" ]; then bot_name="tg-bot-1"; fi
mkdir -p \${bot_name}
cd \${bot_name}

echo "The bot is installed in the directory $(pwd)/\${bot_name}"
mkdir -p config log timelapse_finished timelapse 
wget --cache=off -q -O ../ff5m.sh https://raw.githubusercontent.com/dra1ex/ff5m/refs/heads/main/telegram/ff5m.sh
chmod +x ../ff5m.sh
wget --cache=off -q -O docker-compose.yml https://raw.githubusercontent.com/dra1ex/ff5m/refs/heads/main/telegram/docker-compose.yml
wget --cache=off -q -O config/telegram.conf https://github.com/dra1ex/ff5m/raw/refs/heads/main/telegram/telegram.conf
chmod 777 config log timelapse_finished timelapse

echo "1. Go to https://t.me/BotFather
2. /newbot
3. Enter any name you like
4. Enter the bot name, for example, ff5msuper_bot - make sure it ends with _bot.
5. You will receive a long ID - you need to specify it in the bot settings under the bot_token parameter."

read -p "Enter bot_token: " bot_token

sed -i "s|bot_token: 1111111111:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|bot_token: \${bot_token}|" config/telegram.conf
docker compose up -d

echo "Go to your bot via Telegram.
It will write: Unauthorized access detected with chat_id:
Enter the received number into chat_id."

read -p "Enter chat_id: " chat_id 
docker compose down
sed -i "s|chat_id: 111111111|chat_id: \${chat_id}|" config/telegram.conf 
docker compose up -d
read -p "Do you need to create another bot? [y/N]: " vopros
if [ "\${vopros}" == "y" ] || [ "\${vopros}" == "Y" ]; then cd; ./install.sh; fi
EOF

chmod +x install.sh
su - ff5m ./install.sh
