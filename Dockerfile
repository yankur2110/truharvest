# ─────────────────────────────────────────
# Stage 1 — Build
# Maven builds the JAR inside this container
# ─────────────────────────────────────────
FROM eclipse-temurin:25-jdk AS builder

# Install curl, then download Maven directly from Apache
ARG MAVEN_VERSION=3.9.9
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates wget && \
    wget -q https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    -O /tmp/maven.tar.gz --no-check-certificate && \
    tar -xz -C /opt -f /tmp/maven.tar.gz && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    rm /tmp/maven.tar.gz && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/maven/bin:${PATH}"

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
