FROM amazonlinux:2

# We add the commandbox repo definition so we can install our software.
COPY commandbox.repo /etc/yum.repos.d/commandbox.repo

RUN yum update -y && \
    yum install -y commandbox which && \
    rm -rf /var/cache/yum /var/lib/yum && \
    yum clean all

# all our application work is in this folder
WORKDIR /opt/cfml

ENV WORK_ENVIRONMENT=DEVELOP \
    JAVA_MAXHEAP=1024 \
    WEB_PORT=8080

# Placing this in the deploy folder will automatically apply this package.
RUN  mkdir -p servlet-home/WEB-INF/lucee-server/deploy/
COPY org.lucee.mssql-7.2.2.jre8.lex servlet-home/WEB-INF/lucee-server/deploy/

COPY cfml-config.json server.json ./

# external libs, e.g Redis and AWS
COPY lib lib

# Pre-warm servlet container
RUN mkdir wwwroot && \
    box install commandbox-cfconfig && \
    box server start && box server stop && \
    echo 'ResetThisPassword' > servlet-home/WEB-INF/lucee-server/context/password.txt && \
    box artifacts clean --force
    

RUN echo "<H1>Hello.</H1> Blank project here. Did you forget to bind your volume?" > wwwroot/index.cfm 

# TODO: setup healthcheck 
# HEALTHCHECK --interval=20s --timeout=30s --retries=15 CMD curl --fail ${HEALTHCHECK_URI} || exit 1

EXPOSE 8080 8443

CMD ["box","server","start","console=true"]
