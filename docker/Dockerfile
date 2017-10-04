FROM openjdk:8-jre

ADD ./target/universal/stage.jar /stage.jar
RUN unzip /stage.jar -d /
RUN chmod +x /stage/bin/lift-jetty-cluster
ENTRYPOINT ["/stage/bin/lift-jetty-cluster"]

EXPOSE 8080
