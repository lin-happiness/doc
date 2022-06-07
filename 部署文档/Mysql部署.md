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


#### centos7 安装 Mysql 5.7
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

1)、mysql优化待补充
       中文乱码
```shell
# 默认情况下
mysql> show variables like 'char%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8                       |
| character_set_connection | utf8                       |
| character_set_database   | latin1                     |
| character_set_filesystem | binary                     |
| character_set_results    | utf8                       |
| character_set_server     | latin1                     |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)

# 调整配置
# 添加
[mysql]
default-character-set=utf8

[mysqld]

# 添加
default-storage-engine=INNODB
character_set_server=utf8
# 查询结果
mysql> show variables like 'char%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8                       |
| character_set_connection | utf8                       |
| character_set_database   | utf8                       |
| character_set_filesystem | binary                     |
| character_set_results    | utf8                       |
| character_set_server     | utf8                       |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)
```
连接最大数
```shell
max_connections=1200
```

缓存参数设置

模式设置
```shell

mysql> select @@session.sql_mode;
+--------------------------------------------+
| @@session.sql_mode                         |
+--------------------------------------------+
| STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION |
+--------------------------------------------+
1 row in set (0.00 sec)

mysql> select @@global.sql_mode;
+--------------------------------------------+
| @@global.sql_mode                          |
+--------------------------------------------+
| STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION |
+--------------------------------------------+
1 row in set (0.00 sec)

# 修改配置文件
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION


# sql_mode常用值如下：
ONLY_FULL_GROUP_BY
对于GROUP BY聚合操作，如果在SELECT中的列，没有在GROUP BY中出现，那么这个SQL是不合法的，因为列不在GROUP BY从句中

NO_AUTO_VALUE_ON_ZERO
该值影响自增长列的插入。默认设置下，插入0或NULL代表生成下一个自增长值。如果用户 希望插入的值为0，而该列又是自增长的，那么这个选项就有用了。

STRICT_TRANS_TABLES
在该模式下，如果一个值不能插入到一个事务表中，则中断当前的操作，对非事务表不做限制

NO_ZERO_IN_DATE
在严格模式下，不允许日期或月份为零，只要日期的月或日中含有0值都报错，但是‘0000-00-00’除外

NO_ZERO_DATE
设置该值，mysql数据库不允许插入零日期，插入零日期会抛出错误而不是警告。年月日中任何一个不为0都符合要求，只有‘0000-00-00’会报错

ERROR_FOR_pISION_BY_ZERO
在INSERT或UPDATE过程中，如果数据被零除，则产生错误而非警告。如 果未给出该模式，那么数据被零除时MySQL返回NULL
update table set num = 5 / 0 ; 设置该模式后会报错，不设置则修改成功，num的值为null

NO_AUTO_CREATE_USER
禁止GRANT创建密码为空的用户

NO_ENGINE_SUBSTITUTION
如果需要的存储引擎被禁用或未编译，那么抛出错误。不设置此值时，用默认的存储引擎替代，并抛出一个异常

PIPES_AS_CONCAT
将"||"视为字符串的连接操作符而非或运算符，这和Oracle数据库是一样的，也和字符串的拼接函数Concat相类似

ANSI_QUOTES
启用ANSI_QUOTES后，不能用双引号来引用字符串，因为它被解释为识别符

```


高并发问题处理
       文件数
       打开线程限制
       主从

高可用问题处理





2)、mysql docker部署待补充

##### 1.1、创建需要的文件夹

```shell
#主服务
mkdir /data/mysql/master/logs -p
mkdir /data/mysql/master/data -p
mkdir /data/mysql/master/conf -p

#从服务
mkdir /data/mysql/slave1/logs -p
mkdir /data/mysql/slave1/data -p
mkdir /data/mysql/slave1/conf -p

```

##### 1.2、主MySQL配置

宿主机如果没有timezone，则进行如下配置：

