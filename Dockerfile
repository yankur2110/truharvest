# ─────────────────────────────────────────
# Stage 1 — Build
# Maven builds the JAR inside this container
# ─────────────────────────────────────────
FROM eclipse-temurin:25-jdk AS builder

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy pom.xml first (better layer caching)
COPY pom.xml ./

# Download dependencies (cached unless pom.xml changes)
RUN mvn dependency:go-offline -q

# Copy source code and build the JAR
COPY src/ src/
RUN mvn package -DskipTests -q

# ─────────────────────────────────────────
# Stage 2 — Run
# Lightweight image with only JRE + JAR
# ─────────────────────────────────────────
FROM eclipse-temurin:25-jre

WORKDIR /app

# Copy only the built JAR from Stage 1
COPY --from=builder /app/target/truharvest-*.jar app.jar

# Expose Spring Boot default port
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
