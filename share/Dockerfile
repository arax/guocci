FROM ubuntu:14.04

MAINTAINER Boris Parak <parak@cesnet.cz>

# FedCloud stuff
ADD fedcloud-ui.sh /tmp/fedcloud-ui.sh
RUN /tmp/fedcloud-ui.sh

# Fixing voms-clients
RUN rm /var/lib/voms-clients3/lib/*
ADD libs/* /var/lib/voms-clients3/lib/

# GUOCCI stuff
ADD guocci-setup.sh /tmp/guocci-setup.sh
RUN /tmp/guocci-setup.sh
ADD guocci-run.sh /opt/

# Volume for the VOMS proxy
VOLUME [ "/tmp" ]

# GUOCCI runs on 0.0.0.0:3000 by default
EXPOSE 3000

# Start GUOCCI by default
CMD ["/opt/guocci-run.sh"]
