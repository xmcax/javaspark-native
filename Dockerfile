FROM ubuntu:18.04 AS build-env
RUN apt-get update && apt-get install -y gcc zlib1g-dev wget

RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-19.3.0.2/graalvm-ce-java11-linux-amd64-19.3.0.2.tar.gz
RUN tar -vzxf graalvm-ce-java11-linux-amd64-19.3.0.2.tar.gz
ENV PATH /graalvm-ce-java11-19.3.0.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN gu install native-image

WORKDIR /sparkjava
COPY . /sparkjava

RUN ./gradlew clean fatJar
RUN native-image \
    -H:+ReportUnsupportedElementsAtRuntime \
    -H:+TraceClassInitialization \
    --verbose \
    --enable-http \
    --static \
    --no-fallback \
    --initialize-at-build-time=org.eclipse.jetty,org.slf4j,javax.servlet,org.sparkjava \
    -jar /sparkjava/build/libs/javaspark-native-1.0-SNAPSHOT-fatjar.jar

FROM alpine:3.11.2
WORKDIR /sparkjava
COPY --from=build-env /sparkjava/javaspark-native-1.0-SNAPSHOT-fatjar .

EXPOSE 8080
ENTRYPOINT ./javaspark-native-1.0-SNAPSHOT-fatjar
