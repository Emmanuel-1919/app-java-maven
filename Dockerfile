# Etapa 1: build
FROM  maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app-java-maven/built-1
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
COPY src src
RUN ./mvnw clean package -DskipTests


# Etapa 2: runtime
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app
COPY --from=builder app-java-maven/built-1/target/app-java-maven.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]