FROM centos:7

# build environment
WORKDIR /root/

# Dev stuff
RUN yum -y install curl wget

# Python
RUN curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o /tmp/get-pip.py && \
	python /tmp/get-pip.py && \
	rm /tmp/get-pip.py

# Supervisord
RUN pip install supervisor==3.3.3 && \
	mkdir -p /var/log/supervisord/

# Kerberos client
RUN yum -y install ntp krb5-workstation krb5-libs

CMD ["bash", "-c", "echo 'Hello world'"]