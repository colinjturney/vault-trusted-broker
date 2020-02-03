#!/bin/bash

ssh-keygen -m PEM -t rsa -b 4096 -f ./jenkins-master-id_rsa -q -N "" -C "jenkins-master"
