# multi-stage
# ---------- Build Stage ----------
FROM maven:3.9.10-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy Maven project files
COPY pom.xml .
COPY src ./src

# Build the Spring Boot fat JAR (skip tests for faster build)
RUN mvn -B clean package -DskipTests

# ---------- Runtime Stage ----------
FROM gcr.io/distroless/java17:nonroot
WORKDIR /app

# Copy only the JAR from build stage
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8081

# HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -q --spider http://localhost:8081/actuator/health || exit 1

# Run the JAR
ENTRYPOINT ["java","-jar","/app/app.jar"]
