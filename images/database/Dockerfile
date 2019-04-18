# LICENSE UPL 1.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database 12c Release 1 Enterprise Edition
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) linuxamd64_12102_database_1of2.zip
#     linuxamd64_12102_database_2of2.zip
#     Download Oracle Database 12c Release 1 Enterprise Edition for Linux x64
#     from http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run:
#      $ docker build -t oracle/database:12.1.0.2-ee .
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim as base

# Maintainer
# ----------
MAINTAINER Gerald Venzl <gerald.venzl@oracle.com>

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/12.1.0.2/dbhome_1 \
    INSTALL_DIR=/opt/install

# Use second ENV so that variable get substituted
ENV PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH \
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib \
    CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

# Copy files needed during both installation and runtime
# -------------
COPY setupLinuxEnv.sh checkSpace.sh $INSTALL_DIR/
COPY runOracle.sh startDB.sh createDB.sh dbca.rsp.tmpl setPassword.sh checkDBStatus.sh runUserScripts.sh $ORACLE_BASE/

RUN chmod -cv ug+x $INSTALL_DIR/*.sh && \
    sync && \
    $INSTALL_DIR/checkSpace.sh && \
    $INSTALL_DIR/setupLinuxEnv.sh && \
    rm -rf $INSTALL_DIR

#############################################
# Start new stage for installing the database
#############################################
FROM base AS builder

COPY --chown=oracle:dba db_inst.rsp.tmpl installPerl.sh installDBBinaries.sh $INSTALL_DIR/

# Install DB software binaries
USER oracle

# Software repository URL and file names for installation
ARG REPO_URL=http://localhost:8000/
ARG INSTALL_FILE_1="linuxamd64_12102_database_1of2.zip"
ARG INSTALL_FILE_2="linuxamd64_12102_database_2of2.zip"
ARG EDITION=EE

RUN chmod ug+x $INSTALL_DIR/*.sh \
 && cd $INSTALL_DIR \
 && curl -fL#O "$REPO_URL/{$INSTALL_FILE_1,$INSTALL_FILE_2}" \
 && cd - \
 && sync \
 && $INSTALL_DIR/installDBBinaries.sh $EDITION

#############################################
# Start new layer for database runtime
#############################################

FROM base

COPY --chown=oracle:dba --from=builder $ORACLE_BASE $ORACLE_BASE

RUN $ORACLE_BASE/oraInventory/orainstRoot.sh && \
    $ORACLE_HOME/root.sh

# Switch to Oracle user
USER oracle

# Default settings for new databases
ENV DBCA_TEMPLATE_FILE=General_Purpose.dbc \
    ORACLE_EM_CONFIG=DBEXPRESS \
    ORACLE_CHARACTERSET=AL32UTF8

# Switch to home directory
WORKDIR /home/oracle

VOLUME ["$ORACLE_BASE/oradata"]

EXPOSE 1521 5500

HEALTHCHECK --interval=1m --start-period=5m CMD "$ORACLE_BASE/checkDBStatus.sh" >/dev/null || exit 1

# Define default entrypoint to start Oracle Database.
ENTRYPOINT $ORACLE_BASE/runOracle.sh
