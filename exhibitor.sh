#!/bin/bash -e

cat <<- EOF > /opt/exhibitor/defaults.conf
	zookeeper-data-directory=$ZK_DATA_DIR
	zookeeper-log-directory=$ZK_LOG_DIR
	log-index-directory=$ZK_LOG_DIR/indexed
	backup-extra=directory\=${ZK_LOG_DIR}/backup
	cleanup-period-ms=300000
	check-ms=30000
	backup-period-ms=600000
	cleanup-max-files=20
	backup-max-store-ms=21600000
	observer-threshold=0
	zoo-cfg-extra=tickTime\=2000&initLimit\=10&syncLimit\=5&quorumListenOnAllIPs\=true
	auto-manage-instances-settling-period-ms=0
EOF

/usr/local/bin/manage_off.sh &

# Starting exhibitor
java -jar /opt/exhibitor/exhibitor.jar \
    --port $EXHIBITOR_PORT --defaultconfig /opt/exhibitor/defaults.conf \
    --configtype file --filesystembackup true


