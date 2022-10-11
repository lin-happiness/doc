## centos7安装Mysql
### Mysql5.7安装

#### centos7 安装 Mysql 5.7
##### 1. 下载 MySQL yum包
```shell
wget http://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
```
##### 2.安装MySQL源
```shell
rpm -Uvh mysql57-community-release-el7-11.noarch.rpm
```
##### 3.安装MySQL服务
```shell
# MySQL5.7的GPG升级了，需要更新证书（系统默认证书存放在/etc/pki/rpm-gpg目录下）
# 使用Mysql官方等证书
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# 查看证书
rpm -qa|grep gpg-pubkey
# 结果
gpg-pubkey-5072e1f5-5301d466
gpg-pubkey-352c64e5-52ae6884
gpg-pubkey-3a79bd29-61b8bab7
gpg-pubkey-f4a80eb5-53a7ff4b

# 查看证书详情
rpm -qi gpg-pubkey-5072e1f5-5301d466
# 结果
ame        : gpg-pubkey
Version     : 5072e1f5
Release     : 5301d466
Architecture: (none)
Install Date: Tue 31 May 2022 11:10:57 AM CST
Group       : Public Keys
Size        : 0
License     : pubkey
Signature   : (none)
Source RPM  : (none)
Build Date  : Mon 17 Feb 2014 05:20:38 PM CST
Build Host  : localhost
Relocations : (not relocatable)
Packager    : MySQL Package signing key (www.mysql.com) <build@mysql.com>
Summary     : gpg(MySQL Package signing key (www.mysql.com) <build@mysql.com>)

# 安装mysql
yum install -y mysql-community-server
```
##### 4.启动MySQL
```shell
systemctl start mysqld
```
##### 5.检查是否启动成功
```shell
systemctl status mysqld
```
##### 6.获取临时密码，MySQL5.7为root用户随机生成了一个密码
```shell
grep 'temporary password' /var/log/mysqld.log 

2022-05-31T02:39:15.234467Z 1 [Note] A temporary password is generated for root@localhost: (IF1K27eHu=k
```

##### 7.通过临时密码登录MySQL，进行修改密码操作
```shell
mysql -uroot -p
# 使用临时密码登录后，不能进行其他的操作，否则会报错，这时候我们进行修改密码操作
```
##### 8.因为MySQL的密码规则需要很复杂，如果需要调整密码规则不严格，需要通过命令修改
```shell
set global validate_password_policy=0;
set global validate_password_length=1;
# 修改密码复杂度不够的情况下提示信息
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements

# 修改密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'yourpassword';

#查看账户信息
use mysql;
select user , host,authentication_string,password_last_changed from user;

+---------------+-----------+-------------------------------------------+-----------------------+
| user          | host      | authentication_string                     | password_last_changed |
+---------------+-----------+-------------------------------------------+-----------------------+
| root          | localhost | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 | 2022-05-31 10:41:17   |
| mysql.session | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | 2022-05-31 10:39:16   |
| mysql.sys     | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | 2022-05-31 10:39:16   |
+---------------+-----------+-------------------------------------------+-----------------------+
```



##### 9.授权其他机器远程登录
```shell
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'yourpassword' WITH GRANT OPTION;
FLUSH PRIVILEGES;

# 查看修改情况
select user , host,authentication_string,password_last_changed from user;

+---------------+-----------+-------------------------------------------+-----------------------+
| user          | host      | authentication_string                     | password_last_changed |
+---------------+-----------+-------------------------------------------+-----------------------+
| root          | localhost | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 | 2022-05-31 10:41:17   |
| mysql.session | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | 2022-05-31 10:39:16   |
| mysql.sys     | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | 2022-05-31 10:39:16   |
| root          | %         | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 | 2022-05-31 10:44:02   |
+---------------+-----------+-------------------------------------------+-----------------------+
```

##### 10.开启开机自启动
```shell
# 先退出mysql命令行，然后输入以下命令（默认应该有开机自启动，如果有一场重新设置）
systemctl enable mysqld
systemctl daemon-reload
```

##### 11.设置MySQL的字符集为UTF-8，令其支持中文

```shell
vi /etc/my.cnf
```
添加配置
```shell
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

# 添加
[mysql]
default-character-set=utf8


[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# 添加
default-storage-engine=INNODB
character_set_server=utf8


# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```
##### 12.重启一下MySQL,令配置生效
```shell
systemctl restart mysqld
```
##### 13.防火墙开放3306端口
```shell
firewall-cmd --state
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
```

##### 14.卸载MySQL仓库
一开始的时候我们安装的yum，每次yum操作都会更新一次，耗费时间，我们把他卸载掉
```shell
rpm -qa | grep mysql
yum -y remove mysql57-community-release-el7-11.noarch
```



### Mysql5.6安装


#### centos7 安装 Mysql 5.6
##### 1. 下载 MySQL yum包
```shell
wget http://repo.mysql.com/mysql-community-release-el7-7.noarch.rpm
```
##### 2.安装MySQL源
```shell
rpm -ivh mysql-community-release-el7-7.noarch.rpm
```
##### 3.安装MySQL服务

```shell
# 安装mysql
yum install -y mysql-community-server
```


