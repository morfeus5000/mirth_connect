FROM java:8

ENV MIRTH_CONNECT_VERSION 3.3.1.7856.b91

RUN useradd -u 1000 mirth

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu


VOLUME /opt/mirth-connect/appdata

RUN \
  cd /tmp && \
  wget http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  tar xvzf mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  mv Mirth\ Connect/* /opt/mirth-connect/ && \
  chown -R mirth /opt/mirth-connect


WORKDIR /opt/mirth-connect

EXPOSE 8080 8443

COPY docker-entrypoint.sh /
COPY HL7-MYSQL.xml / 

RUN \
  cd /tmp && \
  cp HL7-MYSQL.xml /opt/mirth-connect/

RUN echo "/opt/mirth-connect/HL7-MYSQL.xml" > /opt/mirth-connect/import.txt

RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]



CMD ["java", "-jar", "mirth-server-launcher.jar"]
CMD ["java", "-jar", "mirth-cli-launcher.jar -a https://127.0.0.1:8443 -u admin -p admin -v 0.0.0 -s '/opt/mirth-connect/import.txt']"
