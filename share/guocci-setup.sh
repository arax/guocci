#!/bin/bash

#
#
#

apt-get update
apt-get -q -y install ruby2.0 ruby2.0-dev git devscripts autotools-dev build-essential libsqlite3-dev sqlite3 zlib1g-dev nodejs

rm /usr/bin/ruby && ln -s /usr/bin/ruby2.0 /usr/bin/ruby
rm -fr /usr/bin/gem && ln -s /usr/bin/gem2.0 /usr/bin/gem

gem install bundler

git clone https://github.com/arax/guocci.git /opt/guocci
cd /opt/guocci
bundle install