```shell
echo "Asia/shanghai" > /etc/timezone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

然后编辑MySQL配置文件：

```shell
# 编辑主数据库配置

vi /data/mysql/master/conf/my.cnf

# 文件内容

[mysqld]
# id为数字
server-id=3306
# 开启复制功能
log-bin=mysql-bin
# 数据库自动增长步长为2(主从总共有多少台就为多少，为了避免id冲突)
auto_increment_increment=2
# 数据库自动增长参照值，master基本上是1，slaver依次递增
auto_increment_offset=1
lower_case_table_names=1

# 设置数据库最大连接数
max_connections = 1000
# 跳过hostname监测 解决连接数据库慢的问题
skip-name-resolve
# add 20211112，解决1、时间问题、2、中文问题？？？
# 默认文字编码方案
character-set-server=utf8mb4
# 东八区
default-time-zone='+08:00'

[mysql]
default-character-set=utf8mb4

[client]
default-character-set=utf8mb4

```

##### 1.3、从MySQL配置

```shell
# 编辑主数据库配置
vi /data/mysql/slave1/conf/my.cnf

[mysqld]
# id为数字
server-id=3307
# 开启复制功能
log-bin=mysql-bin
# 数据库自动增长步长为2(主从总共有多少台就为多少，为了避免id冲突)
auto_increment_increment=2
# 数据库自动增长参照值，master基本上是1，slaver依次递增
auto_increment_offset=2
lower_case_table_names=1

# 设置数据库最大连接数
max_connections = 1000
# 跳过hostname监测 解决连接数据库慢的问题
skip-name-resolve
# add 20211112，解决1、时间问题、2、中文问题？？？
# 默认文字编码方案
character-set-server=utf8mb4
# 东八区
default-time-zone='+08:00'

[mysql]
default-character-set=utf8mb4

[client]
default-character-set=utf8mb4


```

##### 1.4、docker启动主数据库

```shell
# docker 直接运行
docker run -d -p 3306:3306 --name mysql-master \
--restart=always \
-v /data/mysql/master/conf:/etc/mysql \
-v /data/mysql/master/logs:/var/log/mysql \
-v /data/mysql/master/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=root1234% \
-d mysql:5.7
```

##### 1.5、在master中添加权限

###### 1.5.1、添加负责复制的数据库账户
```shell
# 进入主数据库docker实例
docker exec -it mysql-master /bin/bash
# 登录mysql
mysql -u root -p
```

在mysql命令行中执行

```mysql
-- 新建一个 repluser 的用户用来做复制并赋予权限
GRANT REPLICATION SLAVE,FILE,REPLICATION CLIENT ON *.* TO 'repluser'@'%' IDENTIFIED BY 'abc.123';
-- 刷新权限列表
FLUSH PRIVILEGES;
```

###### 1.5.2、查看主数据库状态，记下 File 和 Position

```mysql
-- 查看主库状态
SHOW MASTER STATUS;
```
参考：

| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---------------- | -------- | ------------ | ---------------- | ----------------- |
| mysql-bin.000003 | 621      |              |                  |                   |

##### 1.6、docker启动从数据库

```shell
# docker 直接运行
docker run -d -p 3307:3306 --name mysql-slave1 \
--restart=always \
-v /data/mysql/slave1/conf:/etc/mysql \
-v /data/mysql/slave1/logs:/var/log/mysql \
-v /data/mysql/slave1/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=root1234% \
-d mysql:5.7
```

##### 1.7、在slaver中添加master的信息

###### 1.7.1、在slaver中添加master的信息

```shell
# 进入主数据库docker实例
docker exec -it mysql-slave1 /bin/bash
# 登录mysql
mysql -u root -p

