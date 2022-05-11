## CentOS7安装Mysql5.7
### 一、yum方式安装Mysql 5.7.27

#### 下载 MySQL的yum包
    wget http://repo.mysql.com/mysql57-community-release-el7-10.noarch.rpm
#### 安装MySQL源
    rpm -Uvh mysql57-community-release-el7-10.noarch.rpm
#### 安装MySQL服务端,需要等待一些时间
    yum install -y mysql-community-server
#### 启动MySQL
    systemctl start mysqld
#### 检查是否启动成功
    systemctl status mysqld
#### 获取临时密码，MySQL5.7为root用户随机生成了一个密码
    grep 'temporary password' /var/log/mysqld.log 
#### 通过临时密码登录MySQL，进行修改密码操作
    mysql -u root -p
使用临时密码登录后，不能进行其他的操作，否则会报错，这时候我们进行修改密码操作
 
#### 因为MySQL的密码规则需要很复杂，我们一般自己设置的不会设置成这样，所以我们全局修改一下
    mysql> set global validate_password_policy=0;
    mysql> set global validate_password_length=1;
这时候我们就可以自己设置想要的密码了
 
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'yourpassword';
 

#### 授权其他机器远程登录

    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'yourpassword' WITH GRANT OPTION;
     
    FLUSH PRIVILEGES;
 

#### 开启开机自启动
先退出mysql命令行，然后输入以下命令

    systemctl enable mysqld
    
    systemctl daemon-reload
 

#### 设置MySQL的字符集为UTF-8，令其支持中文
    vi /etc/my.cnf
改成如下,然后保存
 
    # For advice on how to change settings please see
    # http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
    
    [mysqld]
    character_set_server=utf8
    init_connect='SET NAMES utf8'
    #计划任务
    event_scheduler = ON
    
    # 设置模式
    sql_mode =STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
    
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
    
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid
    
    #添加validate_password_policy配置
    validate_password_policy=2
    #关闭密码策略
    validate_password = off

     
#### 重启一下MySQL,令配置生效
    systemctl restart mysqld
 
#### 防火墙开放3306端口
    firewall-cmd --state
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
    firewall-cmd --reload
 

#### 卸载MySQL仓库
一开始的时候我们安装的yum，每次yum操作都会更新一次，耗费时间，我们把他卸载掉

    rpm -qa | grep mysql

    yum -y remove mysql57-community-release-el7-10.noarch
 

### 二、docker方式安装Mysql 5.7



#### 主MySQL配置


    # 编辑主数据库配置，比如 vi /data/mysql/student/master/conf/my.cnf
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


#### 从MySQL配置


    # 编辑主数据库配置，比如 vi /data/mysql/student/slaver1/conf/my.cnf
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

#### docker启动数据库


    # docker 直接运行
    docker run -d -p 3306:3306 --name student-master \
    --restart=always \
    -v /data/mysql/student/master/conf:/etc/mysql \
    -v /data/mysql/student/master/logs:/var/log/mysql \
    -v /data/mysql/student/master/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=root1234% \
    -d mysql:5.7
    
#### 在master中添加权限

##### 添加负责复制的数据库账户

    GRANT REPLICATION SLAVE,FILE,REPLICATION CLIENT ON *.* TO 'repluser'@'%' IDENTIFIED BY '123456';
    -- 刷新权限列表
    FLUSH PRIVILEGES;

##### 查看主数据库状态，记下 File 和 Position

    -- 查看主库状态
    SHOW MASTER STATUS;

| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---------------- | -------- | ------------ | ---------------- | ----------------- |
| mysql-bin.000003 | 621      |              |                  |                   |

#### 在slaver中添加master的信息

##### 在slaver中添加master的信息

    # 配置 master 的地址和端口
    # 配置 master 的账号和密码
    # 配置 master 上同步的 log_file 和起始同步位置
    change master to master_host='10.30.211.104',master_port=3306,master_user='repluser',master_password='123456',master_log_file='mysql-bin.000003'
    ,master_log_pos=621;

##### 开启 slaver

    #启动从库的 SQL 和 IO 线程
    start slave;

##### 查看 slaver 的状态

    show slave status;
    # 主要查看两个参数是否正常
    Slave_IO_Running: Yes
    Slave_SQL_running: Yes

#### 测试

此时在master中新增任何数据库、数据表、数据记录都会直接同步到slaver



### N、安装validate_password密码校验插件
#### 查询插件
1、登录mysql，查询已安装的插件

    show plugins;

2、查询mysql插件目录位置

    show variables like "%plugin_dir%";

#### 安装插件：
##### 第一种方式（推荐）

    install plugin validate_password soname 'validate_password.so';

运行时注册插件。无需重启mysql

##### 第二种方式

my.cnf配置文件添加，之后需要重启mysql

    vi /etc/my.cnf
    
    #添加配置
    
    [mysqld]
    plugin-load=validate_password=validate_password.so


#### 配置插件
##### 第一种方式（推荐）

直接修改全局变量

    set global validate_password_policy=2

##### 第二种方式：

my.cnf配置文件之后重启mysql

    vi /etc/my.cnf
    
    #添加配置
    
    [mysqld]
    #添加validate_password_policy配置
    validate_password_policy=2



#### 查询配置
再次登录mysql执行

    SHOW VARIABLES LIKE 'validate_password%';
结果


    mysql> SHOW VARIABLES LIKE 'validate_password%';
    +--------------------------------------+--------+
    | Variable_name                        | Value  |
    +--------------------------------------+--------+
    | validate_password_check_user_name    | OFF    |
    | validate_password_dictionary_file    |        |
    | validate_password_length             | 8      |
    | validate_password_mixed_case_count   | 1      |
    | validate_password_number_count       | 1      |
    | validate_password_policy             | STRONG |
    | validate_password_special_char_count | 1      |
    +--------------------------------------+--------+
    7 rows in set (0.01 sec)


各配置说明：

- validate-password=ON/OFF/FORCE/FORCE_PLUS_PERMANENT: 决定是否使用该插件(及强制/永久强制使用)。
- validate_password_dictionary_file：插件用于验证密码强度的字典文件路径。
- validate_password_length：密码最小长度。
- validate_password_mixed_case_count：密码至少要包含的小写字母个数和大写字母个数。
- validate_password_number_count：密码至少要包含的数字个数。
- validate_password_policy：密码强度检查等级，0/LOW、1/MEDIUM、2/STRONG。
    - 其中，关于validate_password_policy-密码强度检查等级：
        - 0/LOW：只检查长度。
        - 1/MEDIUM：检查长度、数字、大小写、特殊字符。
        - 2/STRONG：检查长度、数字、大小写、特殊字符字典文件。
- validate_password_special_char_count：密码至少要包含的特殊字符数。


可以直接修改变量，例如：set global validate_password_policy=2



#### 修改密码测试一下插件

    update user set authentication_string=password('abc.123') where user='root';
    select host,user, authentication_string from user;

#### 扩展

如果想关闭validate_password插件

    [mysqld]
    #关闭密码策略
    validate_password = off



##### 参考：
centos7 安装 Mysql 5.7.27，详细完整教程

https://www.cnblogs.com/jinghuyue/p/11565564.html

mysql安装validate_password密码校验插件

https://blog.csdn.net/sumengnan/article/details/114096448