FROM openjdk:18-alpine

COPY ./build/libs/*.jar / 

# Find the jar file dynamically and rename it to app.jar
RUN mv /demo-*.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
