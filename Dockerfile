# ---------- Stage 1: Build WAR bằng Maven ----------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy pom để cache dependency
COPY pom.xml .
RUN mvn -B -ntp -DskipTests dependency:go-offline

# Copy source và build WAR
COPY src ./src
RUN mvn -B -ntp -DskipTests clean package

# ---------- Stage 2: Chạy bằng Tomcat 9 ----------
FROM tomcat:9.0-jdk17

# Xóa webapp mặc định
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR vừa build vào ROOT.war để truy cập trực tiếp tại /
COPY --from=build /workspace/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Mở cổng mặc định của Tomcat
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
