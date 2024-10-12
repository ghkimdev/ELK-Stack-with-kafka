#!/bin/bash

KIBANA_VERSION=8.15.1
KIBANA_HOME=/opt/kibana
KIBANA_CONFIG=${KIBANA_HOME}/config/kibana.yml


cd /opt
echo "[TASK 1] Download Kibana"
wget -q https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz
tar -xzf kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz
mv kibana-${KIBANA_VERSION} kibana
rm -rf kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz
 
cp -r /opt/certs ${KIBANA_HOME}/config/

echo "[TASK 2] Set Config file"
cat <<EOF | tee -a ${KIBANA_CONFIG} > /dev/null
server.host: "kibana.example.com"
server.publicBaseUrl: "https://kibana.example.com:5601"
server.name: "my-kibana"

server.ssl.enabled: true
server.ssl.certificate: "${KIBANA_HOME}/config/certs/my-kibana/my-kibana.crt"
server.ssl.key: "${KIBANA_HOME}/config/certs/my-kibana/my-kibana.key"

elasticsearch.hosts: ["https://elastic01.example.com:9200"]
elasticsearch.username: "kibana_system"
elasticsearch.password: "kibana"
elasticsearch.ssl.certificate: "${KIBANA_HOME}/config/certs/elastic01/elastic01.crt"
elasticsearch.ssl.key: "${KIBANA_HOME}/config/certs/elastic01/elastic01.key"
elasticsearch.ssl.certificateAuthorities: ["${KIBANA_HOME}/config/certs/ca/ca.crt"]

logging.appenders.default:
  type: rolling-file
  fileName: ${KIBANA_HOME}/logs/kibana.log
  policy:
    type: size-limit
    size: 256mb
  strategy:
    type: numeric
    max: 10
  layout:
    type: json

pid.file: ${KIBANA_HOME}/kibana.pid
EOF

echo "[TASK 3] Create Start & Stop script"
touch ${KIBANA_HOME}/startup.sh
touch ${KIBANA_HOME}/shutdown.sh

cat <<EOF | tee ${KIBANA_HOME}/startup.sh > /dev/null
#!/bin/bash
nohup ${KIBANA_HOME}/bin/kibana 2>&1 &
EOF

cat <<EOF | tee ${KIBANA_HOME}/shutdown.sh > /dev/null
#!/bin/bash
pkill -F ${KIBANA_HOME}/kibana.pid
EOF

chmod +x ${KIBANA_HOME}/startup.sh
chmod +x ${KIBANA_HOME}/shutdown.sh


