#!/bin/bash
set -e

# Variables
TOMCAT_VERSION="9.0.108"
TOMCAT_TAR="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
DOWNLOAD_URL="https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_TAR}"
USERNAME="Jaanu"
PASSWORD="Nitheesh@01"

echo "Installing Java 11 (Amazon Corretto)..."
sudo dnf install java-11-amazon-corretto -y

echo "Downloading Apache Tomcat ${TOMCAT_VERSION}..."
wget "${DOWNLOAD_URL}"

echo "Extracting Tomcat..."
tar -zxvf "${TOMCAT_TAR}"

cd "apache-tomcat-${TOMCAT_VERSION}"

echo "Configuring tomcat-users.xml..."
cp conf/tomcat-users.xml conf/tomcat-users.xml.bak
sed -i '/<\/tomcat-users>/ i\<role rolename="manager-gui"/>' conf/tomcat-users.xml
sed -i '/<\/tomcat-users>/ i\<role rolename="manager-script"/>' conf/tomcat-users.xml
sed -i "/<\/tomcat-users>/ i\<user username=\"${USERNAME}\" password=\"${PASSWORD}\" roles=\"manager-gui,manager-script\"/>" conf/tomcat-users.xml

echo "Enabling remote access to Manager app..."
sed -i '21d' webapps/manager/META-INF/context.xml || true
sed -i '22d' webapps/manager/META-INF/context.xml || true

echo "Starting Tomcat..."
sh bin/startup.sh

echo
echo "Tomcat ${TOMCAT_VERSION} installed and started successfully."
echo "Access manager at: http://<your-server-ip>:8080/manager/html"
echo "Username: ${USERNAME}"
echo "Password: ${PASSWORD}"
