FROM momonga/leiningen
MAINTAINER supermomonga

RUN mkdir -p /root/craftbukkit
RUN echo "#\!/bin/bash\ncd \"$( dirname \"$0\" )\" \njava -Xmx1536M -jar craftbukkit.jar -o true" \
      > /root/craftbukkit/run
RUN chmod +x /root/craftbukkit/run

ENTRYPOINT ["/root/craftbukkit/run"]
