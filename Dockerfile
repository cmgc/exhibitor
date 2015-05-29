FROM jeanblanchard/busybox-java:8

ENV \
    ZK_DATA_DIR=/var/lib/zookeeper \
    ZK_LOG_DIR=/var/log/zookeeper \
    EXHIBITOR_POM="https://raw.githubusercontent.com/Netflix/exhibitor/d911a16d704bbe790d84bbacc655ef050c1f5806/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml" \
    MVN_RELEASE="http://www.apache.org/dist/maven/maven-3/3.3.1/binaries/apache-maven-3.3.1-bin.tar.gz" \
    EXHIBITOR_PORT=8181


# Use one step so we can remove intermediate dependencies and minimize size
RUN \
    mkdir -p /opt /usr/local/bin \
    # Install dependencies
    && opkg-install bash tar \

    # Default DNS cache TTL is -1. DNS records, like, change, man.
    && grep -q '^networkaddress.cache.ttl=' /opt/jdk/jre/lib/security/java.security || echo 'networkaddress.cache.ttl=60' >> /opt/jdk/jre/lib/security/java.security \

    # Install Maven (just for building)
    && mkdir -p /opt/maven \
    && curl -Lo /tmp/maven.tgz $MVN_RELEASE \
    && tar -xzf /tmp/maven.tgz -C /opt/maven --strip=1 \
    && rm /tmp/maven.tgz \

    # Install Exhibitor
    && mkdir -p /opt/exhibitor \
    && curl -kLo /opt/exhibitor/pom.xml $EXHIBITOR_POM \
    && /opt/maven/bin/mvn -f /opt/exhibitor/pom.xml package \
    && ln -s /opt/exhibitor/target/exhibitor*jar /opt/exhibitor/exhibitor.jar \

    # Remove build-time dependencies
    && rm -rf ~/.m2 \
    && rm -rf /opt/maven \
    && opkg-cl remove tar bzip2 libbz2 libacl libattr\
    && rm -rf /tmp/*


USER root

COPY exhibitor.sh /usr/local/bin/
COPY manage_off.sh /usr/local/bin/

WORKDIR /opt/exhibitor
EXPOSE 8181

VOLUME ["/var/lib/zookeeper", "/var/log/zookeeper"]

ENTRYPOINT ["bash", "-ex", "/usr/local/bin/exhibitor.sh"]
