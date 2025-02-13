ARG STRIMZI_KAFKA_TAG="0.38.0-kafka-3.6.0"

FROM quay.io/strimzi/kafka:${STRIMZI_KAFKA_TAG}

ARG AWS_MSK_IAM_AUTH_VERSION="2.2.0"
ENV CLASSPATH=/opt/kafka/libs/aws-msk-iam-auth-${AWS_MSK_IAM_AUTH_VERSION}-all.jar

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
COPY confluentinc-kafka-connect-s3-10.5.5 /opt/kafka/plugins/confluentinc-kafka-connect-s3-10.5.5

# MySQL Debezium Connector (Add this section)
ARG DEBEZIUM_VERSION="3.0.7.Final"
RUN mkdir -p /opt/kafka/plugins/debezium-connector-mysql \
    && curl -sSL -o /opt/kafka/plugins/debezium-connector-mysql/debezium-connector-mysql-${DEBEZIUM_VERSION}.jar \
       https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/${DEBEZIUM_VERSION}/debezium-connector-mysql-${DEBEZIUM_VERSION}.jar

RUN chmod +x /opt/kafka/kafka_connect_config_generator.sh \
 && chmod +x /opt/kafka/kafka_mirror_maker_2_connector_config_generator.sh \
 && chmod +x /opt/kafka/kafka_mirror_maker_consumer_config_generator.sh \
 && chmod +x /opt/kafka/kafka_mirror_maker_producer_config_generator.sh