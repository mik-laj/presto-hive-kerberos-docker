# Dockerfile - kdc-server
#
# see docker-compose.yml

FROM centos:8

# build environment
WORKDIR /root/

# Fix CenttOS mirrors: https://techglimpse.com/failed-metadata-repo-appstream-centos-8/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Dev stuff
RUN dnf -y install curl wget python3 && dnf clean all

# python
RUN curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o /tmp/get-pip.py && \
    python3 /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# supervisord
RUN pip install supervisor && \
    mkdir -p /var/log/supervisord/

# kerberos server
RUN dnf -y install chrony krb5-server krb5-libs && dnf clean all

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