##### 4.启动MySQL
```shell
systemctl start mysqld
```
##### 5.检查是否启动成功及报错处理
```shell
# 查看服务状态
systemctl status mysqld

# 查看启动日志
tail -f -n 1000 /var/log/mysqld.log 
# 报错信息
2022-05-31 11:11:48 10082 [Note] RSA private key file not found: /var/lib/mysql//private_key.pem. Some authentication plugins will not work.
2022-05-31 11:11:48 10082 [Note] RSA public key file not found: /var/lib/mysql//public_key.pem. Some authentication plugins will not work.

# 解决方法如下：
# 1.检查是否安装openssl
rpm -qa openssl
# 2.利用openssl生成公有和私有key
cd /var/lib/mysql
openssl genrsa -out mykey.pem 1024
openssl rsa -in mykey.pem -pubout -out mykey.pub
# 3.修改key的权限
chmod 400 mykey.pem
chmod 444 mykey.pub
chown mysql:mysql mykey.pem
chown mysql:mysql mykey.pub
¥# 4.把公私有key的路径加入到my.cnf中
sha256_password_private_key_path=mykey.pem
sha256_password_public_key_path=mykey.pub
# 如果key放在datadir目录下，直接写key名即可。否则要指定key的全路径
#5.重启mysql
SHOW STATUS查看Rsa_public_key状态，如果不为空，则OK.
mysql> SHOW STATUS LIKE 'Rsa_public_key'\G
*************************** 1. row ***************************
Variable_name: Rsa_public_key
       Value: -----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDEALeNX9dY4EMlaDHCIYPBvFNN
NJG2f6dtsyV/IG94TFsKtx/Xobiiz9ihBZSWvUhlfz6aVy9TbN68YEn58G5oOS3o
sxKZQvDF9XvjN0thDPwCgfIwTZgatqmrV/qGewCxQpQ03WHPx+GXQmM9iFSfM84F
pZ8QtiI3m+fIUaOd/QIDAQAB
-----END PUBLIC KEY-----

1 row in set (0.00 sec)

```


##### 6.登陆系统，临时密码为空（输入密码直接回车）
```shell
mysql -u root -p
```

##### 7.进入mysql数据库，进行修改密码操作
```shell
use mysql;
update user set password=password("abc.123") where user="root";
flush privileges;
# 查看结果
select user,host,password from user;

+------+---------------+-------------------------------------------+
| user | host          | password                                  |
+------+---------------+-------------------------------------------+
| root | localhost     | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
| root | vm-0-6-centos | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
| root | 127.0.0.1     | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
| root | ::1           | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
|      | localhost     |                                           |
|      | vm-0-6-centos |                                           |
+------+---------------+-------------------------------------------+

```
##### 8.授权其他机器远程登录
```shell
# 为root账号添加远程访问数据库权限（根据实际情况设置）
use mysql;
GRANT ALL PRIVILEGES ON *.* TO root@"%" IDENTIFIED BY "root";
flush privileges;
# 查看结果
select user,host,password from user;
+------+---------------+-------------------------------------------+
| user | host          | password                                  |
+------+---------------+-------------------------------------------+
| root | localhost     | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
| root | vm-0-6-centos | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
| root | 127.0.0.1     | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
| root | ::1           | *8851FAFDF275020B3029B4D1E714B4DCDD4ED868 |
|      | localhost     |                                           |
|      | vm-0-6-centos |                                           |
| root | %             | *81F5E21E35407D884A6CD4A731AEBFB6AF209E1B |
+------+---------------+-------------------------------------------+

```

##### 10.开启开机自启动
```shell
# 先退出mysql命令行，然后输入以下命令（默认应该有开机自启动，如果有一场重新设置）
systemctl enable mysqld
systemctl daemon-reload
```
##### 11.设置MySQL的字符集为UTF-8，令其支持中文

```shell
vi /etc/my.cnf
```
添加配置
```shell
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.6/en/server-configuration-defaults.html

# 添加
[mysql]
default-character-set=utf8

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

# 添加
default-storage-engine=INNODB
character_set_server=utf8

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 


sha256_password_private_key_path=mykey.pem
sha256_password_public_key_path=mykey.pub


[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```
##### 12.重启一下MySQL,令配置生效
```shell
systemctl restart mysqld
```
##### 13.防火墙开放3306端口
```shell
firewall-cmd --state
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
```

##### 14.卸载MySQL仓库
安装的yum，每次yum操作都会更新一次，耗费时间，需要卸载掉
```shell
rpm -qa | grep mysql
yum -y remove mysql-community-release-el7-7.noarch
```

### 参考
https://www.lxlinux.net/7787.html

http://c.biancheng.net/view/820.html

https://www.cnblogs.com/jinghuyue/p/11565564.html

### 备注
#### 1、安装包说明
```txt
mysql-community-libs-compat-8.0.15-1.el6.x86_64.rpm	MySQL之前版本的共享兼容库
mysql-community-test-8.0.15-1.el6.x86_64.rpm	MySQL服务端的测试组件
mysql-community-devel-8.0.15-1.el6.x86_64.rpm	MySQL数据库客户端应用程序的开发头文件和库
mysql-community-common-8.0.15-1.el6.x86_64.rpm	服务端和客户端的公共文件
mysql-community-libs-8.0.15-1.el6.x86_64.rpm	客户端共享库
mysql-community-client-8.0.15-1.el6.x86_64.rpm	客户端及相关工具
mysql-community-server-8.0.15-1.el6.x86_64.rpm	服务端及相关工具
```

#### 2、待补充
```txt
1)、mysql优化待补充
2)、mysql docker部署待补充
```
