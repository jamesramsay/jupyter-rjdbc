FROM jupyter/r-notebook

MAINTAINER James Ramsay <git@jwr.vc>

USER root

# Temporarily add jessie backports to get openjdk 8, but then remove that source
# Java 8 is a dependency of the Athena JDBC driver
RUN echo 'deb http://cdn-fastly.deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get -y update && \
    apt-get install --no-install-recommends -t jessie-backports -y openjdk-8-jdk openjdk-8-jre-headless ca-certificates-java && \
    rm /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    /usr/sbin/update-java-alternatives -s java-1.8.0-openjdk-amd64

USER $NB_USER

RUN conda install --quiet --yes 'r-rjava'

# By default R fails to find jni.h so we specify the include directory manually
RUN R CMD javareconf JAVA_CPPFLAGS=-I/usr/lib/jvm/default-java/include

# Installing RJDBC fails unless we set the LD_LIBRARY_PATH to point to paths containing libjvm.so
ENV LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64

COPY rjdbc.R /tmp
RUN R -f /tmp/rjdbc.R

COPY athena.R /tmp
RUN R -f /tmp/athena.R

