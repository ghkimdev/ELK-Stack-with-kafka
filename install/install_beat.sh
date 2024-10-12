#!/bin/bash

function set_beatconfig() {
        local BEAT=$1
        local BEAT_VERSION=8.15.1
        local BEAT_HOME=/opt/${BEAT}
        local BEAT_CONFIG=${BEAT_HOME}/${BEAT}.yml
	local CERTS_HOME=/opt/certs

	curl -s -L -O https://artifacts.elastic.co/downloads/beats/${BEAT}/${BEAT}-${BEAT_VERSION}-linux-x86_64.tar.gz

        tar xzf ${BEAT}-${BEAT_VERSION}-linux-x86_64.tar.gz
	mv ${BEAT}-${BEAT_VERSION}-linux-x86_64 ${BEAT}
	rm ${BEAT}-${BEAT_VERSION}-linux-x86_64.tar.gz

	cp -r ${CERTS_HOME} ${BEAT_HOME}/certs

	sed -i "/setup.kibana:/d" ${BEAT_CONFIG}
	sed -i "/output.elasticsearch:/d" ${BEAT_CONFIG}
	sed -i "/preset: balanced/d" ${BEAT_CONFIG}

	cat <<EOF | tee -a ${BEAT_CONFIG}
setup.dashboards.enabled: true

setup.kibana:
  host: "https://kibana.example.com:5601"

  ssl.enabled: true
  ssl.certificate_authorities: ["/${BEAT_HOME}/certs/ca/ca.crt"]
  ssl.certificate: "${BEAT_HOME}/certs/my-kibana/my-kibana.crt"
  ssl.key: "${BEAT_HOME}/certs/my-kibana/my-kibana.key"

output.elasticsearch:
  hosts: ["https://elastic01.example.com:9200","https://elastic02.example.com:9200","https://elastic03.example.com:9200"]
  ssl.certificate_authorities: ["${BEAT_HOME}/certs/ca/ca.crt"]
  ssl.certificate: "${BEAT_HOME}/certs/elastic01/elastic01.crt"
  ssl.key: "${BEAT_HOME}/certs/elastic01/elastic01.key"

  username: "elastic"
  password: "elastic"
EOF

	cat <<EOF | tee ${BEAT_HOME}/startup.sh >> /dev/null
#!/bin/bash
nohup ${BEAT_HOME}/${BEAT} -c ${BEAT_CONFIG} run > ${BEAT_HOME}/${BEAT}.log &
echo "\$!" > ${BEAT_HOME}/${BEAT}.pid
EOF

	cat <<EOF | tee ${BEAT_HOME}/shutdown.sh >> /dev/null
#!/bin/bash
pkill -F ${BEAT_HOME}/${BEAT}.pid
rm -f ${BEAT_HOME}/${BEAT}.pid
EOF

	chmod +x ${BEAT_HOME}/startup.sh
	chmod +x ${BEAT_HOME}/shutdown.sh

}

cd /opt
echo "[TASK 1] Install metricbeat"
set_beatconfig "metricbeat"
echo "[TASK 2] Install auditbeat"
set_beatconfig "auditbeat"
echo "[TASK 3] Install filebeat"
set_beatconfig "filebeat"
echo "[TASK 4] Install packetbeat"
set_beatconfig "packetbeat"
echo "[TASK 5] Install heartbeat"
set_beatconfig "heartbeat"

sudo chown -R root:root /opt/auditbeat/auditbeat.yml
sudo chown -R root:root /opt/packetbeat/packetbeat.yml

