# Start from CentOS base image
FROM centos:centos7
MAINTAINER Yair Zaslavsky <yair.zaslavsky@gmail.com>
MAINTAINER Anatoly Litovsky <anatoly.lit@gmail.com>

# Environment variables
ENV \
    GUAC_VERSION=0.9.9 \
    LC_ALL=en_US.UTF-8 \

#Required setting for tomcat - due to guac server
    TOMCAT_MAJOR 8 \
    ENV TOMCAT_VERSION 8.0.32 \
    ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \

#Required by guac client
    GUAC_JDBC_VERSION=0.9.9 \
    GUAC_LDAP_VERSION=0.9.9

RUN yum -y update i



#GUACD
# Bring environment up-to-date, install guacamole-server build dependencies



RUN yum -y install epel-release && \
    yum -y install             \
        cairo-devel            \
        dejavu-sans-mono-fonts \
        freerdp-devel          \
        freerdp-plugins        \
        gcc                    \
        ghostscript            \
        libjpeg-turbo-devel    \
        libssh2-devel          \
        liberation-mono-fonts  \
        libtelnet-devel        \
        libvorbis-devel        \
        libvncserver-devel     \
        libwebp-devel          \
        make                   \
        pango-devel            \
        pulseaudio-libs-devel  \
        tar                    \
        terminus-fonts         \
        uuid-devel              && \
    yum clean all


#TODO: CMD [ "/usr/local/sbin/guacd", "-b", "0.0.0.0", "-f" ]

COPY bin /opt/guacd/bin/

# Download and install latest guacamole-server
RUN /opt/guacd/bin/download-guacd.sh "$GUAC_VERSION"

#Cagefox
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y x11vnc xorg-x11-server-Xvfb git net-tools which python procps-ng hostname numpy python-websockify


#GUAC-CLIENT
#TOMCAT
RUN yum install java-1.7.0-openjdk


ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

RUN set -ex \
	&& for key in \
		05AB33110949707C93A279E3D3EFE6B686867BA6 \
		07E48665A34DCAFAE522E5E6266191C37C037D42 \
		47309207D818FFD8DCD3F83F1931D684307A10A5 \
		541FBE7D8F78B25E055DDEE13C370389288584E7 \
		61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
		79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
		9BA44C2621385CB966EBA586F72C284D731FABEE \
		A27677289986DB50844682F8ACB77FC2E86E29AC \
		A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
		DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
		F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
		F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23 \
	; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done


RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*



### TODO: Here there was CMD ["catalina.sh", "run"] - should we run it in this stage?


#TOMCAT PORT
EXPOSE 8080
#GUACD PORT
EXPOSE 4822