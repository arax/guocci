#!/bin/bash

#
#
#

# Location
cd /opt/guocci

# Services
service memcached status || service memcached start

# ENV
export SECRET_KEY_BASE="f337c64a560bb7af70cfbf0d8e7d1b3fde4252a2ff4332bc94414dfd052797527f94eceafcbd11b0278320c97f1905ffaeabfe9b651e0c6119051079f4249274"

# Start!
bundle exec rails server -b 0.0.0.0 -e production
