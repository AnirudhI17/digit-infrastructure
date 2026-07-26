# Multi-stage Build from Official Repository to maintain zero-source footprint
FROM maven:3.8-openjdk-11-slim AS build
RUN apt-get update && apt-get install -y git
WORKDIR /app
ARG REPO_URL=https://github.com/egovernments/DIGIT-OSS.git
ARG BRANCH_NAME=master
RUN git clone --depth 1 -b ${BRANCH_NAME} ${REPO_URL} .
WORKDIR /app/core-services/pdf-service
RUN mvn clean package -DskipTests -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/core-services/pdf-service/target/*.jar app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=dev
ENTRYPOINT ["java", "-jar", "app.jar"]
