#!/bin/bash
set -e

# Load base utility functions like sunzi.mute() and sunzi.install()
source recipes/sunzi.sh

# This line is necessary for automated provisioning for Debian/Ubuntu.
# Remove if you're not on Debian/Ubuntu.
export DEBIAN_FRONTEND=noninteractive

# Add Dotdeb repository. Recommended if you're using Debian. See http://www.dotdeb.org/about/
# source recipes/dotdeb.sh
# source recipes/backports.sh

# Update apt catalog and upgrade installed packages
sunzi.mute "apt-get update"
sunzi.mute "apt-get -y upgrade"

# Install packages
apt-get -y install git-core ntp curl

# Install sysstat, then configure if this is a new install.
if sunzi.install "sysstat"; then
  sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
  /etc/init.d/sysstat restart
fi

if [[ "$(which java)" != /usr/bin/java ]]; then
  echo "Installing Java"
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

  # sunzi.mute "add-apt-repository -y ppa:webupd8team/java"
  sunzi.mute "apt-get update"
  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  apt-get -y install oracle-java8-installer
  apt-get -y install oracle-java8-set-default
  java -version
fi

if [[ "$(which lein)" != /usr/local/bin/lein ]]; then
  echo "Installing leiningen"
  sunzi.mute "curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o /usr/local/bin/lein"
  sunzi.mute "chmod a+x /usr/local/bin/lein"
  sunzi.mute "lein"
fi


if [ ! -e /home/vagrant/craftbukkit/craftbukkit.jar ]; then
  echo "Installing craftbukkit"
  craftbukkit_url=<%= @attributes.craftbukkit_url %>
  craftbukkit_md5=<%= @attributes.craftbukkit_md5 %>
  mkdir -p /home/vagrant/craftbukkit
  sunzi.mute "curl $craftbukkit_url -o /home/vagrant/craftbukkit/craftbukkit.jar"
  hash=`openssl md5 /home/vagrant/craftbukkit/craftbukkit.jar | awk '{print $2}'`
  echo "hash: $hash"
  if [[ "$hash" != "$craftbukkit_md5" ]]; then
    echo "MD5 hash didn't match. Removing it."
    rm /home/vagrant/craftbukkit/craftbukkit.jar
  fi
fi

# Install Ruby using rbenv
source recipes/rbenv.sh
ruby_version=<%= @attributes.ruby_version %>

if [[ "$(which ruby)" != /usr/local/rbenv/versions/$ruby_version* ]]; then
  echo "Installing ruby-$ruby_version"
  # Install dependencies using RVM autolibs - see https://blog.engineyard.com/2013/rvm-ruby-2-0
  rbenv install $ruby_version
  rbenv global $ruby_version
  echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

  # Install Bundler
  gem install bundler
fi

echo "Provisioning finished."
