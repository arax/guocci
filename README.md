# guocci
A proof-of-concept GUI for (r)OCCI

## Requirements
* Ruby 2+ (and devel dependencies) installed
* `memcached` installed and running on `localhost:11211`
* `nodejs` installed

## Usage
```bash
gem install bundler
```
```bash
git clone https://github.com/arax/guocci.git
cd guocci
bundle install
```
```bash
export GUOCCI_VO_FILTER="fedcloud.egi.eu"
export GUOCCI_VOMS_PROXY_PATH="/tmp/x509up_u$(id -u)"
export GUOCCI_CA_PATH="/etc/grid-security/certificates"
bundle exec rails s
```
Go to [http://localhost:3000](http://localhost:3000).
