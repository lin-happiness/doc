## redis部署

### 一、为什么使用 Redis？ 
- Redis 是开源的内存中的数据结构存储系统，它可以用作数据库、数据缓存和消息中间件。
- 它支持多种类型的数据结构，如 字符串strings， 散列 hashes， 列表 lists， 集合 sets， 有序集合 sorted sets 与范围查询， bitmaps， hyperloglogs 和 地理空间（geospatial） 索引半径查询。
- Redis 还内置了 复制（replication），LUA脚本（Lua scripting）， LRU驱动事件（LRU eviction），事务（transactions） 和不同级别的磁盘持久化（persistence）， 并通过 Redis哨兵（Sentinel）和自动 分区（Cluster）提供高可用性（high availability）
- 支持数据的备份，即 master-slave 模式的数据备份。
- 运行时数据和状态都保存在内存中，支持数据的持久化。 可以将内存中的数据保持在磁盘中，重启的时候可以再次加载进行使用等等。 
### 二、Redis在项目中的应用场景 
- 缓存数据 最常用，对经常需要查询且变动不是很频繁的数据 常称作热点数据。
- 消息队列 相当于消息订阅系统，比如ActiveMQ、RocketMQ。如果对数据有较高一致性要求时，还是建议使用MQ。 
- 计数器 比如统计点击率、点赞率，Redis具有原子性，可以避免并发问题。 
- 电商网站信息 大型电商平台初始化页面数据的缓存。比如去哪儿网购买机票的时候首页的价格和你点进去的价格会有差异。 
- 热点数据 比如新闻网站实时热点、微博热搜等，需要频繁更新。总数据量比较大的时候直接从数据库查询会影响性能。 
### 三、redis部署-手工

#### 安装依赖
    yum install -y gcc gcc-c++ make openssl openssl-devel wget
#### 下载安装包
    wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.9.tar.gz"
#### 解压安装包
    tar -zxf redis.tar.gz
    cd redis-5.0.9/
#### make编译并安装
    sudo make
    sudo make PREFIX=/usr/local/redis install
    sudo chmod 755 -R  /usr/local/redis/

#### 配置
    cd utils/

##### 一直回车到最后只修改路径
    sudo ./install_server.sh
    
    Welcome to the redis service installer
    This script will help you easily set up a running redis server
    
    Please select the redis port for this instance: [6379]
    Selecting default: 6379
    Please select the redis config file name [/etc/redis/6379.conf]
    Selected default - /etc/redis/6379.conf
    Please select the redis log file name [/var/log/redis_6379.log]
    Selected default - /var/log/redis_6379.log
    Please select the data directory for this instance [/var/lib/redis/6379]
    Selected default - /var/lib/redis/6379
    Please select the redis executable path []
    Mmmmm...  it seems like you don't have a redis executable. Did you run make install yet?
    [lin@VM-0-6-centos utils]$ sudo ./install_server.sh
    Welcome to the redis service installer
    This script will help you easily set up a running redis server
    
    Please select the redis port for this instance: [6379]
    Selecting default: 6379
    Please select the redis config file name [/etc/redis/6379.conf]
    Selected default - /etc/redis/6379.conf
    Please select the redis log file name [/var/log/redis_6379.log]
    Selected default - /var/log/redis_6379.log
    Please select the data directory for this instance [/var/lib/redis/6379]
    Selected default - /var/lib/redis/6379
    Please select the redis executable path [] /usr/local/redis/bin/redis-server
    Selected config:
    Port           : 6379
    Config file    : /etc/redis/6379.conf
    Log file       : /var/log/redis_6379.log
    Data dir       : /var/lib/redis/6379
    Executable     : /usr/local/redis/bin/redis-server
    Cli Executable : /usr/local/redis/bin/redis-cli
    Is this ok? Then press ENTER to go on or Ctrl-C to abort.
    Copied /tmp/6379.conf => /etc/init.d/redis_6379
    Installing service...
    Successfully added to chkconfig!
    Successfully added to runlevels 345!
    Starting Redis server...
    Installation successful!


#### 查看服务状态
    [lin@VM-0-6-centos utils]$  netstat -natp | grep 6379
    (No info could be read for "-p": geteuid()=1000 but you should be root.)
    tcp        0      0 127.0.0.1:6379          0.0.0.0:*               LISTEN      -


