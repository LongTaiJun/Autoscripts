#!/bin/bash
# Author:Tyson
# E-mail:admin#svipc.com
# Website:http://www.svipc.com
# Version:1.0.0  Aug-16-2015-12:28:58
# Notes:Autoscripts for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+

Install_hhvm_CentOS()
{
cd $Autoscripts_dir/src

id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 

if [ "$CentOS_RHEL_version" == '7' ];then
    if [ -e /etc/yum.repos.d/epel.repo_bk ];then
        /bin/mv /etc/yum.repos.d/epel.repo{_bk,}
    elif [ ! -e /etc/yum.repos.d/epel.repo ];then
        cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
    fi
    cat > /etc/yum.repos.d/hhvm.repo << EOF
[hhvm]
name=Copr repo for hhvm-repo owned by no1youknowz
baseurl=https://copr-be.cloud.fedoraproject.org/results/no1youknowz/hhvm-repo/epel-7-\$basearch/
skip_if_unavailable=True
gpgcheck=0
enabled=0
EOF
    yum --enablerepo=hhvm -y install hhvm
    [ ! -e "/usr/bin/hhvm" -a "/usr/local/bin/hhvm" ] && ln -s /usr/local/bin/hhvm /usr/bin/hhvm
fi

if [ "$CentOS_RHEL_version" == '6' ];then
    if [ -e /etc/yum.repos.d/epel.repo_bk ];then
        /bin/mv /etc/yum.repos.d/epel.repo{_bk,}
    elif [ ! -e /etc/yum.repos.d/epel.repo ];then
        cat > /etc/yum.repos.d/epel.repo << EOF 
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
    fi

    for Package in libmcrypt-devel glog-devel jemalloc-devel tbb-devel libdwarf-devel mysql-devel libxml2-devel libicu-devel pcre-devel gd-devel boost-devel sqlite-devel pam-devel bzip2-devel oniguruma-devel openldap-devel readline-devel libc-client-devel libcap-devel libevent-devel libcurl-devel libmemcached-devel lcms2 inotify-tools
    do
        yum -y install $Package
    done

    [ "$IPADDR_STATE"x == "CN"x ] && REMI_ADDR=http://mirrors.swu.edu.cn || REMI_ADDR=http://mirrors.mediatemple.net

    cat > /etc/yum.repos.d/remi.repo << EOF
[remi]
name=Les RPM de remi pour Enterprise Linux 6 - \$basearch
baseurl=$REMI_ADDR/remi/enterprise/6/remi/\$basearch/
#mirrorlist=http://rpms.famillecollet.com/enterprise/6/remi/mirror
enabled=0
gpgcheck=0
EOF

    yum -y remove libwebp
    src_url=http://mirrors.svipc.com/Autoscripts/libwebp-0.3.1-2.el6.remi.x86_64.rpm && Download_src
    src_url=http://mirrors.svipc.com/Autoscripts/hhvm-3.5.0-4.el6.x86_64.rpm && Download_src
    rpm -ivh libwebp-0.3.1-2.el6.remi.x86_64.rpm
    yum --enablerepo=remi --disablerepo=epel -y install mysql mysql-devel mysql-libs

    yum -y remove boost-system boost-filesystem

    cat > /etc/yum.repos.d/gleez.repo << EOF
[gleez]
name=Gleez repo
baseurl=http://yum.gleez.com/6/\$basearch/
enabled=0
gpgcheck=0
EOF
    ping yum.gleez.com -c 4 >/dev/null 2>&1
    yum --enablerepo=gleez --disablerepo=epel -y install -R 2 ./hhvm-3.5.0-4.el6.x86_64.rpm
fi

userdel -r nginx;userdel -r saslauth
rm -rf /var/log/hhvm
mkdir /var/log/hhvm
chown -R ${run_user}.${run_user} /var/log/hhvm
cat > /etc/hhvm/config.hdf << EOF
ResourceLimit {
  CoreFileSize = 0          # in bytes
  MaxSocket = 10000         # must be not 0, otherwise HHVM will not start
  SocketDefaultTimeout = 5  # in seconds
  MaxRSS = 0
  MaxRSSPollingCycle = 0    # in seconds, how often to check max memory
  DropCacheCycle = 0        # in seconds, how often to drop disk cache
}

Log {
  Level = Info
  AlwaysLogUnhandledExceptions = true
  RuntimeErrorReportingLevel = 8191
  UseLogFile = true
  UseSyslog = false
  File = /var/log/hhvm/error.log
  Access {
    * {
      File = /var/log/hhvm/access.log
      Format = %h %l %u % t \"%r\" %>s %b
    }
  }
}

MySQL {
  ReadOnly = false
  ConnectTimeout = 1000      # in ms
  ReadTimeout = 1000         # in ms
  SlowQueryThreshold = 1000  # in ms, log slow queries as errors
  KillOnTimeout = false
}

Mail {
  SendmailPath = /usr/sbin/sendmail -t -i
  ForceExtraParameters =
}
EOF

cat > /etc/hhvm/server.ini << EOF
; php options
pid = /var/log/hhvm/pid

; hhvm specific
;hhvm.server.port = 9001
hhvm.server.file_socket = /var/log/hhvm/sock
hhvm.server.type = fastcgi
hhvm.server.default_document = index.php
hhvm.log.use_log_file = true
hhvm.log.file = /var/log/hhvm/error.log
hhvm.repo.central.path = /var/log/hhvm/hhvm.hhbc
EOF

cat > /etc/hhvm/php.ini << EOF
hhvm.mysql.socket = /tmp/mysql.sock
expose_php = 0
memory_limit = 400000000
post_max_size = 50000000
EOF

if [ -e "/usr/bin/hhvm" -a ! -e "$php_install_dir" ];then
    sed -i 's@/dev/shm/php-cgi.sock@/var/log/hhvm/sock@' $web_install_dir/conf/nginx.conf 
    [ -z "`grep 'fastcgi_param SCRIPT_FILENAME' $web_install_dir/conf/nginx.conf`" ] && sed -i "s@fastcgi_index index.php;@&\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;@" $web_install_dir/conf/nginx.conf 
    sed -i 's@include fastcgi.conf;@include fastcgi_params;@' $web_install_dir/conf/nginx.conf 
    service nginx reload
fi

rm -rf /etc/ld.so.conf.d/*_64.conf
ldconfig
# Supervisor
yum -y install python-setuptools
ping pypi.python.org -c 4 >/dev/null 2>&1
easy_install supervisor
echo_supervisord_conf > /etc/supervisord.conf
sed -i 's@pidfile=/tmp/supervisord.pid@pidfile=/var/run/supervisord.pid@' /etc/supervisord.conf
[ -z "`grep 'program:hhvm' /etc/supervisord.conf`" ] && cat >> /etc/supervisord.conf << EOF
[program:hhvm]
command=/usr/bin/hhvm --mode server --user $run_user --config /etc/hhvm/server.ini --config /etc/hhvm/php.ini --config /etc/hhvm/config.hdf
numprocs=1 ; number of processes copies to start (def 1)
directory=/tmp ; directory to cwd to before exec (def no cwd)
autostart=true ; start at supervisord start (default: true)
autorestart=unexpected ; whether/when to restart (default: unexpected)
stopwaitsecs=10 ; max num secs to wait b4 SIGKILL (default 10)
EOF
src_url=https://github.com/Supervisor/initscripts/raw/master/redhat-init-mingalevme && Download_src
/bin/mv redhat-init-mingalevme /etc/init.d/supervisord
chmod +x /etc/init.d/supervisord
chkconfig supervisord on
service supervisord start
cd ..
}
