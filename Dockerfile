FROM momonga/craftbukkit
MAINTAINER supermomonga

RUN apt-get install -y git-core

RUN git clone https://github.com/supermomonga/rukkit.git /rukkit
RUN mkdir -p /craftbukkit/plugins/rukkit/
RUN cp /rukkit/config.yml.sample /craftbukkit/plugins/rukkit/config.yml
RUN cd /rukkit && lein deps && lein uberjar
RUN ln -s -f /rukkit/target/rukkit-1.0.0-SNAPSHOT-standalone.jar /craftbukkit/plugins/rukkit.jar

ENV GEM_HOME /rukkit/vendor/gems
# RUN java -jar ~/.m2/repository/org/jruby/jruby-complete/1.7.16.1/jruby-complete-1.7.16.1.jar -S \
#       gem install bundler

VOLUME ["/rukkit"]

ENTRYPOINT ["/bin/bash"]