```

```mysql
-- 配置 master 的地址和端口
-- 配置 master 的账号和密码
-- 配置 master 上同步的 log_file 和起始同步位置
change master to master_host='10.36.0.112',master_port=3306,master_user='repluser',master_password='abc.123',master_log_file='mysql-bin.000003'
,master_log_pos=621;
```

###### 1.7.2、开启 slaver

```mysql
-- 启动从库的 SQL 和 IO 线程
start slave;
```

###### 1.7.3、查看 slaver 的状态

```mysql
show slave status;
-- 主要查看两个参数是否正常
Slave_IO_Running: Yes
Slave_SQL_running: Yes
```

###### 1.7.4、清除 slave 中的错误信息（主从同步出现问题之后才需要做这些，平时不需要。且必须要在从库进行操作）

```sql
-- 停止从库的同步状态
stop slave;
-- 设置全局忽略错误数量，有可能不是1
set global sql_slave_skip_counter=1;
-- 重新启动从库
start slave;
-- 查看从库状态，恢复正常就可以了
show slave status;
```

##### 1.8、开启防火墙端口
```shell
# 添加端口3306/tcp 3307/tcp
firewall-cmd --add-port=3306/tcp --zone=public --permanent
firewall-cmd --add-port=3307/tcp --zone=public --permanent
# 重载防火墙配置
firewall-cmd --reload
# 查看防火墙控制的端口列表
firewall-cmd --list-port
```









```txt

Mysql 的配置详解
1. back_log

指定MySQL可能的连接数量。当MySQL主线程在很短的时间内得到非常多的连接请求，该参数就起作用，之后主线程花些时间（尽管很短）检查连接并且启动一个新线程。

back_log参数的值指出在MySQL暂时停止响应新请求之前的短时间内多少个请求可以被存在堆栈中。如果系统在一个短时间内有很多连接，则需要增大该参数的值，该参数值指定到来的TCP/IP连接的侦听队列的大小。不同的操作系统在这个队列大小上有它自己的限制。 试图设定back_log高于你的操作系统的限制将是无效的。

当观察MySQL进程列表，发现大量 264084 | unauthenticated user | xxx.xxx.xxx.xxx | NULL | Connect | NULL | login | NULL 的待连接进程时，就要加大 back_log 的值。back_log默认值为50。

2. basedir

MySQL主程序所在路径，即：--basedir参数的值。

3. bdb_cache_size

分配给BDB类型数据表的缓存索引和行排列的缓冲区大小，如果不使用DBD类型数据表，则应该在启动MySQL时加载 --skip-bdb 参数以避免内存浪费。

4.bdb_log_buffer_size

分配给BDB类型数据表的缓存索引和行排列的缓冲区大小，如果不使用DBD类型数据表，则应该将该参数值设置为0，或者在启动MySQL时加载 --skip-bdb 参数以避免内存浪费。

5.bdb_home

参见 --bdb-home 选项。

6. bdb_max_lock

指定最大的锁表进程数量（默认为10000），如果使用BDB类型数据表，则可以使用该参数。如果在执行大型事物处理或者查询时发现 bdb: Lock table is out of available locks or Got error 12 from ... 错误，则应该加大该参数值。

7. bdb_logdir

指定使用BDB类型数据表提供服务时的日志存放位置。即为 --bdb-logdir 的值。

8. bdb_shared_data

如果使用 --bdb-shared-data 选项则该参数值为On。

9. bdb_tmpdir

BDB类型数据表的临时文件目录。即为 --bdb-tmpdir 的值。

10. binlog_cache_size

为binary log指定在查询请求处理过程中SQL 查询语句使用的缓存大小。如果频繁应用于大量、复杂的SQL表达式处理，则应该加大该参数值以获得性能提升。

11. bulk_insert_buffer_size

指定 MyISAM 类型数据表表使用特殊的树形结构的缓存。使用整块方式(bulk)能够加快插入操作( INSERT ... SELECT, INSERT ... VALUES (...), (...), ..., 和 LOAD DATA INFILE) 的速度和效率。该参数限制每个线程使用的树形结构缓存大小，如果设置为0则禁用该加速缓存功能。注意：该参数对应的缓存操作只能用户向非空数据表中执行插入操作！默认值为 8MB。

