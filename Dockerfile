#
# Shibboleth Identity Provider
#
# Builds a partial image for running the Shibboleth Identity Provider.
#
# This includes Java, Jetty and the Jetty configuration. At present,
# the IdP itself and its configuration are mounted into the container.
#

#
# The base Java image to use is determined by a build argument.
#
ARG JAVA_VERSION
FROM ${JAVA_VERSION}

MAINTAINER Ryu, Gyoung-Seok <narzis@gmail.com>

#
# Jetty itself lives in JETTY_HOME.
#
ENV JETTY_HOME=/opt/jetty

#
# The Jetty base lives in JETTY_BASE, outside the Shibboleth IdP.
#
ENV JETTY_BASE=/opt/jetty-base

#
# A subdirectory of JETTY_BASE is used for Jetty's logs, and is
# exposed as a volume.
#
ENV JETTY_LOGS=${JETTY_BASE}/logs
VOLUME ["${JETTY_LOGS}"]

ENV IDP_HOME=/opt/shibboleth-idp

#
# Add the Jetty base.
#
ARG JETTY_BASE_VERSION
ADD jetty-base-${JETTY_BASE_VERSION} ${JETTY_BASE}
ARG SHIB_RELEASE
#
# Add the Jetty distribution.
#
ADD jetty-dist/dist          ${JETTY_HOME}
EXPOSE 80 443 8443

VOLUME ["${IDP_HOME}"]
# RUN yum -y update && yum -y install \
#     wget 

# RUN wget -P /opt/shibboleth-idp/webapp/WEB-INF/lib/ https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.6.0.0/ojdbc8-19.6.0.0.jar
# RUN yum clean all
WORKDIR ${JETTY_BASE}
CMD ["java",\
    "-Djdk.tls.ephemeralDHKeySize=2048", \
    "-Didp.home=/opt/shibboleth-idp", \
    "-Djetty.base=/opt/jetty-base",\
    "-Djetty.logs=/opt/jetty-base/logs",\
    # "-jar", "/opt/jetty/start.jar"]
    "-jar", "/opt/jetty/start.jar"]
    # ,  "--list-modules"]

#
# Add Jetty configuration overlay from a tar archive.
#
ADD overlay/jetty-base-${JETTY_BASE_VERSION}.tar ${JETTY_BASE}
ADD overlay/shibboleth.tar /data/shibboleth-overlay
#
# End.
#
