FROM ubuntu:18.04
MAINTAINER RonaldMones <ronald@brixcrm.nl>

ENV MMONIT_VERSION mmonit-3.7.1
ENV MMONIT_USER monit
ENV MMONIT_ROOT /opt/monit
ENV MMONIT_BIN $MMONIT_ROOT/bin/mmonit
ENV MONIT_BIN /usr/bin/monit
ENV MONIT_LOG /var/log/monit.log
ENV MONIT_CONF $MMONIT_ROOT/conf/monitrc
ENV HOME $MMONIT_ROOT
ENV PATH $MMONIT_ROOT/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Add monit user and group
RUN groupadd -r $MMONIT_USER \
    && useradd -r -m \
       -g $MMONIT_USER \
       -d $MMONIT_ROOT \
       -s /usr/sbin/nologin \
       $MMONIT_USER

# Install monit and dependencies for mmonit
RUN apt-get update
RUN apt-get -y install wget tar

# Switch user
USER $MMONIT_USER

# Set workdir to monit root
WORKDIR $MMONIT_ROOT

# Download and install mmonit

RUN wget https://mmonit.com/dist/$MMONIT_VERSION-linux-x64.tar.gz
RUN tar -xf $MMONIT_ROOT/$MMONIT_VERSION-linux-x64.tar.gz && rm -rf $MMONIT_ROOT/$MMONIT_VERSION-linux-x64.tar.gz
RUN mv $MMONIT_ROOT/$MMONIT_VERSION/* . && rm -rf $MMONIT_ROOT/$MMONIT_VERSION

# Make config
COPY ./monitrc $MMONIT_ROOT/conf/monitrc
#    && sed -i "s/root/$EJABBERD_USER/g" $EJABBERD_ROOT/bin/ejabberdctl

# Wrapper for setting config on disk from environment
# allows setting things like MONIT_USER at runtime
COPY ./run $MMONIT_ROOT/bin/run
USER root
RUN chown monit:monit ${MMONIT_ROOT}/conf/monitrc
#RUN touch $MONIT_LOG && chown monit:monit $MONIT_LOG;
RUN touch $MMONIT_ROOT/logs/error.log && chown monit:monit $MMONIT_ROOT/logs/error.log;
RUN touch $MMONIT_ROOT/logs/mmonit.log && chown monit:monit $MMONIT_ROOT/logs/mmonit.log;
USER monit

# Add run scripts
ADD ./scripts $MMONIT_ROOT/bin/scripts

# VOLUME ["$MMONIT_ROOT/database", "$MMONIT_ROOT/ssl"]
EXPOSE 2812 8080

CMD ["start"]
ENTRYPOINT ["run"]