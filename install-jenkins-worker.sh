#!/bin/bash

# Install Java
sudo apt-get update -y
sudo apt-get --assume-yes install openjdk-11-jre

PATH_NEW=${PATH}:/usr/lib/jbm/java-11-openjdk-amd64/bin

sudo echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/bin/java"' > /etc/environment
sudo echo "PATH=${PATH_NEW}" >> /etc/environment

PATH=${PATH_NEW}
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/bin/java"

sudo apt-get --assume-yes install git openssh-server

# Add Jenkins user

sudo useradd --system --shell /bin/bash "jenkins"

mkdir -p /home/jenkins/.ssh/
mkdir -p /home/jenkins/jenkins
chown -R jenkins:jenkins /home/jenkins/jenkins
chown -R jenkins:jenkins /home/jenkins/.ssh

echo $(cat /vagrant/jenkins-master.pub) >> /home/jenkins/.ssh/authorized_keys
chmod 0600 /home/jenkins/.ssh/authorized_keys
chown -R jenkins:jenkins /home/jenkins/.ssh/authorized_keys
