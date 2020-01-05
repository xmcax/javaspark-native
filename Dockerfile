FROM ubuntu:18.04
RUN apt-get update && apt-get install -y gcc zlib1g-dev wget

RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-19.3.0.2/graalvm-ce-java11-linux-amd64-19.3.0.2.tar.gz
RUN tar -vzxf graalvm-ce-java11-linux-amd64-19.3.0.2.tar.gz
ENV PATH /graalvm-ce-java11-19.3.0.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN gu install native-image

WORKDIR /graalvm-demo
COPY . /graalvm-demo

RUN ./gradlew clean fatJar
RUN native-image --verbose --enable-http -H:+ReportUnsupportedElementsAtRuntime --no-fallback -jar /graalvm-demo/build/libs/javaspark-native-1.0-SNAPSHOT-fatjar.jar


FROM adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.3_7-slim
WORKDIR /graalvm-demo
COPY --from=0 /graalvm-demo/javaspark-native-1.0-SNAPSHOT-fatjar .
RUN apk --update --no-cache add \
    curl \
    tar \
    && rm -rf /var/cache/apk/*

EXPOSE 8080
CMD ./javaspark-native-1.0-SNAPSHOT-fatjar
