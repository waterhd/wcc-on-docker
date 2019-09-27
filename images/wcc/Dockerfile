#
# Copyright (c) 2018 Oracle and/or its affiliates. All rights reserved.
#
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
# Description: This file is used to build Oracle WebCenter Content image
#
# Pull base image from the Oracle Container Registry or Docker Store and tag the name as 'oracle/fmw-infrastructure:12.2.1.3'
# -------------------------------------------------------------
FROM oracle/fmw-infrastructure:12.2.1.3

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
USER root

ENV ORACLE_HOME=/u01/oracle \
	USER_MEM_ARGS="-Djava.security.egd=file:/dev/urandom" \
	MW_HOME=/u01/oracle \
	UCM_ORACLE_HOME=/u01/oracle/wccontent \
	WLS_HOME=/u01/oracle/wlserver/server \
	WL_HOME=/u01/oracle/wlserver \
	DOMAIN_ROOT=/u01/oracle/user_projects/domains \
	PATH=$PATH:$JAVA_HOME/bin:/u01/oracle/oracle_common/common/bin \
	CONTAINER_SCRIPT_DIR=/u01/oracle/container-scripts \
	CONTENT_PKG=fmw_12.2.1.3.0_wccontent_Disk1_1of1.zip \
	CONTENT_SHA1=945b1514a7f8fcc48484939458bc6898b0a37cdc \
	CONTENT_JAR=fmw_12.2.1.3.0_wccontent.jar \
	ADMIN_PORT=7001 \
	WCCONTENT_PORT=16200 \
	ADMIN_SSL_PORT=9001 \
	WCCONTENT_SSL_PORT=9002 \
	LANG=en_US.UTF8 \
	LC_ALL=en_US.UTF8 \
	NLS_LANG=AMERICAN_AMERICA

# Copy packages and scripts
# -------------------------------------------------------------
COPY install.file oraInst.loc /u01/

# Install missing packages
# -------------------------------------------------------------
RUN yum install -y unzip hostname && rm -rf /var/cache/yum

#Install packages and adjust file permissions, go to /u01 as user 'oracle' to proceed with WLS installation
# -------------------------------------------------------------
RUN mkdir -p /u01/oracle/logs && chmod a+xr /u01

# Install as user
# -------------------------------------------------------------
USER oracle

# Base URL can be adjusted if needed
ARG BASE_URL=http://localhost:8000/oracle/fmw

# Download install file and install
RUN curl -fLO# "$BASE_URL/$CONTENT_PKG" \
 && printf "%s *%s\n" $CONTENT_SHA1 $CONTENT_PKG | sha1sum -c \
 && unzip $CONTENT_PKG \
 && $JAVA_HOME/bin/java -jar $CONTENT_JAR -silent -force -novalidation -ignoreSysPrereqs \
      -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -jreLoc $JAVA_HOME ORACLE_HOME=$ORACLE_HOME \
 && rm -rf $CONTENT_JAR $CONTENT_PKG /u01/oraInst.loc /u01/install.file

WORKDIR $ORACLE_HOME

COPY --chown=oracle wait-for createDomain.py createDomainAndStart.sh $CONTAINER_SCRIPT_DIR/

# Make scripts executable
RUN chmod +x $CONTAINER_SCRIPT_DIR/*.sh

# Set defaults
ENV ADMIN_USERNAME=weblogic DB_PORT=1521 DOMAIN_NAME=wcc RUN_RCU=1 WAIT_TIMEOUT=1800 \
    MANAGED_SERVER=UCM_server1 \
    DOMAIN_TEMPLATE="Oracle Universal Content Management - Content Server"

# Define default command to start bash.
CMD ["createDomainAndStart.sh"]

# Expose all Ports
EXPOSE $ADMIN_PORT $ADMIN_SSL_PORT $WCCONTENT_PORT $WCCONTENT_SSL_PORT
