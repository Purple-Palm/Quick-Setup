#!/bin/sh
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb
mkdir ~/ccminer
cd ~/ccminer

# Fetch the latest release info
GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/Android-Mining/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets | .[] | .browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets | .[] | .name")

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"
wget ${GITHUB_DOWNLOAD_URL} -O ~/ccminer/ccminer
wget https://raw.githubusercontent.com/Purple-Palm/Quick-Setup/main/config.json -O ~/ccminer/config.json
chmod +x ~/ccminer/ccminer

# Prompt for miner username
while true; do
    echo -n "Enter username for this miner (e.g., hmd_01): "
    read MINER_USERNAME
    if [ -n "$MINER_USERNAME" ]; then
        break
    else
        echo "Username cannot be empty. Please try again."
    fi
done

# Update config.json with the provided username
sed -i "s/UNNAMED_MINER/$MINER_USERNAME/" ~/ccminer/config.json

# Create start.sh
cat << EOF > ~/ccminer/start.sh
#!/bin/sh
~/ccminer/ccminer -c ~/ccminer/config.json
EOF
chmod +x start.sh

echo "Setup nearly complete."
echo "Edit the config with \"nano ~/ccminer/config.json\" if needed."
echo "To start the miner, run \"cd ~/ccminer; ./start.sh\"."
