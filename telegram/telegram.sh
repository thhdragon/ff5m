#!/bin/bash

# Run
# bash <(wget --cache=off -q -O - https://github.com/dra1ex/ff5m/raw/refs/heads/main/telegram/telegram.sh)

# Remove unofficial docker containers
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt remove $pkg; done

# Add Docker's official GPG key:
apt update
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update 
apt upgrade -y

# Install Docker from official source
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

useradd -m -G docker ff5m
chsh ff5m -s /bin/bash

systemctl enable docker
systemctl restart docker

cd ~ff5m

cat > install.sh <<EOF
#!/bin/bash
cd $(pwd) || { echo "Failed to open home directory."; exit 1; }
read -p "Enter the name of the directory where the bot will be stored [tg-bot-1]: " bot_name
if [ "\${bot_name}" == "" ]; then bot_name="tg-bot-1"; fi
mkdir -p \${bot_name}
cd \${bot_name} || { echo "Failed to open directory."; exit 1; }

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
