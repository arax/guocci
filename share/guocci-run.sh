#!/bin/bash

#
#
#

cd /opt/guocci
service memcached status || service memcached start
bundle exec rails server -b 0.0.0.0 -e production
