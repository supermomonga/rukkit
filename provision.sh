
apt-get update
apt-get -y upgrade
apt-get -y install git-core ntp curl

craftbukkit_url=http://tcpr.ca/files/craftbukkit/craftbukkit-1.7.9-R0.1-20140501.232444-18.jar
craftbukkit_md5=9fbcce9e7ea0a9883ef47bb83abdb4e7
craftbukkit_allow_memory_size=1536M

if [[ "$(which java)" != /usr/bin/java ]]; then
  echo "Installing Java"
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

  # add-apt-repository -y ppa:webupd8team/java
  apt-get update
  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  apt-get -y install oracle-java8-installer
  apt-get -y install oracle-java8-set-default
  java -version
fi

if [[ "$(which lein)" != /usr/local/bin/lein ]]; then
  echo "Installing leiningen"
  curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o /usr/local/bin/lein
  chmod a+x /usr/local/bin/lein
  lein
fi


# Install craftbukkit
if [ ! -e /home/vagrant/craftbukkit/craftbukkit.jar ]; then
  echo "Installing craftbukkit"
  mkdir -p /home/vagrant/craftbukkit
  curl $craftbukkit_url -o /home/vagrant/craftbukkit/craftbukkit.jar
  hash=`openssl md5 /home/vagrant/craftbukkit/craftbukkit.jar | awk '{print $2}'`
  echo "hash: $hash"
  if [[ "$hash" != "$craftbukkit_md5" ]]; then
    echo "MD5 hash didn't match. Removing it."
    rm /home/vagrant/craftbukkit/craftbukkit.jar
  fi
fi

if [ ! -e /home/vagrant/craftbukkit/run ]; then
  echo "Creating runner"
  mkdir -p /home/vagrant/craftbukkit
  touch /home/vagrant/craftbukkit/run
  chmod +x /home/vagrant/craftbukkit/run
  echo "#!/bin/bash" >> /home/vagrant/craftbukkit/run
  echo 'cd "$( dirname "$0" )"' >> /home/vagrant/craftbukkit/run
  echo "java -Xmx$craftbukkit_allow_memory_size -jar craftbukkit.jar -o true" >> /home/vagrant/craftbukkit/run
fi

echo "Install leiningen deps"
cd /vagrant
sudo -u vagrant lein deps :tree
sudo -u vagrant lein deps :tree

if [ ! -e /home/vagrant/craftbukkit/plugins/rukkit.jar ]; then
  mkdir -p /home/vagrant/craftbukkit/plugins
  mkdir -p /home/vagrant/craftbukkit/plugins/rukkit
  ln -s /home/vagrant/rukkit/target/rukkit-1.0.0-SNAPSHOT-standalone.jar /home/vagrant/craftbukkit/plugins/rukkit.jar
fi

if [ ! -e /home/vagrant/craftbukkit/plugins/rukkit/config.yml ]; then
  mkdir -p /home/vagrant/craftbukkit/plugins
  mkdir -p /home/vagrant/craftbukkit/plugins/rukkit
  cp /home/vagrant/rukkit/config.yml.sample /home/vagrant/craftbukkit/plugins/rukkit/config.yml
fi

chown vagrant.vagrant -R /home/vagrant
