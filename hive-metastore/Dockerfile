FROM debian:buster-slim

# Make sure noninteractive debian install is used and language variables set
ENV DEBIAN_FRONTEND=noninteractive \
    LANGUAGE=C.UTF-8 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 \
    LC_MESSAGES=C.UTF-8

# Install system dependencies
# Note missing man directories on debian-buster
RUN mkdir -pv /usr/share/man/man1 \
    && mkdir -pv /usr/share/man/man7 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        gettext-base \
        git \
        gnupg2 \
        krb5-user \
        libkrb5-dev \
        libpostgresql-jdbc-java \
        locales \
        postgresql-client \
        rsync \
        sudo \
        unzip \
        procps \
        netcat \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN adduser hive \
    && echo "hive ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hive \
    && chmod 0440 /etc/sudoers.d/hive

# Install OpenJDK 8
RUN curl -fSL https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
    && echo 'deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ buster main' > \
        /etc/apt/sources.list.d/adoptopenjdk.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
      adoptopenjdk-8-hotspot-jre \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-jre-amd64

# Install Apache Hadoop
ARG HADOOP_VERSION=2.10.1
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop

RUN HADOOP_URL="https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
    && set -x \
    && curl -fSL https://dist.apache.org/repos/dist/release/hadoop/common/KEYS | gpg --import - \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && mkdir -p "${HADOOP_HOME}" \
    && tar -xf /tmp/hadoop.tar.gz -C "${HADOOP_HOME}" --strip-components=1 \
    && rm /tmp/hadoop.tar.gz /tmp/hadoop.tar.gz.asc \
    && ln -s "${HADOOP_HOME}/etc/hadoop" /etc/hadoop \
    && mkdir "${HADOOP_HOME}/logs" \
    && mkdir /hadoop-data

ENV PATH=$HADOOP_HOME/bin/:$PATH

# Install Apache Hive
ARG HIVE_VERSION=2.3.7
ENV HIVE_HOME=/opt/hive
ENV HIVE_CONF_DIR=/etc/hive

RUN HIVE_URL="https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
    && set -x \
    && curl -fSL https://downloads.apache.org/hive/KEYS | gpg --import - \
    && curl -fSL "$HIVE_URL" -o /tmp/hive.tar.gz \
    && curl -fSL "$HIVE_URL.asc" -o /tmp/hive.tar.gz.asc \
    && gpg --verify /tmp/hive.tar.gz.asc \
    && mkdir -p "${HIVE_HOME}" \
    && tar -xf /tmp/hive.tar.gz -C "${HIVE_HOME}" --strip-components=1 \
    && rm /tmp/hive.tar.gz /tmp/hive.tar.gz.asc \
    && ln -s "${HIVE_HOME}/etc/hive" "${HIVE_CONF_DIR}" \
    && mkdir "${HIVE_HOME}/logs"

ENV PATH=$HIVE_HOME/bin/:$PATH

# Install GCS connector
ARG GCS_VARIANT="hadoop2"
ARG GCS_VERSION="2.1.6"

RUN GCS_JAR_PATH="/opt/hadoop-gcs-connector-${GCS_VARIANT}-${GCS_VERSION}.jar" \
    && GCS_JAR_URL="https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-${GCS_VARIANT}-${GCS_VERSION}.jar" \
    && curl -fSL "${GCS_JAR_URL}" -o "${GCS_JAR_PATH}"

ENV HADOOP_CLASSPATH="/opt/hadoop-gcs-connector-${GCS_VARIANT}-${GCS_VERSION}.jar:$HADOOP_CLASSPATH"

# Install AWS S3 connector
ARG AWS_SDK_VERSION="1.11.927"

RUN AWS_SDK_JAR_URL="https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar" \
    && AWS_SDK_JAR_PATH="/opt/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar" \
    && curl -fSL "${AWS_SDK_JAR_URL}" --output "${AWS_SDK_JAR_PATH}"

ENV HADOOP_CLASSPATH="/opt/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-2.10.1.jar:$HADOOP_CLASSPATH"

# Install encrypoint and configuration
COPY ./entrypoint.sh /entrypoint.sh
COPY ./core-site.template.xml ${HADOOP_CONF_DIR}/
COPY ./yarn-site.template.xml ${HADOOP_CONF_DIR}/
COPY ./hdfs-site.template.xml ${HADOOP_CONF_DIR}/
COPY ./hive-site.template.xml ${HIVE_CONF_DIR}/

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9083
CMD ["/opt/hive/bin/hive", "--service", "metastore", "-p", "9083", "--verbose"]