#### 创建软链接，优化服务
    sudo ln -s /usr/local/redis/bin/* /usr/local/bin/

#### 修改redis配合（外网可以访问）

    sudo sed -i  '70s/127.0.0.1/0.0.0.0/' /etc/redis/6379.conf 
    sudo sed -i  '89s/protected-mode yes/protected-mode no/' /etc/redis/6379.conf

- 不同版本的conf行数可能存在差异，根据情况修改行数，vi中通过:set number查看行数


#### 重启服务
    [lin@VM-0-6-centos bin]$ sudo service redis_6379 restart
    Stopping ...
    Redis stopped
    Starting Redis server...

#### 登录数据库-命令方式
    [lin@VM-0-6-centos bin]$ redis-cli -h 172.17.0.6 -p 6379
    172.17.0.6:6379>
- -h指定地址，-p指定端口

#### 登录数据库-桌面工具

- Another Redis Desktop Manager
- RedisDesktopManager

#### 部分命令说明

##### 键值key-value的管理
    格式：
    创建键：set 键名 值
    删除键：del 键名
    获取键对应的值：get 键名
    获取当前数据库的所有键：keys 
##### 数据库的切换
    格式：
    切换到某库：select 库名
    移动当前库中的键值到另一个库：move 键名 库名 

##### 数据库的性能测试
    redis-benchmark -h 172.17.0.6 -p 6379 -t get -c 50 -n 10000

- -h 指服务器的地址  
- -p 服务端口
- -c 并发连接数
- -n 请求总数


结果

    [lin@VM-0-6-centos redis-5.0.9]$ redis-benchmark -h 172.17.0.6 -p 6379 -t get -c 50 -n 10000
    ====== GET ======
      10000 requests completed in 0.26 seconds
      50 parallel clients
      3 bytes payload
      keep alive: 1
      
    60.48% <= 1 milliseconds
    99.91% <= 2 milliseconds
    100.00% <= 2 milliseconds
    38022.81 requests per second

#### 配置Redis密码及登录
##### 配置密码
- 第一种方式：在redis配置文件中配置requirepass


    sudo vi /etc/redis/6379.conf
原配置

    # requirepass foobared
去掉注释，修改密码

    requirepass 654321
结果

    [lin@VM-0-6-centos ~]$ sudo service redis_6379 restart
    Stopping ...
    Redis stopped
    Starting Redis server...
    [lin@VM-0-6-centos ~]$ redis-cli -h 172.17.0.6 -p 6379
    172.17.0.6:6379> auth 654321
    OK
    172.17.0.6:6379> set lin 123
    OK
    172.17.0.6:6379> get lin
    "123"
    172.17.0.6:6379>

- 第二种方式：在命令界面设置密码：


    config set requirepass 123456
结果

    [lin@VM-0-6-centos ~]$ redis-cli -h 172.17.0.6 -p 6379
    172.17.0.6:6379> config set requirepass 123456
    OK
    172.17.0.6:6379> set lin a
    (error) NOAUTH Authentication required.
    172.17.0.6:6379> auth 123456
    OK
    172.17.0.6:6379> set lin a
    OK
    172.17.0.6:6379> get lin
    "a"
    172.17.0.6:6379> config get requirepass
    1) "requirepass"
    2) "123456"
    172.17.0.6:6379>

注：如果没有在配置文件中配置requirepass，redis重启后密码将失效

##### 登录有密码的Redis
- 第一种方式：在登录的时候的时候输入密码：


    redis-cli -h 172.17.0.6 -p 6379 -a 654321

- 第二种方式：先登陆后验证：


    redis-cli -h 172.17.0.6 -p 6379
    172.17.0.6:6379> auth 654321

##### 重启有密码的Redis
通过服务重启带密码的redis会报错，可以通过redis命令方式关闭redis：通过redis-cli密码登陆，执行shutdown命令 


    [lin@VM-0-6-centos ~]$ sudo service redis_6379 restart
    Stopping ...
    (error) NOAUTH Authentication required.
    Waiting for Redis to shutdown ...
    Waiting for Redis to shutdown ...
    Waiting for Redis to shutdown ...
    ^C
    [lin@VM-0-6-centos ~]$ redis-cli -h 172.17.0.6 -p 6379 -a 654321
    Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
    172.17.0.6:6379> shutdown
    not connected> exit
    [lin@VM-0-6-centos ~]$ ps aux|grep redis
    lin       9175  0.0  0.0 112812   972 pts/1    R+   15:02   0:00 grep --color=auto redis

还可以通过修改redis重启脚本的方式，修改redis服务脚本，大约43行中-p 后面添加 -a 654321 (654321为redis的密码)

    sudo vi /etc/rc.d/init.d/redis_6379
修改前

    $CLIEXEC -p $REDISPORT shutdown
修改后

    $CLIEXEC -p $REDISPORT -a 654321 shutdown

结果（会提示安全警告，因为明文的将密码写入了配置中）

    [lin@VM-0-6-centos bin]$ sudo service redis_6379 restart
    Stopping ...
    Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
    Redis stopped
    Starting Redis server...


### 四、redis部署-docker
#### 部署docker环境
参考docker部署

#### 获取redis镜像

    sudo docker pull redis:latest
结果

    [lin@VM-0-6-centos ~]$ sudo docker pull redis:latest
    latest: Pulling from library/redis
    f7ec5a41d630: Pull complete
    a36224ca8bbd: Pull complete
    7630ad34dcb2: Pull complete
    c6d2a5632e6c: Pull complete
    f1957981f3c1: Pull complete
    42642d666cff: Pull complete
    Digest: sha256:e10f55f92478715698a2cef97c2bbdc48df2a05081edd884938903aa60df6396
    Status: Downloaded newer image for redis:latest
    docker.io/library/redis:latest


不加版本号默认获取最新版本，可以使用 docker search redis 查看镜像来源

#### 查看本地镜像

    sudo docker images

结果

    [lin@VM-0-6-centos ~]$ sudo docker images
    REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
    redis        latest    739b59b96069   9 days ago   105MB


#### 从官网获取[redis.conf](http://download.redis.io/redis-stable/redis.conf)配置文件（官网下载龟速，想别的办法吧）

修改默认配置文件
- bind 127.0.0.1 #注释掉这部分，这是限制redis只能本地访问
- protected-mode no #默认yes，开启保护模式，限制为本地访问
- daemonize no#默认no，改为yes意为以守护进程方式启动，可后台运行，除非kill进程（可选），改为yes会使配置文件方式启动redis失败
- dir  ./ #输入本地redis数据库存放文件夹（可选）
- appendonly yes #redis持久化（可选）


#### docker 启动 redis 命令

    mkdir /data/redis/data -p
    mkdir /data/redis/conf -p
    
    docker run -p 6379:6379 --name redis --restart=always  -v /home/docker/redis.conf:/etc/redis/redis.conf -v /home/docker/data:/data -d redis redis-server /etc/redis/redis.conf --appendonly yes 
    
    docker run -d --name redis --restart=always -p 6379:6379  -v /data/redis/conf:/etc/redis/redis.conf -v /data/redis/data:/data  redis --requirepass "abc.123" --appendonly yes

/home/docker/redis.conf配置文件一定要有，否则生成一个redis.conf的文件夹

命令解释说明：

    -p 6379:6379 端口映射：前表示主机部分，：后表示容器部分。
    --name myredis  指定该容器名称，查看和进行操作都比较方便。
    -v 挂载目录，规则与端口映射相同。
    -d redis 表示后台启动redis
    redis-server /etc/redis/redis.conf  以配置文件启动redis，加载容器内的conf文件，最终找到的是挂载的目录/usr/local/docker/redis.conf
    appendonly yes 开启redis 持久化

#### 使用命令查看redis容器运行情况

    [lin@VM-0-6-centos redis.conf]$ sudo docker ps -a
    CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS                                       NAMES
    b775a1485617   redis     "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:6380->6379/tcp, :::6380->6379/tcp   myredis
    [lin@VM-0-6-centos redis.conf]$


#### 使用命令进入redis

    [lin@VM-0-6-centos redis.conf]$ sudo docker exec -it myredis /bin/bash
    root@b775a1485617:/data#


#### 使用 redis-cli 可以测试连接

    root@b775a1485617:/data# redis-cli
    127.0.0.1:6379>


### 参考

菜鸟教程-Redis教程

https://www.runoob.com/redis/keys-keys.html

部署 redis 和基本操作

https://blog.csdn.net/weixin_49228721/article/details/109612634

redis 密码时 重启问题

https://blog.csdn.net/mingjie1212/article/details/51778914

docker方式安装redis

https://www.runoob.com/docker/docker-install-redis.html

Docker 安装 Redis

https://www.cnblogs.com/liyiran/p/11522114.html