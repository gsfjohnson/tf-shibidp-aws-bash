#!/bin/bash

hostnamectl set-hostname ${fqdn}

yum -y install git wget unzip tomcat8

exit

cat <<EOFEOF >/etc/sysconfig/iptables
# Generated by iptables-save v1.4.21 on Fri Jun 17 04:03:09 2016
*nat
:PREROUTING  ACCEPT [0:0]
:INPUT       ACCEPT [0:0]
:OUTPUT      ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
-A PREROUTING -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 8443
COMMIT
# Completed on Fri Jun 17 04:03:09 2016

# Generated by iptables-save v1.4.21 on Fri Jun 17 04:03:09 2016
*filter
:INPUT   ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT  ACCEPT [0:0]
COMMIT
# Completed on Fri Jun 17 04:03:09 2016
EOFEOF

fn="jdk-8u91-linux-x64"
wget -c --no-cookies --no-check-certificate \
 --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
 "http://download.oracle.com/otn-pub/java/jdk/8u91-b14/${fn}.rpm" \
 --output-document="/tmp/${fn}.rpm"

wget -c --no-cookies --no-check-certificate \
 --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
 "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" \
 --output-document="/tmp/jce_policy-8.zip"

yum localinstall /tmp/jdk-8u91-linux-x64.rpm
unzip /tmp/jce_policy-8.zip -d /opt
cp -f /opt/UnlimitedJCEPolicyJDK8/*jar /usr/java/jdk1.8.0_91/jre/lib/security/

echo export JAVA_HOME=/opt/java >>/etc/profile

##
## install jetty
##
fn="jetty-distribution-9.3.9.v20160517"
wget -c --no-cookies --no-check-certificate \
  "http://eclipse.org/downloads/download.php?file=/jetty/stable-9/dist/${fn}.tar.gz&r=1" \
  --output-document="/tmp/${fn}.tar.gz"

tar xzf /tmp/${fn}.tar.gz -C /opt
cd /opt
ln -s $fn jetty

useradd -m jetty
chown -R jetty:jetty /opt/jetty/
ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty
chkconfig --add jetty
chkconfig --level 345 jetty on
cat <<EOFEOF >/etc/default/jetty
JETTY_HOME=/opt/jetty
JETTY_USER=jetty
JETTY_PORT=80
JETTY_HOST=0.0.0.0
JETTY_LOGS=/opt/jetty/logs/
EOFEOF

#service jetty start
