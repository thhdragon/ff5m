#!/bin/bash
#
# Run With
# bash <(wget --cache=off -q -O - https://raw.githubusercontent.com/dra1ex/ff5m/refs/heads/main/telegram/telegram.sh)


# Function to check if a command was successful
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Function to check Linux distribution
check_distro() {
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] && [ "$ID" != "debian" ]; then
        echo "Error: This script only supports Ubuntu and Debian. Current distribution: $ID"
        exit 1
    fi
    echo "Detected distribution: $ID"
}

# Progress message
echo "Starting Docker and Telegram bot installation..."

# Check distribution
check_distro

# Check if user ff5m already exists
if id "ff5m" >/dev/null 2>&1; then
    echo "User ff5m already exists, skipping user creation."
else
    useradd -m -G docker ff5m
    check_error "Failed to create user ff5m"
    chsh ff5m -s /bin/bash
    check_error "Failed to set shell for ff5m"
    echo "Created user ff5m."
fi

# Prompt for removing unofficial Docker packages
echo "WARNING: This script will remove unofficial Docker packages (docker.io, docker-doc, docker-compose, docker-compose-v2, podman-docker, containerd, runc)."
read -p "Do you want to continue with removal? [y/N]: " confirm_remove
if [ "$confirm_remove" != "y" ] && [ "$confirm_remove" != "Y" ]; then
    echo "Installation aborted by user."
    exit 1
fi

# Remove unofficial Docker packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    if dpkg -l | grep -q "$pkg"; then
        apt remove -y $pkg
        check_error "Failed to remove package $pkg"
        echo "Removed package $pkg."
    else
        echo "Package $pkg not installed, skipping."
    fi
done

# Update package lists
echo "Updating package lists..."
apt update
check_error "Failed to update package lists"
apt upgrade -y
check_error "Failed to upgrade packages"

# Install prerequisites
echo "Installing prerequisites..."
apt install ca-certificates curl -y
check_error "Failed to install prerequisites"

# Create directory for Docker GPG key
install -m 0755 -d /etc/apt/keyrings
check_error "Failed to create /etc/apt/keyrings directory"

# Add Docker's official GPG key
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    echo "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/$ID/gpg -o /etc/apt/keyrings/docker.asc
    check_error "Failed to download Docker GPG key"
    chmod a+r /etc/apt/keyrings/docker.asc
    check_error "Failed to set permissions for Docker GPG key"
else
    echo "Docker GPG key already exists, skipping."
fi

# Add Docker repository based on distribution
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "Adding Docker repository..."
    . /etc/os-release
    if [ "$ID" = "ubuntu" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif [ "$ID" = "debian" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $VERSION_CODENAME stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    check_error "Failed to add Docker repository"
else
    echo "Docker repository already configured, skipping."
fi

# Update package lists after adding repository
echo "Updating package lists with Docker repository..."
apt update
check_error "Failed to update package lists with Docker repository"

# Install Docker
echo "Installing Docker..."
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
check_error "Failed to install Docker"

# Enable and restart Docker service
if ! systemctl is-active --quiet docker; then
    echo "Enabling and starting Docker service..."
    systemctl enable docker
    check_error "Failed to enable Docker service"
    systemctl restart docker
    check_error "Failed to restart Docker service"
else
    echo "Docker service already enabled and running."
fi

# Switch to ff5m user home directory
cd ~ff5m
check_error "Failed to switch to ff5m home directory"

# Create install.sh script
echo "Creating install.sh script..."
cat > install.sh <<EOF
#!/bin/bash

check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

cd \$(pwd) || { echo "Failed to open home directory."; exit 1; }
read -p "Enter the name of the directory where the bot will be stored [tg-bot-1]: " bot_name
if [ "\${bot_name}" == "" ]; then bot_name="tg-bot-1"; fi
if [ -d "\${bot_name}" ]; then
    echo "Directory \${bot_name} already exists, skipping creation."
else
    mkdir -p \${bot_name}
    check_error "Failed to create directory \${bot_name}"
fi
cd \${bot_name} || { echo "Failed to open directory."; exit 1; }

echo "The bot is installed in the directory \$(pwd)"
for dir in config log timelapse_finished timelapse; do
    if [ -d "\${dir}" ]; then
        echo "Directory \${dir} already exists, skipping."
    else
        mkdir -p \${dir}
        check_error "Failed to create directory \${dir}"
    fi
done

if [ ! -f ../ff5m.sh ]; then
    wget --cache=off -q -O ../ff5m.sh https://raw.githubusercontent.com/dra1ex/ff5m/refs/heads/main/telegram/ff5m.sh
    check_error "Failed to download ff5m.sh"
    chmod +x ../ff5m.sh
    check_error "Failed to set executable permissions for ff5m.sh"
else
    echo "ff5m.sh already exists, skipping download."
fi

if [ ! -f docker-compose.yml ]; then
    wget --cache=off -q -O docker-compose.yml https://raw.githubusercontent.com/dra1ex/ff5m/refs/heads/main/telegram/docker-compose.yml
    check_error "Failed to download docker-compose.yml"
else
    echo "docker-compose.yml already exists, skipping download."
fi

if [ ! -f config/telegram.conf ]; then
    wget --cache=off -q -O config/telegram.conf https://github.com/dra1ex/ff5m/raw/refs/heads/main/telegram/telegram.conf
    check_error "Failed to download telegram.conf"
else
    echo "telegram.conf already exists, skipping download."
fi

chmod 777 config log timelapse_finished timelapse
check_error "Failed to set permissions for directories"

echo "1. Go to https://t.me/BotFather
2. /newbot
3. Enter any name you like
4. Enter the bot name, for example, ff5msuper_bot - make sure it ends with _bot.
5. You will receive a long ID - you need to specify it in the bot settings under the bot_token parameter."

read -p "Enter bot_token: " bot_token
if [ -z "\${bot_token}" ]; then
    echo "Error: bot_token cannot be empty."
    exit 1
fi

sed -i "s|bot_token: 1111111111:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|bot_token: \${bot_token}|" config/telegram.conf
check_error "Failed to update bot_token in telegram.conf"

echo "Starting Docker Compose..."
docker compose up -d
check_error "Failed to start Docker Compose"

echo "Go to your bot via Telegram.
It will write: Unauthorized access detected with chat_id:
Enter the received number into chat_id."

read -p "Enter chat_id: " chat_id
if [ -z "\${chat_id}" ]; then
    echo "Error: chat_id cannot be empty."
    exit 1
fi

echo "Stopping Docker Compose..."
docker compose down
check_error "Failed to stop Docker Compose"

sed -i "s|chat_id: 111111111|chat_id: \${chat_id}|" config/telegram.conf
check_error "Failed to update chat_id in telegram.conf"

echo "Restarting Docker Compose..."
docker compose up -d
check_error "Failed to restart Docker Compose"

read -p "Do you need to create another bot? [y/N]: " vopros
if [ "\${vopros}" == "y" ] || [ "\${vopros}" == "Y" ]; then
    cd
    ./install.sh
fi
EOF

chmod +x install.sh
check_error "Failed to set executable permissions for install.sh"

echo "Running install.sh as ff5m user..."
su - ff5m -c "./install.sh"
check_error "Failed to run install.sh as ff5m user"

echo "Installation completed successfully."
