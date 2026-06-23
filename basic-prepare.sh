#!/usr/bin/env bash

#Update and upgrade new system
#sudo apt update -y && sudo apt upgrade -y

#Change default OpenSSH port to custom 10122 port-ssh
FILE="/opt/test/test.txt"
sed -i 's/^#Port 22$/Port 10122/' "$FILE"
