FROM gradle:8.4.0-jdk8-jammy@sha256:c10f5e897983c6b87008b2d604e6baf824d3d99d852543bc5cb3b6b1c45e5bcb AS deps

WORKDIR /deps

COPY build.gradle build.gradle
RUN gradle getMongoKafkaConnectDeps

RUN mkdir -p /deps/debezium-postgres && \
    curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.0.Final/debezium-connector-postgres-2.6.0.Final-plugin.tar.gz \
    | tar -xz -C /deps/debezium-postgres

RUN mkdir -p /deps/kafka-connect-jdbc && \
    curl -L https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/10.7.6/kafka-connect-jdbc-10.7.6.tar.gz \
    | tar -xz --strip-components=1 -C /deps/kafka-connect-jdbc

RUN curl -L "https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.5.1/applicationinsights-agent-3.5.1.jar" \
    --output "applicationinsights-agent.jar"

FROM debezium/connect-base:2.6.0.Final@sha256:ea2d17592e93e06e93459f940704d9b57f2b30d4f4bb5e83699bfae28aeea568

COPY --from=deps /deps/mongo-kafka-connect/ /kafka/connect/mongo-kafka-connect/

COPY --from=deps /deps/debezium-postgres/ /kafka/connect/debezium-postgres/

COPY --from=deps /deps/kafka-connect-jdbc/ /kafka/connect/kafka-connect-jdbc/

COPY --from=deps /deps/applicationinsights-agent.jar .

USER root

RUN chmod -R 777 /kafka/connect/
RUN chmod -R 777 /tmp
RUN chown kafka:kafka applicationinsights-agent.jar

USER kafka