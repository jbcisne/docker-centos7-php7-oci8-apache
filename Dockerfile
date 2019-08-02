FROM centos:7

MAINTAINER Juliano Buzanello <jbcisne@gmail.com>

RUN yum -C install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
        http://rpms.famillecollet.com/enterprise/7/remi/x86_64/remi-release-7.6-2.el7.remi.noarch.rpm \
    && rm -rf /var/cache/yum/* \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 /etc/pki/rpm-gpg/RPM-GPG-KEY-remi /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

RUN yum-config-manager --enable remi,remi-php72 && yum clean all

RUN yum install -y git \
    libaio \
    unzip \
    httpd \
    mysql-devel \
    mysql-libs \
    mod_ssl \
    php \
    php-devel \
    php-pear \
    php-gd \
    php-intl \
    php-tidy \
    php-pdo \
    php-cli \
    php-curl \
    php-process \
    php-xml \
    php-xmlrpc \
    php-mysql \
    php-mbstring \
    php-bcmath \
    php-ldap \
    php-mysql \
    php-pgsql \
    php-gd \
    php-soap \
    php-pecl-imagick \
    php-pecl-zip \
    php-pecl-xdebug which \
    && yum update -y \
    && rm -rf /var/cache/yum/* \
    && echo 'date.timezone=America/Sao_Paulo' > /etc/php.d/00-docker-php-date-timezone.ini \
    && yum -y update bash

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

#
# Instalando instantclient da oracle
#
ADD instantclient/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/
ADD instantclient/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/

RUN rpm -Uvh /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN rpm -Uvh /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN echo 'export LD_LIBRARY_PATH="/usr/lib/oracle/12.1/client64/lib"' >> /root/.bashrc

#
# Instalando php OCI8
# @see https://github.com/remicollet/remirepo/issues/18
#
RUN sed -i -e 's/#define HAVE_OCI8_DTRACE 1/\/\*#define HAVE_OCI8_DTRACE 1\*\//g' /usr/include/php/main/php_config.h
RUN pecl channel-update pecl.php.net
RUN echo 'instantclient,/usr/lib/oracle/12.1/client64/lib/' | pecl install oci8
RUN echo 'extension=oci8.so' > /etc/php.d/20-oci8.ini 

#
# UTC Timezone & Networking
#
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo "NETWORKING=yes" > /etc/sysconfig/network


EXPOSE 80

#CMD /usr/sbin/httpd -c "ErrorLog /dev/stdout" -DFOREGROUND


