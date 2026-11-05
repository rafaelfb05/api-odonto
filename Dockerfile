# Inicia a etapa de construção, chamada "build".
# Usa uma imagem com Maven 3.9 e Java 21 para compilar o projeto.
FROM maven:3.9-eclipse-temurin-21 AS build

# Cria a pasta /app e acessa ela
WORKDIR /app

# Copia o pom.xml do projeto para a pasta /app.
# Esse arquivo contém as dependências e configurações do Maven.
COPY pom.xml .

# Baixa antecipadamente as dependências e os plugins do projeto.
# -B executa o Maven sem interação, adequado para automação.
# Essa etapa pode ser reaproveitada pelo cache enquanto o pom.xml não mudar.
RUN mvn -B dependency:go-offline

# Copia a pasta src do projeto para /app/src.
# Ela contém o código-fonte e os recursos da aplicação.
COPY src ./src

# Limpa arquivos de builds anteriores e gera o pacote da aplicação.
# clean: remove a pasta target anterior.
# package: compila e empacota o projeto, gerando o JAR em target.
# -DskipTests: pula a execução dos testes.
RUN mvn -B clean package -DskipTests

# Inicia uma segunda etapa, com uma imagem que contém o Java 21 para execução.
# O Maven e os arquivos-fonte ficam na etapa anterior,
# reduzindo o tamanho da imagem final.
FROM eclipse-temurin:21-jre

# Define /app como a pasta de trabalho da imagem final.
WORKDIR /app

# Copia o JAR gerado na etapa "build" para a imagem final,
# renomeando o arquivo para app.jar.
COPY --from=build /app/target/*.jar app.jar

# Documenta que a aplicação deve utilizar a porta 10000.
# Este comando não configura a porta do Spring nem a publica no host.
EXPOSE 10000

# Define o comando executado quando o contêiner iniciar.
# java -jar inicia a aplicação contida no arquivo /app/app.jar.
ENTRYPOINT ["java", "-jar", "/app/app.jar"]