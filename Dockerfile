FROM        ubuntu:16.04

# Update the package repository and install applications
RUN apt-get update -qq && \
  apt-get upgrade -yqq && \
  apt-get -yqq install varnish && \
  apt-get -yqq install iputils-ping && \
  apt-get -yqq clean

# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl

ENV VARNISH_PORT 80

# Expose port 80
EXPOSE 80

ADD start.sh /start.sh
CMD ["/start.sh"]
