#!/bin/bash

HOSTNAME=$(hostname)
ELASTIC_VERSION=8.15.1
ELASTIC_HOME=/opt/elasticsearch
ELASTIC_CONFIG=${ELASTIC_HOME}/config/elasticsearch.yml
CERTS_HOME=/opt/certs



echo "[TASK 1] Set Max map count"
cat <<EOF | sudo tee -a /etc/sysctl.conf > /dev/null
vm.max_map_count = 262144
EOF

sudo sysctl -p


cd /opt
echo "[TASK 2] Download Elasticsearch"
wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz
tar -xzf elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz
mv elasticsearch-${ELASTIC_VERSION} elasticsearch
rm -rf elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz


if [ $(hostname) == "elastic01" ]
then
	echo "[TASK 3] Create SSL Certificate"
	mkdir -p ${CERTS_HOME}
	cd ${CERTS_HOME}
	cat <<EOF | tee ${CERTS_HOME}/instance.yml > /dev/null
instances:
  - name: 'elastic01'
    dns: [ 'elastic01.example.com' ]
  - name: "elastic02"
    dns: [ 'elastic02.example.com' ]
  - name: "elastic03"
    dns: [ 'elastic03.example.com' ]
  - name: 'my-kibana'
    dns: [ 'kibana.example.com' ]
  - name: 'my-logstash'
    dns: [ 'logstash.example.com' ]
EOF

	${ELASTIC_HOME}/bin/elasticsearch-certutil ca --pem --out ${CERTS_HOME}/ca.zip > /dev/null
	unzip -q ${CERTS_HOME}/ca.zip

	${ELASTIC_HOME}/bin/elasticsearch-certutil cert --ca-cert ${CERTS_HOME}/ca/ca.crt --ca-key ${CERTS_HOME}/ca/ca.key --in /opt/certs/instance.yml --pem --out ${CERTS_HOME}/certs.zip > /dev/null
	unzip -q ${CERTS_HOME}/certs.zip
	cp -r ${CERTS_HOME} ${ELASTIC_HOME}/config/
else
	echo "[TASK 3] Copy SSL Certificate"
	sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r elastic01:${CERTS_HOME} ${CERTS_HOME}
	cp -r ${CERTS_HOME} ${ELASTIC_HOME}/config/certs
fi

echo "[TASK 4] Update Config file"
cat <<EOF | tee -a ${ELASTIC_CONFIG} > /dev/null
cluster.name: my-cluster
node.name: ${HOSTNAME}
network.host: ${HOSTNAME}.example.com
discovery.seed_hosts: ["elastic01","elastic02","elastic03"]
cluster.initial_master_nodes: ["elastic01"]

xpack.security.enabled: true
xpack.security.http.ssl.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.key: certs/${HOSTNAME}/${HOSTNAME}.key
xpack.security.http.ssl.certificate: certs/${HOSTNAME}/${HOSTNAME}.crt
xpack.security.http.ssl.certificate_authorities: certs/ca/ca.crt
xpack.security.transport.ssl.key: certs/${HOSTNAME}/${HOSTNAME}.key
xpack.security.transport.ssl.certificate: certs/${HOSTNAME}/${HOSTNAME}.crt
xpack.security.transport.ssl.certificate_authorities: certs/ca/ca.crt
EOF

echo "[TASK 5] Create Start & Stop script"
touch ${ELASTIC_HOME}/startup.sh
touch ${ELASTIC_HOME}/shutdown.sh 

cat <<EOF | tee ${ELASTIC_HOME}/startup.sh > /dev/null
#!/bin/bash
${ELASTIC_HOME}/bin/elasticsearch -d -p es.pid
EOF

cat <<EOF | tee ${ELASTIC_HOME}/shutdown.sh > /dev/null
#!/bin/bash
pkill -F ${ELASTIC_HOME}/es.pid
EOF

chmod +x ${ELASTIC_HOME}/startup.sh
chmod +x ${ELASTIC_HOME}/shutdown.sh


