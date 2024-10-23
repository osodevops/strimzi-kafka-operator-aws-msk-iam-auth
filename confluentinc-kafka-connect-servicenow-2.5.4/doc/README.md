# Kafka Connect ServiceNow Source Connector
## Overview
kafka-connect-servicenow is a Kafka Connector that reads data from ServiceNow table when new data are new/updated. 
It integrates [ServiceNow Table API](https://docs.servicenow.com/bundle/newyork-application-development/page/integrate/inbound-rest/concept/c_TableAPI.html) to pick up new record changes (insertion and updates) in ServiceNow tables. 
Documentation for this connector can be found [here](https://docs.confluent.io/current/connect/kafka-connect-servicenow/index.html)

## Configuration

Here's an example to what ServiceNow Configuration looks like:

```
name=ServiceNowConnector
tasks.max=1
connector.class=io.confluent.connect.servicenow.ServiceNowSourceConnector

#### Required ####
kafka.topic=topic-servicenow
servicenow.url=https://dev23125.service-now.com/
servicenow.table=incident
servicenow.user=admin
servicenow.password=Confluenttest1

confluent.topic.replication.factor=1
confluent.topic.bootstrap.servers=localhost:9092
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter

#### Optional ####
batch.max.row=10000
poll.interval.s=60
servicenow.since=2019-01-01
```
Table of all configurations in ServiceNow Connector

| Name                                  | Description                                                                                                                                                                                                                                                                                                                                                                                                                          | Type     | Default | Valid Values                             | Importance |
|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|------------------------------------------|------------|
| kafka.topic                           | The Kafka topic to write the ServiceNow data to.                                                                                                                                                                                                                                                                                                                                                                                     | string   |         |                                          | high       |
| servicenow.password                   | ServiceNow password to connect with.                                                                                                                                                                                                                                                                                                                                                                                                 | password |         |                                          | high       |
| servicenow.username                   | ServiceNow username to connect with.                                                                                                                                                                                                                                                                                                                                                                                                 | string   |         |                                          | high       |
| servicenow.url                        | The ServiceNow instance to connect to.                                                                                                                                                                                                                                                                                                                                                                                               | string   |         |                                          | high       |
| servicenow.table                      | The serviceNow table name to poll data from.                                                                                                                                                                                                                                                                                                                                                                                         | string   |         |                                          | high       |
| connection.timeout.ms                 | The amount of time to wait while connecting to the ServiceNow endpoint.                                                                                                                                                                                                                                                                                                                                                              | long     | 50000   |                                          | low        |
| read.timeout.ms                       | The timeout for read (GET) requests to ServiceNow                                                                                                                                                                                                                                                                                                                                                                                    | int      | 20000   |                                          | medium     |
| write.timeout.ms                      | The timeout for write (POST/PUT) requests to ServiceNow.                                                                                                                                                                                                                                                                                                                                                                             | int      | 20000   |                                          | medium     |
| poll.interval.s                       | The interval to poll data from ServiceNow endpoint.                                                                                                                                                                                                                                                                                                                                                                                  | long     | 1       | [1, 600]                                 | high       |
| servicenow.since                      | The starting point to poll data from ServiceNow table in format YYYY-MM-DD HH:MM:SS. By default, it uses the starting date (YYYY-MM-DD HH:MM:SS 00:00:00) of the connector.                                                                                                                                                                                                                                                          | string   | The date of connector start |                      | medium     |
| batch.max.row                         | The batch size to determine how many data returned in each poll. Smaller batch size may results in pagination of servicenow response.                                                                                                                                                                                                                                                                                                | string   | 10000   | [1, 10000]                               | low        |
| servicenow.ssl.keystore.path          | The location of the key store file.                                                                                                                                                                                                                                                                                                                                                                                                  | string   |         |                                          | low        |
| servicenow.ssl.keystore.password      | The password for key store file.                                                                                                                                                                                                                                                                                                                                                                                                     | string   |         |                                          | low        |
| servicenow.ssl.truststore.path        | The location of the trust store file.                                                                                                                                                                                                                                                                                                                                                                                                | string   |         |                                          | low        |
| servicenow.ssl.truststore.password    | The password for trust store file.                                                                                                                                                                                                                                                                                                                                                                                                   | string   |         |                                          | low        |

## Building

```
git clone https://github.com/confluentinc/kafka-connect-servicenow.git
cd kafka-connect-servicenow
mvn clean install
```

Tips: Remember to change credentials and endpoint before building the package, otherwise, integration test will fail.

Then, follow [ServiceNow Documentation](https://docs.confluent.io/current/connect/kafka-connect-servicenow/index.html) to run the connector

# Integration Tests

To run ITs in your local environment, please export the SERVICENOW_CREDS environment variable to
 the path of your credentials file, which must be in a JSON format.
```bash
export SERVICENOW_CREDS=path/to/your/creds.json
```

An example credentials file:
```$xslt
{
  "creds": {
    "servicenow_url": <your_servicenow_url>,
    "servicenow_user": <your_servicenow_user>,
    "servicenow_password": <your_servicenow_password>,
  }
}
```

You can run `vault kv get v1/ci/kv/connect/servicenow_it` to obtain ServiceNow credentials that 
can be used to populate a credentials file.

## Performance Test

This repo contains three additional files: `config/servicenow-config-perf.json`, `bin/datagen.go`, and `bin/Dockerfile`. 
Connect provides a easy-to-use framework to performance test the connector.
Please refer to [Connect performance testing](https://github.com/confluentinc/connect-performance-testing) to run performance tests.