12. character_set

MySQL的默认字符集。

13. character_sets

MySQL所能提供支持的字符集。

14. concurrent_inserts

如果开启该参数，MySQL则允许在执行 SELECT 操作的同时进行 INSERT 操作。如果要关闭该参数，可以在启动 mysqld 时加载 --safe 选项，或者使用 --skip-new 选项。默认为On。

15. connect_timeout

指定MySQL服务等待应答一个连接报文的最大秒数，超出该时间，MySQL向客户端返回 bad handshake。

16. datadir

指定数据库路径。即为 --datadir 选项的值。

17. delay_key_write

该参数只对 MyISAM 类型数据表有效。有如下的取值种类：

off: 如果在建表语句中使用 CREATE TABLE ... DELAYED_KEY_WRITES，则全部忽略

DELAYED_KEY_WRITES；

on: 如果在建表语句中使用 CREATE TABLE ... DELAYED_KEY_WRITES，则使用该选项（默认）；

all: 所有打开的数据表都将按照 DELAYED_KEY_WRITES 处理。

如果 DELAYED_KEY_WRITES 开启，对于已经打开的数据表而言，在每次索引更新时都不刷新带有

DELAYED_KEY_WRITES 选项的数据表的key buffer，除非该数据表关闭。该参数会大幅提升写入键值的速

度。如果使用该参数，则应该检查所有数据表：myisamchk --fast --force。

18.delayed_insert_limit

在插入delayed_insert_limit行后，INSERT DELAYED处理模块将检查是否有未执行的SELECT语句。如果有，在继续处理前执行允许这些语句。

19. delayed_insert_timeout

一个INSERT DELAYED线程应该在终止之前等待INSERT语句的时间。

20. delayed_queue_size

为处理INSERT DELAYED分配的队列大小（以行为单位）。如果排队满了，任何进行INSERT DELAYED的客户必须等待队列空间释放后才能继续。

21. flush

在启动MySQL时加载 --flush 参数打开该功能。

22. flush_time

如果该设置为非0值，那么每flush_time秒，所有打开的表将被关，以释放资源和sync到磁盘。注意：只建议在使用 Windows9x/Me 或者当前操作系统资源严重不足时才使用该参数！

23. ft_boolean_syntax

搜索引擎维护员希望更改允许用于逻辑全文搜索的操作符。这些则由变量 ft_boolean_syntax 控制。

24. ft_min_word_len

指定被索引的关键词的最小长度。注意：在更改该参数值后，索引必须重建！

25. ft_max_word_len

指定被索引的关键词的最大长度。注意：在更改该参数值后，索引必须重建！

26. ft_max_word_len_for_sort

指定在使用REPAIR, CREATE INDEX, or ALTER TABLE等方法进行快速全文索引重建过程中所能使用的关键词的最大长度。超出该长度限制的关键词将使用低速方式进行插入。加大该参数的值，MySQL将会建立更大的临时文件（这会减轻CPU负载，但效率将取决于磁盘I/O效率），并且在一个排序取内存放更少的键值。

27. ft_stopword_file

从 ft_stopword_file 变量指定的文件中读取列表。在修改了 stopword 列表后，必须重建 FULLTEXT 索引。

28. have_innodb

YES: MySQL支持InnoDB类型数据表； DISABLE: 使用 --skip-innodb 关闭对InnoDB类型数据表的支持。

29. have_bdb

YES: MySQL支持伯克利类型数据表； DISABLE: 使用 --skip-bdb 关闭对伯克利类型数据表的支持。

30. have_raid

YES: 使MySQL支持RAID功能。

31. have_openssl

YES: 使MySQL支持SSL加密协议。

32. init_file

指定一个包含SQL查询语句的文件，该文件在MySQL启动时将被加载，文件中的SQL语句也会被执行。

33. interactive_timeout

服务器在关上它前在一个交互连接上等待行动的秒数。一个交互的客户被定义为对mysql_real_connect()使用CLIENT_INTERACTIVE选项的客户。也可见wait_timeout。

