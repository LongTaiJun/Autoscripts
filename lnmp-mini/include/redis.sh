#!/bin/bash
# Author:Tyson
# E-mail:admin#svipc.com
# Website:http://www.svipc.com
# Version:1.0.0  Aug-16-2015-12:28:58
# Notes:Autoscripts for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+

Install_redis()
{
cd $Autoscripts_dir/src
src_url=http://download.redis.io/releases/redis-$redis_version.tar.gz && Download_src

tar xzf redis-$redis_version.tar.gz
cd redis-$redis_version
if [ "$OS_BIT" == '32' ];then
    sed -i '1i\CFLAGS= -march=i686' src/Makefile
    sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
fi

make

if [ -f "src/redis-server" ];then
    mkdir -p $redis_install_dir/{bin,etc,var}
    /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
    /bin/cp redis.conf $redis_install_dir/etc/
    ln -s $redis_install_dir/bin/* /usr/local/bin/
    sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $redis_install_dir/etc/redis.conf
    sed -i "s@logfile.*@logfile $redis_install_dir/var/redis.log@" $redis_install_dir/etc/redis.conf
    sed -i "s@^dir.*@dir $redis_install_dir/var@" $redis_install_dir/etc/redis.conf
    sed -i 's@daemonize no@daemonize yes@' $redis_install_dir/etc/redis.conf
    redis_maxmemory=`expr $Mem / 8`000000
    [ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" $redis_install_dir/etc/redis.conf
    echo "${CSUCCESS}Redis-server install successfully! ${CEND}"
    cd ..
    rm -rf redis-$redis_version
    OS_CentOS='/bin/cp ../init.d/Redis-server-init-CentOS /etc/init.d/redis-server \n
chkconfig --add redis-server \n
chkconfig redis-server on'
    OS_Debian_Ubuntu="useradd -M -s /sbin/nologin redis \n
chown -R redis:redis $redis_install_dir/var/ \n
/bin/cp ../init.d/Redis-server-init-Ubuntu /etc/init.d/redis-server \n
update-rc.d redis-server defaults"
    OS_command
    sed -i "s@/usr/local/redis@$redis_install_dir@g" /etc/init.d/redis-server
    #[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
    #sysctl -p
    service redis-server start
else
    rm -rf $redis_install_dir
    echo "${CFAILURE}Redis-server install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi

if [ -e "$php_install_dir/bin/phpize" ];then
    src_url=http://pecl.php.net/get/redis-$redis_pecl_version.tgz && Download_src
    tar xzf redis-$redis_pecl_version.tgz
    cd redis-$redis_pecl_version
    make clean
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config
    make && make install
    if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/redis.so" ];then
        [ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions  | grep zts`\"@" $php_install_dir/etc/php.ini
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "redis.so"@' $php_install_dir/etc/php.ini
        echo "${CSUCCESS}PHP Redis module install successfully! ${CEND}"
        cd ..
        rm -rf redis-$redis_pecl_version
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    else
        echo "${CFAILURE}PHP Redis install failed, Please contact the author! ${CEND}"
    fi
fi
cd ..
}
