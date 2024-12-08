#!/bin/sh
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget python3

wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb
mkdir ~/ccminer
cd ~/ccminer

# Download latest miner release and config.json
GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/Android-Mining/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets | .[] | .browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets | .[] | .name")

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"
wget ${GITHUB_DOWNLOAD_URL} -O ~/ccminer/ccminer
wget https://raw.githubusercontent.com/Purple-Palm/Quick-Setup/main/config.json -O ~/ccminer/config.json
chmod +x ~/ccminer/ccminer

# Create a Python script to update config.json
cat << 'EOF' > ~/ccminer/update_config.py
import json
import os

# Define the path to the config file
config_path = os.path.expanduser("~/ccminer/config.json")

# Prompt for the miner username
miner_username = input("Enter username for this miner (e.g., hmd_01): ").strip()

if not miner_username:
    print("Error: Username cannot be empty.")
    exit(1)

# Load and update the config
try:
    with open(config_path, "r") as file:
        config = json.load(file)

    # Update the "user" field with the new username
    config["user"] = config["user"].replace("UNNAMED_MINER", miner_username)

    # Write the updated config back to the file
    with open(config_path, "w") as file:
        json.dump(config, file, indent=4)

    print(f"Username updated successfully to: {miner_username}")

except Exception as e:
    print(f"Error updating config: {e}")
    exit(1)
EOF

# Make the Python script executable
chmod +x ~/ccminer/update_config.py

# Create the miner start script
cat << EOF > ~/ccminer/start.sh
#!/bin/sh
~/ccminer/ccminer -c ~/ccminer/config.json
EOF
chmod +x ~/ccminer/start.sh

echo "Setup complete."
echo "To configure your miner, run: python3 ~/ccminer/update_config.py"
echo "To start mining, run: cd ~/ccminer; ./start.sh"