34. join_buffer_size

用于全部联合(join)的缓冲区大小(不是用索引的联结)。缓冲区对2个表间的每个全部联结分配一次缓冲区，当增加索引不可能时，增加该值可得到一个更快的全部联结。（通常得到快速联结的最佳方法是增加索引。）

35. key_buffer_size

用于索引块的缓冲区大小，增加它可得到更好处理的索引(对所有读和多重写)，到你能负担得起那样多。如果你使它太大，系统将开始变慢慢。必须为OS文件系统缓存留下一些空间。为了在写入多个行时得到更多的速度。

36. language

用户输出报错信息的语言。

37. large_file_support

开启大文件支持。

38. locked_in_memory

使用 --memlock 将mysqld锁定在内存中。

39. log

记录所有查询操作。

40. log_update

开启update log。

41. log_bin

开启 binary log。

42. log_slave_updates

如果使用链状同步或者多台Slave之间进行同步则需要开启此参数。

43. long_query_time

如果一个查询所用时间超过该参数值，则该查询操作将被记录在Slow_queries中。

44. lower_case_table_names

1: MySQL总使用小写字母进行SQL操作；

0: 关闭该功能。

注意：如果使用该参数，则应该在启用前将所有数据表转换为小写字母。

45. max_allowed_packet

一个查询语句包的最大尺寸。消息缓冲区被初始化为net_buffer_length字节，但是可在需要时增加到max_allowed_packet个字节。该值太小则会在处理大包时产生错误。如果使用大的BLOB列，必须增加该值。

46. net_buffer_length

通信缓冲区在查询期间被重置到该大小。通常不要改变该参数值，但是如果内存不足，可以将它设置为查询期望的大小。（即，客户发出的SQL语句期望的长度。如果语句超过这个长度，缓冲区自动地被扩大，直到max_allowed_packet个字节。）

47. max_binlog_cache_size

指定binary log缓存的最大容量，如果设置的过小，则在执行复杂查询语句时MySQL会出错。

48. max_binlog_size

指定binary log文件的最大容量，默认为1GB。

49. max_connections

允许同时连接MySQL服务器的客户数量。如果超出该值，MySQL会返回Too many connections错误，但通常情况下，MySQL能够自行解决。

50. max_connect_errors

对于同一主机，如果有超出该参数值个数的中断错误连接，则该主机将被禁止连接。如需对该主机进行解禁，执行：FLUSH HOST;。

51. max_delayed_threads

不要启动多于的这个数字的线程来处理INSERT DELAYED语句。如果你试图在所有INSERT DELAYED线程在用后向一张新表插入数据，行将被插入，就像DELAYED属性没被指定那样。

52. max_heap_table_size

内存表所能使用的最大容量。

53. max_join_size

如果要查询多于max_join_size个记录的联合将返回一个错误。如果要执行没有一个WHERE的语句并且耗费大量时间，且返回上百万行的联结，则需要加大该参数值。

54. max_sort_length

在排序BLOB或TEXT值时使用的字节数(每个值仅头max_sort_length个字节被使用；其余的被忽略)。

55. max_user_connections

指定来自同一用户的最多连接数。设置为0则代表不限制。

56. max_tmp_tables

（该参数目前还没有作用）。一个客户能同时保持打开的临时表的最大数量。

57. max_write_lock_count

当出现max_write_lock_count个写入锁定数量后，开始允许一些被锁定的读操作开始执行。避免写入锁定过多，读取操作处于长时间等待状态。

58. myisam_recover_options

 

mysql SHOW STATUS 详解

SHOW STATUS提供服务器的状态信息(象mysqladmin extended-status一样)。输出类似于下面的显示，尽管格式和数字可以有点不同：
下列含义：

