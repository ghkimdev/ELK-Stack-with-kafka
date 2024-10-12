#!/bin/bash

LOGSTASH_VERSION=8.15.1
LOGSTASH_HOME=/opt/logstash
LOGSTASH_CONFIG=${LOGSTASH_HOME}/logstash.yml

cd /opt
echo "[TASK 1] Download Logstash"
wget -q https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VERSION}-linux-x86_64.tar.gz
tar -xzf logstash-${LOGSTASH_VERSION}-linux-x86_64.tar.gz
mv logstash-${LOGSTASH_VERSION} logstash
rm logstash-${LOGSTASH_VERSION}-linux-x86_64.tar.gz

wget -q https://download.elastic.co/demos/logstash/gettingstarted/logstash-tutorial.log.gz -P ${LOGSTASH_HOME}/
mkdir -p ${LOGSTASH_HOME}/conf.d
mkdir -p ${LOGSTASH_HOME}/logs
cp -r /opt/certs ${LOGSTASH_HOME}/config/

echo "[TASK 2] Set Config file"
cat <<EOF | tee -a ${LOGSTASH_CINFIG}
node.name: my-logstash
path.config: ${LOGSTASH_HOME}/conf.d
EOF

echo "[TASK 3] Create Start & Stop script"
touch ${LOGSTASH_HOME}/startup.sh
touch ${LOGSTASH_HOME}/shutdown.sh

cat <<EOF | tee ${LOGSTASH_HOME}/startup.sh
#!/bin/bash
nohup ${LOGSTASH_HOME}/bin/logstash -f ${LOGSTASH_HOME}/conf.d/* >> ${LOGSTASH_HOME}/logs/logstash.log &
echo \$! > ${LOGSTASH_HOME}/logstash.pid
EOF

cat <<EOF | tee ${LOGSTASH_HOME}/shutdown.sh
#!/bin/bash
pkill -F ${LOGSTASH_HOME}/logstash.pid
rm -f ${LOGSTASH_HOME}/logstash.pid
EOF

chmod +x ${LOGSTASH_HOME}/startup.sh
chmod +x ${LOGSTASH_HOME}/shutdown.sh
