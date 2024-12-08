#!/bin/sh
# Update and install necessary dependencies
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget

# Download and install OpenSSL
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb

# Create miner directory and navigate into it
mkdir -p ~/ccminer
cd ~/ccminer

# Fetch the latest release from GitHub
GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/Android-Mining/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets | .[] | .browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets | .[] | .name")

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"

wget ${GITHUB_DOWNLOAD_URL} -O ~/ccminer/ccminer
wget https://raw.githubusercontent.com/Purple-Palm/Quick-Setup/main/config.json -O ~/ccminer/config.json
chmod +x ~/ccminer/ccminer

# Ask for a custom username
echo "Enter username for this miner (e.g., hmd_01): "
read CUSTOM_USERNAME

# Update the config.json with the custom username
sed -i "s/UNNAMED_MINER/${CUSTOM_USERNAME}/g" ~/ccminer/config.json

# Create a start script
cat << EOF > ~/ccminer/start.sh
#!/bin/sh
~/ccminer/ccminer -c ~/ccminer/config.json
EOF
chmod +x start.sh

# Final instructions
echo "Setup nearly complete."
echo "Edit the config with \"nano ~/ccminer/config.json\" if necessary."
echo "Start the miner with \"cd ~/ccminer; ./start.sh\"."
