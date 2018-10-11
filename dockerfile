FROM payara/server-full
ARG ZEEA_DB_SERVERNAME
ARG ZEEA_DATABASE_NAME

ENV ZEEA_DB_SERVERNAME ${ZEEA_DB_SERVERNAME}
ENV ZEEA_DATABASE_NAME ${ZEEA_DATABASE_NAME}

# mySQL Connector J/8
RUN wget -O $PAYARA_PATH/glassfish/domains/domain1/lib/mysql-connector-java-8.0.12.jar   http://central.maven.org/maven2/mysql/mysql-connector-java/8.0.12/mysql-connector-java-8.0.12.jar  

# WAR File to deploy
#COPY ./war/inventoryweb-2.0-SNAPSHOT.war $DEPLOY_DIR
ADD --chown=payara:payara https://github.com/zeesh17s/zeeainventory/raw/master/war/inventoryweb-2.0-SNAPSHOT.war $DEPLOY_DIR

ENTRYPOINT ${PAYARA_PATH}/generate_deploy_commands.sh && \
echo "create-jdbc-connection-pool --datasourceclassname com.mysql.cj.jdbc.MysqlDataSource --restype javax.sql.ConnectionPoolDataSource --property user=shan:password=shan:DatabaseName=$ZEEA_DATABASE_NAME:ServerName=$ZEEA_DB_SERVERNAME:port=3306:useSSL=false zeeaPoolMySql" > mycommands.asadmin && \
echo "create-jdbc-resource --connectionpoolid zeeaPoolMySql jdbc/__zeea" >> mycommands.asadmin && \
echo "create-auth-realm --classname com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm --property jaas-context=jdbcRealm:datasource-jndi=jdbc/__zeea:user-table=EMPLOYEE:user-name-column=username:password-column=password:group-table=EMPLOYEE_GROUPS:group-name-column=GROUPNAME:digest-algorithm=SHA-256 --target server jdbcRealm" >> mycommands.asadmin && \
cat ${PAYARA_PATH}/post-boot-commands.asadmin >> mycommands.asadmin && \
cat ${DEPLOY_COMMANDS} >> mycommands.asadmin && \
${PAYARA_PATH}/bin/asadmin start-domain -v --postbootcommandfile mycommands.asadmin ${PAYARA_DOMAIN}

EXPOSE 4848:4848
EXPOSE 8080:8080

# change "asadmin start-domain -v" to startInForeground.sh this shell script is located in ${payara_path}/bin