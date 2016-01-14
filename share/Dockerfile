FROM ubuntu:14.04

MAINTAINER Boris Parak <parak@cesnet.cz>

# FedCloud stuff
ADD fedcloud-ui.sh /tmp/fedcloud-ui.sh
RUN /tmp/fedcloud-ui.sh
RUN fetch-crl -v || true
RUN echo "alias occi='occi --auth x509 --user-cred /tmp/x509up_u1000 --voms'" >> /root/.bashrc
RUN echo "alias voms-proxy-info='voms-proxy-info -file /tmp/x509up_u1000'" >> /root/.bashrc
RUN echo "alias voms-proxy-init='voms-proxy-init -out /tmp/x509up_u1000'" >> /root/.bashrc
RUN echo "alias voms-proxy-destroy='voms-proxy-destroy -file /tmp/x509up_u1000'" >> /root/.bashrc

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
