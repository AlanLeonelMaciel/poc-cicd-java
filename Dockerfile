# Etapa 1: Construcción (Build)
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app
# Copiamos los archivos de Maven
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
# Descargamos dependencias (optimiza el caché de Docker)
RUN ./mvnw dependency:go-offline
# Copiamos el código fuente y compilamos saltando los tests (se corren en GitHub)
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Etapa 2: Imagen final (Run)
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Copiamos solo el .jar generado en la etapa anterior
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
