Database modernization demo featuring oracle CDC connector, cluster linking, ksqldb, and a fully managed mongoDB Atlas sink

Refer to this repo for setting up the oracle DB and data upon which this demo is built: https://github.com/sami2ahmed/demo-database-modernization. Tl;dr we are going to launch an onprem Confluent Platform and post an Oracle CDC Source connector to run there. It's going to house our CUSTOMERS table. Sensitive data will be masked by a


# CONFLUENT PLATFORM CLUSTER
1. from root of repo 
`docker-compose up -d`
2. confirm no connectors are running 
`http GET "http://localhost:8083/connectors" | jq '.'\`
3. view existing topics and create redo-log-topic
`kafka-topics --bootstrap-server localhost:9092 --list`
`kafka-topics --bootstrap-server localhost:9092 --create --topic redo-log-topic`

# ORACLE CDC CONNECTOR
4. post oracle-cdc-config to connect api
```curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
        "name": "OracleCdcSourceConnectorSM",
        "config": {
                "connector.class": "io.confluent.connect.oracle.cdc.OracleCdcSourceConnector",
                "name": "OracleCdcSourceConnectorSM",
                "tasks.max":1,
                "oracle.server": "<ENDPOINT>",
                "oracle.port": 1521,
                "oracle.sid":"ORCL",
                "oracle.username": "<USERNAME>",
                "oracle.password": "<PASSWORD>",
                "start.from":"snapshot",
                "redo.log.topic.name": "redo-log-topic",
                "redo.log.consumer.bootstrap.servers":"kafka:9092",

                "table.inclusion.regex": "ORCL[.]<USERNAME>[.]CUSTOMERS",
                "table.topic.name.template": "${databaseName}.${schemaName}.${tableName}",
                "confluent.topic.replication.factor":1,
                "redo.log.row.fetch.size": 1,
                "numeric.mapping": "best_fit_or_double",

                "topic.creation.groups":"redo",
                "topic.creation.redo.include":"redo-log-topic",
                "topic.creation.redo.replication.factor":1,
                "topic.creation.redo.partitions":1,
                "topic.creation.redo.cleanup.policy":"delete",
                "topic.creation.redo.retention.ms":1209600000,
                "topic.creation.default.replication.factor":1,
                "topic.creation.default.partitions":1,
                "topic.creation.default.cleanup.policy":"compact",
                "confluent.topic.bootstrap.servers":"kafka:9092",
                "topic.creation.enable": true
                }
        }'```
5. confirm connector is up
`http GET "http://localhost:8083/connectors" | jq '.'`
6. confirm topic is created and populated by connector, you'll need to insert your username from oracle DB in the command below.  
`kafka-console-consumer --bootstrap-server localhost:9092 --topic ORCL.ADMIN2.CUSTOMERS --from-beginning`
7. in differnet terminal you can run an update against the connector and confirm its being captured, i ran AWS RDS oracle and ssh'ed into it, then login as admin (user you setup with the appropriate connect privileges as described in demo-mod repo).
`update CUSTOMERS set avg_credit_spend = avg_credit_spend+300 where first_name = 'Hansiain';`
`COMMIT WORK;`
8. you can start a different terminal and kafka consumer to ensure changes like the update above come into the redo-log-topic
`kafka-console-consumer --bootstrap-server localhost:9092 --topic redo-log-topic --from-beginning`

# SCHEMA LINK
1. setup SR config on CP instance, the values below should be from your CC instance
`cat > schema-registry.config <<EOF

schema.registry.url=<URL>
basic.auth.credentials.source=USER_INFO
basic.auth.user.info=<USER : PASSWORD>

EOF`

2. create the SR exporter, provide whatever names in <>
schema-exporter --create --name <> --config-file schema-registry.config \
--context-type CUSTOM \
--context-name <> \
--schema.registry.url http://schema-registry:8081

3. check status of exporter
schema-exporter --describe --name <> --schema.registry.url http://schema-registry:8081 | jq


# CLUSTER LINK
1. get onprem cluster id -- THIS CHANGES EACH TIME YOU DOCKER UP AND DOWN
`kafka-cluster cluster-id --bootstrap-server kafka:9092`

2. export cluster id as variable, insert in <> below.
`export CP_CLUSTER_ID="EuBiQonXQaS169R62U1MNw"``

3. this is config for the cloud side, it tells cloud cluster it is destination of the link and that local cluster initiates the connection
`cat > clusterlink-hybrid-dst.config <<EOF
link.mode=DESTINATION
connection.mode=INBOUND
EOF`

*you must login to confluent cloud CLI and select cluster there before proceeding with 4 i.e.
`cflt login`
`cflt environment use <ENV>`
`cflt kafka cluster use <LKC>`

4. cluster link creation on CC side, insert your lkc including "lkc" in <>
`confluent kafka link create from-on-prem --config-file clusterlink-hybrid-dst.config --source-cluster-id $CP_CLUSTER_ID --source-bootstrap-server 0.0.0.0 --cluster <LKC>`

5. tell CC it is source of the link & CP that it will originate connection to CC, insert your values in '<>'
`cat > clusterlink-onprem-source.config <<EOF
link.mode=SOURCE
connection.mode=OUTBOUND bootstrap.servers=pkc-kj826.eastus2.azure.confluent.cloud:9092 security.protocol=SASL_SSL
sasl.mechanism=PLAIN sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username='<>' password='<>';
EOF`

6. create link from CP side, insert your lkc like in step above
`kafka-cluster-links --bootstrap-server kafka:9092 --create --link from-on-prem --config-file clusterlink-onprem-source.config --cluster-id <LKC>`


# PYTHON PRODUCER
WIP

# KSQLDB
WIP
