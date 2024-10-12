#!/bin/bash

# Set hosts file
sed -i "/127.0.2.1/d" /etc/hosts

cat <<EOF | tee -a /etc/hosts > /dev/null
172.16.1.101 kibana.example.com logstash.example.com
172.16.1.101 elastic01.example.com elastic01
172.16.1.102 elastic02.example.com elastic02
172.16.1.103 elastic03.exampll.com elastic03
172.16.1.111 kafka01.example.com kafka01
172.16.1.112 kafka02.example.com kafka02
172.16.1.113 kafka03.exampll.com kafka03
EOF

# Enable ssh password authentication
echo "Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

apt install -qq sshpass

chown -R vagrant:vagrant /opt
