This script is written using the shell, in order to quickly deploy `LEMP`/`LAMP`/`LNMP`/`LNMPA`(Linux, Nginx/Tengine, MySQL in a production environment/MariaDB/Percona, PHP), applicable to CentOS 5~7(including RedHat), Debian 6~8, Ubuntu 12.04~15.04 of 32 and 64.

Script properties:
- Continually updated
- Source compiler installation, most stable source is the latest version, and download from the official site
- Some security optimization
- Providing a plurality of database versions (MySQL-5.6, MySQL-5.5, MariaDB-10.0, MariaDB-5.5, Percona-5.6, Percona-5.5)
- Providing multiple PHP versions (php-5.3, php-5.4, php-5.5, php-5.6, php-7/phpng(Beta))
- Provide Nginx, Tengine
- Providing a plurality of Apache version (Apache-2.4, Apache-2.2)
- According to their needs to install PHP Cache Accelerator provides ZendOPcache, xcache, apcu, eAccelerator. And php encryption and decryption tool ionCube, ZendGuardLoader
- Installation Pureftpd, phpMyAdmin according to their needs
- Install memcached, redis according to their needs
- Tcmalloc can use according to their needs or jemalloc optimize MySQL, Nginx
- Providing add a virtual host script
- Provide Nginx/Tengine, MySQL/MariaDB/Percona, PHP, Redis, phpMyAdmin upgrade script
- Provide local backup and remote backup (rsync between servers) script
- Provided under HHVM install CentOS 6,7

## How to use
If your server system: CentOS/Redhat (Do not enter "//" and "// subsequent sentence)
```bash
yum -y install wget screen   // For CentOS / Redhat
wget http://mirrors.svipc.com/LNMP-Autoscripts.tar.gz   // Contains the source code
tar xzf lnmp-full.tar.gz
cd lnmp    // If you need to modify the directory (installation, data storage, Nginx logs), modify options.conf file
screen -S lnmp    // if network interruption, you can execute the command `screen -r lnmp` reconnect install window
./install.sh   // Do not sh install.sh or bash install.sh such execution
```
If your server system: Debian/Ubuntu (Do not enter "//" and "// subsequent sentence)
```bash
apt-get -y install wget screen    // For Debian / Ubuntu
wget http://mirrors.svipc.com/LNMP-Autoscripts.tar.gz   // Contains the source code
tar xzf lnmp-full.tar.gz
cd lnmp    // If you need to modify the directory (installation, data storage, Nginx logs), modify options.conf file
screen -S lnmp    // if network interruption, you can execute the command `screen -r lnmp` reconnect install window
./install.sh   // Do not sh install.sh or bash install.sh such execution
```

## How to add a virtual host

```bash
cd ~/lnmp    // Must enter the directory execution under lnmp
./vhost.sh    // Do not sh vhost.sh or bash vhost.sh such execution
```

## How to delete a virtual host

```bash
cd ~/lnmp
./vhost.sh del
```

## How to add FTP virtual user 

```bash
cd ~/lnmp
./pureftpd_vhost.sh
```

## How to backup

```bash
cd ~/lnmp
./backup_setup.sh    // Backup parameters 
./backup.sh    // Perform the backup immediately 
crontab -l    // Can be added to scheduled tasks, such as automatic backups every day 1:00 
  0 1 * * * cd ~/lnmp;./backup.sh  > /dev/null 2>&1 &
```

## How to manage service
Nginx/Tengine:
```bash
service nginx {start|stop|status|restart|reload|configtest}
```
MySQL/MariaDB/Percona:
```bash
service mysqld {start|stop|restart|reload|status}
```
PHP:
```bash
service php-fpm {start|stop|restart|reload|status}
```
HHVM:
```bash
service supervisord {start|stop|status|restart|reload}
```
Apache:
```bash
service httpd {start|restart|stop}
```
Pure-Ftpd:
```bash
service pureftpd {start|stop|restart|status}
```
Redis:
```bash
service redis-server {start|stop|status|restart|reload}
```
Memcached:
```bash
service memcached {start|stop|status|restart|reload}
```

## How to upgrade 
```bash
./upgrade.sh
```

## How to uninstall 

```bash
./uninstall.sh
```

## Installation
Follow the instructions in [Wiki Installation page](http://www.svipc.com)<br />

For feedback, questions, and to follow the progress of the project (Chinese): <br />
[lnmp最新源码一键安装脚本](http://www.svipc.com)<br />