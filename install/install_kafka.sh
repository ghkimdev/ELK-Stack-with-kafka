#!/bin/bash

KAFKA_VERSION=3.8.0
KAFKA_HOME=/opt/kafka
KAFKA_CONFIG=${KAFKA_HOME}/config/server.properties
ZOOKEEPER_CONFIG=${KAFKA_HOME}/config/zookeeper.properties

cd /opt
echo "[TASK 1] Install Java 11"
sudo apt-get update -qq && sudo apt-get install -y -qq openjdk-11-jdk-headless >/dev/null 2>&1


echo "[TASK 2] Install Kafka"
wget -q https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz
tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz
mv kafka_2.13-${KAFKA_VERSION} kafka
rm kafka_2.13-${KAFKA_VERSION}.tgz

mkdir -p ${KAFKA_HOME}/logs
mkdir -p /opt/zookeeper/data
mkdir -p /opt/zookeeper/logs

hostname | rev | cut -c 1 > /opt/zookeeper/data/myid

echo "[TASK 3] Set Kafka config"
sed -i "/broker.id=/d" ${KAFKA_CONFIG}
sed -i "/log.dirs=/d" ${KAFKA_CONFIG}
sed -i "/num.partitions=/d" ${KAFKA_CONFIG}
sed -i "/zookeeper.connect=/d" ${KAFKA_CONFIG}

cat <<EOF | tee -a ${KAFKA_CONFIG}
broker.id=$(cat /opt/zookeeper/data/myid)
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://$(hostname -i):9092
log.dirs=${KAFKA_HOME}/logs
num.partitions=3
zookeeper.connect=172.16.1.111:2181,172.16.1.112:2181,172.16.1.113:2181/my-kafka-cluster
EOF


echo "[TASK 4] Set Zookeeper config"

sed -i '/dataDir=/d' ${ZOOKEEPER_CONFIG}
cat <<EOF | tee -a ${ZOOKEEPER_CONFIG}
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/data
dataLogDir=/opt/zookeeper/logs

maxSessionTimeout=180000
server.1=172.16.1.111:2888:3888
server.2=172.16.1.112:2888:3888
server.3=172.16.1.113:2888:3888
EOF
