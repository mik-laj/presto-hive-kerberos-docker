# Dockerfile - kdc-server
#
# see docker-compose.yml

FROM centos:8

# build environment
WORKDIR /root/

# Dev stuff
RUN yum -y install curl wget && yum clean all

# python
RUN curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o /tmp/get-pip.py && \
    python /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# supervisord
RUN pip install supervisor==3.3.3 && \
    mkdir -p /var/log/supervisord/

# kerberos server
RUN yum -y install ntp krb5-server krb5-libs && yum clean all

# kerberos server configuration
ENV KRB5_CONFIG=/etc/krb5.conf
ENV KRB5_KDC_PROFILE=/var/kerberos/krb5kdc/kdc.conf

RUN mkdir -pv /var/kerberos/krb5kdc/
COPY kdc.conf /var/kerberos/krb5kdc/kdc.conf
COPY kadm5.acl /var/kerberos/krb5kdc/kadm5.acl
COPY krb5.conf /etc/krb5.conf
RUN mkdir -pv /var/log/kerberos/ && \
    touch /var/log/kerberos/kadmin.log && \
    touch /var/log/kerberos/krb5lib.log && \
    touch /var/log/kerberos/krb5.log && \
    kdb5_util -r EXAMPLE.COM -P krb5 create -s

# kerberos utils
COPY utils /opt/kerberos-utils/

# supervisord configuration
COPY supervisord.conf /etc/supervisord.conf

# entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
