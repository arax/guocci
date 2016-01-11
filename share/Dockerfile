FROM ubuntu:14.04

MAINTAINER Boris Parak <parak@cesnet.cz>

ADD guocci-setup.sh /tmp/guocci-setup.sh
RUN /tmp/guocci-setup.sh

ADD guocci-run.sh /opt/

VOLUME [ "/etc/grid-security/certificates", "/tmp" ]

EXPOSE 3000
CMD ["/opt/guocci-run.sh"]
