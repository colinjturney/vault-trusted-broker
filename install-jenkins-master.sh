#!/bin/bash

# Install Java
sudo apt-get update -y
sudo apt-get --assume-yes install openjdk-11-jre

PATH_NEW=${PATH}:/usr/lib/jbm/java-11-openjdk-amd64/bin

sudo echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/bin/java"' > /etc/environment
sudo echo "PATH=${PATH_NEW}" >> /etc/environment

PATH=${PATH_NEW}
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/bin/java"

# Install Jenkins

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install -y jenkins

# Generate SSH key to access worker node

mkdir /var/lib/jenkins/.ssh/
chown -R jenkins:jenkins /var/lib/jenkins/.ssh/

cp /vagrant/jenkins-master-id_rsa.pub /var/lib/jenkins/.ssh/id_rsa.pub
cp /vagrant/jenkins-master-id_rsa /var/lib/jenkins/.ssh/id_rsa

# Below is important for using the same Jenkins-Crumb across different sessions- a hack for getting the configuration to automate and is not a recommended practice.

echo 'JAVA_ARGS="$JAVA_ARGS -Dhudson.security.csrf.DefaultCrumbIssuer.EXCLUDE_SESSION_ID=true"' >> /etc/default/jenkins

service jenkins restart
