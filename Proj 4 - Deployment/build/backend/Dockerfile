FROM gradle:7-jdk11 AS build

WORKDIR /app

COPY build.gradle gradlew liquibase.gradle pre-commit.gradle settings.gradle system.properties .
COPY src /app/src
COPY config /app/config

RUN gradle war

FROM tomcat:9.0.93-jdk11 AS tomcat

RUN apt-get update && apt-get install -y postgresql-client

COPY --from=build /app/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

COPY scripts/ /scripts/
COPY backup/ /backup/
RUN chmod +x /scripts/*.sh

EXPOSE 8080

CMD ["catalina.sh", "run"]

# CMD ["/scripts/pgsql_restore.sh", "/backup/2024-08-19.dump"]

