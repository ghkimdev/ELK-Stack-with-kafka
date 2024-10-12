#!/bin/bash

# Centos
#cp -ar /etc/pki/tls/cert/ca-bundle.crt /etc/pki/tls/cert/ca-bundle.crt.bak
#cp -ar /etc/pki/tls/cert/ca-bundle.trust.crt /etc/pki/tls/cert/ca-bundle.trust.crt.bak

#yum install ca-certificates
#update-ca-trust force-enable
#cp /opt/certs/ca/ca.crt /etc/pki/ca-trust/source/anchors/
#update-ca-trust extract

#cat /opt/certs/ca/ca.crt >> /etc/pki/tls/cert/ca-bundle.crt 

# Ubuntu
sudo apt-get install -y ca-certificates
sudo cp /opt/certs/ca/ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
