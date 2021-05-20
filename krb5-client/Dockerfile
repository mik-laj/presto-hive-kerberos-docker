FROM centos:8

# build environment
WORKDIR /root/

# Dev stuff
RUN yum -y install curl wget ntp krb5-workstation krb5-libs && yum clean all

CMD ["bash", "-c", "echo 'Hello world'"]
