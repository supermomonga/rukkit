FROM java:8-jdk
MAINTAINER supermomonga

ENV LEIN_ROOT true

RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
      -o /usr/local/bin/lein \
      && chmod a+x /usr/local/bin/lein
RUN lein

RUN apt-get install -y git-core

RUN mkdir -p /craftbukkit/plugins/rukkit/gems/
ENV GEM_HOME /craftbukkit/plugins/rukkit/gems/

WORKDIR /rukkit
COPY ./project.clj /rukkit/project.clj
COPY ./spigot-1.10.jar /rukkit/spigot-1.10.jar
RUN lein deploy localrepo org.spigotmc/spigot 1.10 spigot-1.10.jar
RUN lein deps
COPY ./ /rukkit
RUN lein uberjar
RUN ln -s -f /rukkit/target/rukkit-1.0.0-SNAPSHOT-standalone.jar /craftbukkit/plugins/rukkit.jar
