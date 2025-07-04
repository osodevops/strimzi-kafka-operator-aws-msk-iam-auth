ARG STRIMZI_KAFKA_TAG="0.38.0-kafka-3.6.0"

FROM quay.io/strimzi/kafka:${STRIMZI_KAFKA_TAG}

ARG AWS_MSK_IAM_AUTH_VERSION="2.2.0"
ENV CLASSPATH=/opt/kafka/libs/*

USER root

RUN curl -sSL -o /opt/kafka/libs/aws-msk-iam-auth-${AWS_MSK_IAM_AUTH_VERSION}-all.jar https://github.com/aws/aws-msk-iam-auth/releases/download/v2.2.0/aws-msk-iam-auth-2.2.0-all.jar

COPY kafka_connect_config_generator.sh /opt/kafka/kafka_connect_config_generator.sh
COPY kafka_mirror_maker_2_connector_config_generator.sh /opt/kafka/kafka_mirror_maker_2_connector_config_generator.sh
COPY kafka_mirror_maker_consumer_config_generator.sh /opt/kafka/kafka_mirror_maker_consumer_config_generator.sh
COPY kafka_mirror_maker_producer_config_generator.sh /opt/kafka/kafka_mirror_maker_producer_config_generator.sh

RUN mkdir -p /opt/kafka/plugins
# JDBC Kafka Connector
COPY confluentinc-kafka-connect-jdbc-10.0.1 /opt/kafka/plugins/confluentinc-kafka-connect-jdbc-10.0.1
COPY redshift/redshift-jdbc42-2.1.0.17.jar /opt/kafka/plugins/confluentinc-kafka-connect-jdbc-10.0.1/lib/
COPY mysql-driver/mysql-connector-java-5.1.49.jar /opt/kafka/plugins/confluentinc-kafka-connect-jdbc-10.0.1/lib/

# Servicenow connector
COPY confluentinc-kafka-connect-servicenow-2.5.4 /opt/kafka/plugins/confluentinc-kafka-connect-servicenow-2.5.4

# S3 Kafka Connector
COPY confluentinc-kafka-connect-s3-10.6.5 /opt/kafka/plugins/confluentinc-kafka-connect-s3-10.6.5

# MySQL Debezium Connector
ARG DEBEZIUM_VERSION="3.0.7.Final"
RUN curl -sSL -o /tmp/debezium-connector-mysql-${DEBEZIUM_VERSION}-plugin.tar.gz \
       https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/${DEBEZIUM_VERSION}/debezium-connector-mysql-${DEBEZIUM_VERSION}-plugin.tar.gz \
    && mkdir -p /opt/kafka/plugins/debezium-connector-mysql \
    && tar -xzf /tmp/debezium-connector-mysql-${DEBEZIUM_VERSION}-plugin.tar.gz -C /opt/kafka/plugins/debezium-connector-mysql \
    && rm -f /tmp/debezium-connector-mysql-${DEBEZIUM_VERSION}-plugin.tar.gz

# Postgres Debezium Connector
ARG DEBEZIUM_PG_VERSION="3.1.2.Final"
RUN curl -sSL -o /tmp/debezium-connector-postgres-${DEBEZIUM_PG_VERSION}-plugin.tar.gz \
       https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_PG_VERSION}/debezium-connector-postgres-${DEBEZIUM_PG_VERSION}-plugin.tar.gz \
    && mkdir -p /opt/kafka/plugins/debezium-connector-postgres \
    && tar -xzf /tmp/debezium-connector-postgres-${DEBEZIUM_PG_VERSION}-plugin.tar.gz -C /opt/kafka/plugins/debezium-connector-postgres \
    && rm -f /tmp/debezium-connector-postgres-${DEBEZIUM_PG_VERSION}-plugin.tar.gz

#ARG DEBEZIUM_JDBC_VERSION="3.0.7.Final"
ARG DEBEZIUM_JDBC_VERSION="2.6.2.Final"
RUN curl -sSL -o /tmp/debezium-connector-jdbc-${DEBEZIUM_JDBC_VERSION}-plugin.tar.gz \
       https://repo1.maven.org/maven2/io/debezium/debezium-connector-jdbc/${DEBEZIUM_JDBC_VERSION}/debezium-connector-jdbc-${DEBEZIUM_JDBC_VERSION}-plugin.tar.gz \
    && mkdir -p /opt/kafka/plugins/debezium-connector-jdbc \
    && tar -xzf /tmp/debezium-connector-jdbc-${DEBEZIUM_JDBC_VERSION}-plugin.tar.gz -C /opt/kafka/plugins/debezium-connector-jdbc \
    && rm -f /tmp/debezium-connector-jdbc-${DEBEZIUM_JDBC_VERSION}-plugin.tar.gz

RUN mkdir  -p /opt/kafka/plugins/service-now-connector
COPY servicenow-source-connector/servicenow-connector-1.0-SNAPSHOT-all.jar /opt/kafka/plugins/service-now-connector

RUN chmod +x /opt/kafka/kafka_connect_config_generator.sh \
 && chmod +x /opt/kafka/kafka_mirror_maker_2_connector_config_generator.sh \
 && chmod +x /opt/kafka/kafka_mirror_maker_consumer_config_generator.sh \
 && chmod +x /opt/kafka/kafka_mirror_maker_producer_config_generator.sh


