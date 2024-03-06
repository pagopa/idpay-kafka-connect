FROM gradle:8.4.0-jdk8-jammy@sha256:c10f5e897983c6b87008b2d604e6baf824d3d99d852543bc5cb3b6b1c45e5bcb AS deps

WORKDIR /deps

COPY build.gradle build.gradle
RUN gradle getMongoKafkaConnectDeps

RUN curl -L "https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.4.19/applicationinsights-agent-3.4.19.jar" \
    --output "applicationinsights-agent.jar"

FROM debezium/connect-base:2.4.1.Final@sha256:52297b4d15b2eff0a19b44337e34a9cd3144696a70393ab9f4eee14d697abb0e

COPY --from=deps /deps/mongo-kafka-connect/ /kafka/connect/mongo-kafka-connect/
COPY --from=deps /deps/applicationinsights-agent.jar .


USER root
RUN chmod 777 -R /kafka/connect/ && chown kafka:kafka -R applicationinsights-agent.jar
RUN chmod 777 -R /tmp
USER kafka