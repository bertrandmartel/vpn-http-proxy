FROM amazonlinux:2

COPY start.sh /data/start.sh

RUN yum update -y && \
    amazon-linux-extras install epel && \
    yum install -y unzip jq openvpn gettext iputils squid && \
    amazon-linux-extras install -y nginx1 && \
    chmod +x /data/start.sh

COPY client.conf.template /etc/openvpn/client.conf.template

ENTRYPOINT ["/data/start.sh"]