Aborted_clients 由于客户没有正确关闭连接已经死掉，已经放弃的连接数量。
Aborted_connects 尝试已经失败的MySQL服务器的连接的次数。
Connections 试图连接MySQL服务器的次数。
Created_tmp_tables 当执行语句时，已经被创造了的隐含临时表的数量。
Delayed_insert_threads 正在使用的延迟插入处理器线程的数量。
Delayed_writes 用INSERT DELAYED写入的行数。
Delayed_errors 用INSERT DELAYED写入的发生某些错误(可能重复键值)的行数。
Flush_commands 执行FLUSH命令的次数。
Handler_delete 请求从一张表中删除行的次数。
Handler_read_first 请求读入表中第一行的次数。
Handler_read_key 请求数字基于键读行。
Handler_read_next 请求读入基于一个键的一行的次数。
Handler_read_rnd 请求读入基于一个固定位置的一行的次数。
Handler_update 请求更新表中一行的次数。
Handler_write 请求向表中插入一行的次数。
Key_blocks_used 用于关键字缓存的块的数量。
Key_read_requests 请求从缓存读入一个键值的次数。
Key_reads 从磁盘物理读入一个键值的次数。
Key_write_requests 请求将一个关键字块写入缓存次数。
Key_writes 将一个键值块物理写入磁盘的次数。
Max_used_connections 同时使用的连接的最大数目。
Not_flushed_key_blocks 在键缓存中已经改变但是还没被清空到磁盘上的键块。
Not_flushed_delayed_rows 在INSERT DELAY队列中等待写入的行的数量。
Open_tables 打开表的数量。
Open_files 打开文件的数量。
Open_streams 打开流的数量(主要用于日志记载）
Opened_tables 已经打开的表的数量。
Questions 发往服务器的查询的数量。
Slow_queries 要花超过long_query_time时间的查询数量。
Threads_connected 当前打开的连接的数量。
Threads_running 不在睡眠的线程数量。
Uptime 服务器工作了多少秒。

关于上面的一些注释：

如果Opened_tables太大，那么你的table_cache变量可能太小。
如果key_reads太大，那么你的key_cache可能太小。缓存命中率可以用key_reads/key_read_requests计算。
如果Handler_read_rnd太大，那么你很可能有大量的查询需要MySQL扫描整个表或你有没正确使用键值的联结(join)。
SHOW VARIABLES显示出一些MySQL系统变量的值，你也能使用mysqladmin variables命令得到这个信息。如果缺省值不合适，你能在mysqld启动时使用命令行选项来设置这些变量的大多数。

SHOW PROCESSLIST显示哪个线程正在运行，你也能使用mysqladmin processlist命令得到这个信息。如果你有process权限，你能看见所有的线程，否则，你仅能看见你自己的线程。见7.20 KILL句法。如果你不使用FULL选项，那么每个查询只有头100字符被显示出来。


SHOW GRANTS FOR user列出对一个用户必须发出以重复授权的授权命令

```


```txt
mysql -u root -p 回车输入密码进入mysql

show processlist;

查看连接数，可以发现有很多连接处于sleep状态，这些其实是暂时没有用的，所以可以kill掉

show variables like "max_connections";

查看最大连接数，应该是与上面查询到的连接数相同，才会出现too many connections的情况

set GLOBAL max_connections=1000;

修改最大连接数，但是这不是一劳永逸的方法，应该要让它自动杀死那些sleep的进程。

show global variables like 'wait_timeout';

这个数值指的是mysql在关闭一个非交互的连接之前要等待的秒数，默认是28800s

set global wait_timeout=300;

修改这个数值，这里可以随意，最好控制在几分钟内

set global interactive_timeout=500;

修改这个数值，表示mysql在关闭一个连接之前要等待的秒数，至此可以让mysql自动关闭那些没用的连接，但要注意的是，正在使用的连接到了时间也会被关闭，因此这个时间值要合适



SHOW VARIABLES LIKE '%table_open_cache%';

查看

show global status like 'Open%tables';

作者：天咋哭了
链接：https://www.jianshu.com/p/5101a9359b64
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

```