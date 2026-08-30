# =============================================================================
# PetCare API - imagem da APLICACAO (Java 21 + Spring Boot 3)
#
# Build em dois estagios: o Maven e o codigo-fonte ficam apenas no estagio de
# compilacao. A imagem final leva so o JRE e o JAR, o que deixa a imagem menor
# e reduz a superficie de ataque.
#
# REGRA DO CP: o container da aplicacao NAO pode rodar como root.
# =============================================================================

# --------------------------- estagio 1: compilacao ---------------------------
FROM maven:3.9-eclipse-temurin-21 AS compilacao
WORKDIR /origem

# O pom vem sozinho primeiro: enquanto ele nao mudar, o Docker reaproveita a
# camada com as dependencias ja baixadas e o build seguinte fica bem mais rapido.
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# --------------------------- estagio 2: execucao -----------------------------
FROM eclipse-temurin:21-jre-alpine

LABEL projeto="PetCare - CP4 Containers em Nuvem" \
      componente="aplicacao"

# Usuario proprio, sem privilegio administrativo
RUN addgroup -S clinica && adduser -S -G clinica -u 1001 petcare

WORKDIR /opt/petcare

# --chown ja entrega o arquivo com o dono certo, sem precisar de um RUN extra
COPY --from=compilacao --chown=petcare:clinica /origem/target/petcare.jar app.jar

# Daqui em diante nenhum processo roda como root
USER petcare

EXPOSE 8080

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -Duser.timezone=America/Sao_Paulo"

# O Docker/ACI passa a enxergar sozinho se a aplicacao esta saudavel
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
