#!/bin/bash
set -e

# 1. System update and install dependencies
sudo yum update -y
sudo yum install -y wget tar java-17-amazon-corretto

# 2. Create base directory and navigate
sudo mkdir -p /app
cd /app

# 3. Define working Nexus version
NEXUS_VERSION="3.78.2-04"
NEXUS_FILENAME="nexus-unix-x86-64-${NEXUS_VERSION}.tar.gz"
NEXUS_URL="https://download.sonatype.com/nexus/3/${NEXUS_FILENAME}"

echo "⏬ Attempting download: ${NEXUS_URL}"
wget -O nexus.tar.gz "${NEXUS_URL}"

if [ $? -ne 0 ]; then
  echo "❌ Download failed for Nexus version ${NEXUS_VERSION}. Exiting."
  exit 1
fi

# 4. Extract and rename
sudo tar -xzf nexus.tar.gz
sudo mv "nexus-${NEXUS_VERSION}" nexus
sudo mkdir -p /app/sonatype-work

# 5. Create nexus user if needed
if ! id nexus &>/dev/null; then
  sudo adduser nexus
fi

# 6. Set permissions
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# 7. Ensure Nexus runs as nexus user
echo 'run_as_user="nexus"' | sudo tee /app/nexus/bin/nexus.rc

# 8. Create systemd service
sudo tee /etc/systemd/system/nexus.service > /dev/null << 'EOL'
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# 9. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# 10. Output final info
echo "✅ Nexus ${NEXUS_VERSION} installed successfully!"
echo "Access it at: http://<your-ec2-public-ip>:8081"
echo "Admin password is in: /app/sonatype-work/nexus3/admin.password"
