#!/bin/bash

#
#
#

apt-get update
apt-get -q -y install ruby ruby-dev git devscripts autotools-dev build-essential libsqlite3-dev sqlite3 zlib1g-dev nodejs
gem install bundler

git clone https://github.com/arax/guocci.git /opt/guocci
cd /opt/guocci
bundle install
