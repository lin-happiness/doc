# 一、环境准备
## 1、升级操作系统从centos7.8升级到CentOS Linux release 7.9.2009 (Core)
```shell
	yum update -y
```
## 2、安装wget  腾讯云默认已安装
```shell
yum install -y wget
```
## 3、调整防火墙，腾讯云默认防火墙是关闭状态，打开端口根据业务需要调整
```shell
	开启防火墙 
	systemctl start firewalld
	添加80,443端口 
	firewall-cmd --zone=public --add-port=80/tcp --permanent
	firewall-cmd --zone=public --add-port=443/tcp --permanent
	firewall-cmd --zone=public --add-port=20000-30000/tcp --permanent
	重新载入配置
	firewall-cmd --reload
	查看防火墙端口配置情况
	firewall-cmd --zone=public --list-ports
	删除端口
	firewall-cmd --zone= public --remove-port=80/tcp --permanent
		
	获取所有支持的ICMP类型
	firewall-cmd --get-icmptypes
	
	增加icmp时间戳过滤
	firewall-cmd --zone=public --add-icmp-block=timestamp-reply  --permanent
	firewall-cmd --zone=public --add-icmp-block=timestamp-request --permanent
	firewall-cmd --zone=public --add-icmp-block=time-exceeded --permanent
	重新载入配置
	firewall-cmd --reload
	查看过滤规则
	firewall-cmd --zone=public --list-icmp-blocks	
```
## 4、安装htop iftop iotop lsof
```shell
    yum install -y epel-release
	yum install -y htop iftop iotop lsof
```
## 5、安装了unzip
```shell
	yum install unzip	
```
## 6、关闭selinux 
临时关闭：
```shell
    sudo setenforce 0
```
永久关闭：
```shell
    vi /etc/selinux/config
    将SELINUX=enforcing改为SELINUX=disabled，保存后退出
```



# PHP环境部署
## 一、PHP安装流程
### 1、首先安装EPEL软件包：
```shell
    yum install epel-release
```
### 2、然后安装源
```shell
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
```
### 3、查看源的情况
```shell
    yum repolist all|grep php72
```
返回结果如下：
```shell
    ------------
    [root@VM-1-8-centos ~]# yum repolist all|grep php72
    Repository epel is listed more than once in the configuration
    remi-php72                          Remi's PHP 7.2 RPM repositor disabled
    remi-php72-debuginfo/x86_64         Remi's PHP 7.2 RPM repositor disabled
    remi-php72-test                     Remi's PHP 7.2 test RPM repo disabled
    remi-php72-test-debuginfo/x86_64    Remi's PHP 7.2 test RPM repo disabled
    ------------
```
看起来全都被禁用了，
### 4、启用第一个
```shell
    yum-config-manager --enable remi-php72
```
如果提示没有指令，就自行安装一下
```shell
    yum -y install yum-utils
```
### 5、然后就是安装PHP和PHP相关的插件。
```shell
    yum install php72 php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache php72-php-bcmath php72-php-zip php72-php-gearman php72-php-redis
```
增加redis插件
```shell
yum install  php72-php-redis
```
### 6、启动PHP7.2，同样是使用 service 命令来控制，比如启动
```shell
    service php72-php-fpm start 
    或者
    systemctl start php72-php-fpm.service
```
### 7、查看启动状态
```shell
    systemctl status php72-php-fpm.service
```
### 8、查看php版本
```shell
    /usr/bin/php72 -v
```
### 9、设置开启启动
```shell
    systemctl enable php72-php-fpm.service
```
### 10、安装rar扩展

### 安装 php72-php-devel否则phpize命令报错
```shell
    yum install php72-php-devel
```
### 下载地址rar安装包
http://pecl.php.net/package/rar

### 安装扩展，运行以下命令完成安装：
```shell
    gunzip rar-4.2.0.tgz
    
    tar -xvf rar-4.2.0.tar
    
    cd rar-4.2.0
    
    /opt/remi/php72/root/usr/bin/phpize
    
    ./configure --with-php-config=/opt/remi/php72/root/usr/bin/php-config
    
    make && make install
```
### 安装完成后，php的扩展目录会自动出现rar.so文件，只需在php.ini文件中引入即可。
编辑php.ini，加入以下代码：
```shell
    vi /opt/remi/php72/root/usr/lib64/php/modules/
    
    extension=rar.so
```
### 重启服务
```shell
    systemctl restart php72-php-fpm.service
```
### 查看扩展
```shell
    php72 -m
```
### 处理连接
```shell
cp /usr/bin/php72 /usr/bin/php
```
## 二、安装Nginx
nginx 安装使用编译安装的方式，首先从官网下载安装包，这里选择目前的稳定版1.18。

### 1、下载安装包
```shell
# 源码包放到 /data 目录下
mkdir /data
cd /data
# 下载源码包
wget http://nginx.org/download/nginx-1.19.4.tar.gz

```
### 如果提示 -bash: wget: 未找到命令 ，就安装一个 
```shell
    yum install wget
```
### 2、下载后解压缩
```shell
tar -zxvf nginx-1.19.4.tar.gz
```
### 3、进入到目录，
```shell
    cd nginx-1.19.4
```
### 4、安装对应依赖
```shell
# 1、安装 make
yum -y install autoconf automake make
# 2、安装 g++
yum -y install gcc gcc-c++
# 3、安装 pcre
yum -y install pcre pcre-devel
# 4、安装 zlib
yum -y install zlib zlib-devel
# 5、安装 openssl
yum install -y openssl openssl-devel

```

### 5、然后安装，执行以下命令
> 如不需要 *https* 模块则不用加 **--with-http_ssl_module**，上述openssl修改就是为了http_ssl模块准备

```shell
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
# 配置
# --prefix 指定安装目录
# --with-http_ssl_module 安装 https 模块
# 出现 creating objs/Makefile 代表编译成功
# make 编译
# make install 安装
make && make install
```
### 6、启动nginx

#### 进入到nginx的目录，/usr/local/nginx，启动nginx
```shell
    ./nginx
```
### 7、测试访问
    curl http://127.0.0.1

这时候访问主机的 IP地址，就会显示nginx的欢迎页面。打不开检查一下防火墙。

### 8、查看nginx版本
    /usr/local/nginx/sbin/nginx -V
### 9、设置为服务并设置开机启动
创建nginx.service文件
```shell
vi /usr/lib/systemd/system/nginx.service
```
 然后，用下面内容替换原内容
```shell
[Unit]
# 服务说明
Description=nginx service
After=network.target

# 服务运行参数配置
[Service]
Type=forking
# 启动服务，以下三个参数都需要绝对路径
ExecStart=/usr/local/nginx/sbin/nginx
# 重启服务
ExecReload=/usr/local/nginx/sbin/nginx -s reload
# 停止服务
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
### 设置开机自启
```shell
systemctl enable nginx.service 
```
### 10、查看运行状态
```shell
systemctl status nginx.service 
```
## 三、配置Nginx与PHP关联

### 1、创建一个用户 www
#### 1）、查看用户是否已经有www：
```shell
	cut -d : -f 1 /etc/passwd
```
#### 2）、查看用户组：
```shell
	cut -d : -f 1 /etc/group
```
#### 3）、创建指定用户和组 www
```shell
	添加组：
	groupadd www
	添加用户：
	useradd -g www -m  www
```

### 2、修改php的文件www.conf
```shell
vi /etc/opt/remi/php72/php-fpm.d/www.conf
```
将文件修改如下内容：（默认值是apache）
```shell
    user www
    group www

修改

    pm = dynamic为pm = static
    
    pm.max_children = 256 （数据根据内存大小除以30为上限，根据实际情况调整）
```

修改完成重新启动php-fpm
```shell
    service php72-php-fpm restart
    或者
    systemctl restart php72-php-fpm.service
```
### 3、修改php.ini
```shell
    vi /etc/opt/remi/php72/php.ini
    1）、调整 memory_limit ，根据内存大小调整 memory_limit = 10240M
    2）、调整 upload_max_filesize = 100M
```
修改完成重新启动php-fpm
```shell
    service php72-php-fpm restart
    或者 
    systemctl restart php72-php-fpm.service
```

### 4、修改nginx的配置
```shell
    vi /usr/local/nginx/conf/nginx.conf

去掉 user 的注解，改为 www
    
    user  www www;
```
### 5、设置网站根目录
默认nginx会访问安装目录里面的 html 文件夹，如果需要修改，则需要修改 server 下的 root 项，改成绝对路径。

### 6、默认配置中有关于PHP的配置，找到如下代码并将注解去掉
```shell
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
```
注意有些区别，fastcgi_param 部分有改动，注意也改一下，否则会出现400错误。

全文配置如下：
```shell
    user  www www;
    worker_processes  1;
    events {
        worker_connections  1024;
    }
    
    http {
        include       mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        keepalive_timeout  65;
    
    server {
        listen       80;
        server_name  _;
        root         /home/wwwroot/aiapi.jgjykj.com/public;
    
         location / {
                index index.html index.htm index.php default.html default.htm default.php;
                try_files $uri $uri/ /index.php?$query_string;
                if (!-e $request_filename) {
                        rewrite ^/(.*)$ /index.php?s=/$1 last;
              }
        }
    
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
    }
    }

```
重启Nginx，进入nginx程序目录
```shell
    ./nginx -s reload 
    或者 
    /usr/local/nginx/sbin/nginx -s reload 
    或者
    systemctl reload nginx.service
```

然后就在root指定的目录中创建测试文件 index.php

```shell
    <?php     
        phpinfo(); 

```
不出意外的话会看到正常的php信息页面


### nginx配置针对AI项目优化版本

### 1、server中root的路径：
```shell
    测试环境为root /home/wwwroot/aitest.sdchedu.cn/public;
    正式环境为root /home/wwwroot/aiapi.jgjykj.com/public;
```
### 2、同源问题暂未处理
```shell

    server {
                        listen       80;
                        server_name  _;
                        root /home/wwwroot/aiapi.jgjykj.com/public;
    
                        add_header Access-Control-Allow-Origin https://ai.jgjykj.com;
                        add_header Access-Control-Allow-Credentials true;
                        add_header Access-Control-Allow-Methods  GET,POST,PUT,DELETE,OPTIONS,PATCH;
                        add_header Access-Control-Allow-Headers DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization;
    
                        location / {
                        index index.html index.htm index.php default.html default.htm default.php;
                        #try_files $uri $uri/ /index.php?$query_string;
                        try_files $uri $uri/ /index.php?$1;
                        if (!-e $request_filename) {
                                        #一级目录
                                        rewrite ^/index.php(.*)$ /index.php?s=$1 last;
                                        rewrite ^/(.*)$ /index.php?s=/$1 last;
                                  }
                        if ($request_method = 'OPTIONS') {
                                        add_header Access-Control-Allow-Origin https://ai.jgjykj.com;
                                        add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS,PATCH;
                                        add_header Access-Control-Allow-Credentials true;
                                        add_header Access-Control-Allow-Headers DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization;
                                        return 204;
                                        }
                        }
    
                        error_page   500 502 503 504  /50x.html;
                        location = /50x.html {
                                root   html;
                        }


```



### 完整代码
```shell
       user  www www;
    
    worker_processes auto;
    worker_cpu_affinity auto;
    
    error_log  /data/wwwlogs/nginx_error.log  crit;
    
    pid        /usr/local/nginx/logs/nginx.pid;
    
    #Specifies the value for maximum file descriptors that can be opened by this process.
    worker_rlimit_nofile 51200;
    
    events
        {
            use epoll;
            worker_connections 51200;
            multi_accept off;
            accept_mutex off;
        }
    
    http
        {
        include       mime.types;
        default_type  application/octet-stream;
    
        server_names_hash_bucket_size 128;
        client_header_buffer_size 32k;
        large_client_header_buffers 4 32k;
        client_max_body_size 50m;
    
        sendfile on;
        sendfile_max_chunk 512k;
        tcp_nopush on;
    
        keepalive_timeout 60;
    
        tcp_nodelay on;
    
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_buffer_size 64k;
        fastcgi_buffers 4 64k;
        fastcgi_busy_buffers_size 128k;
        fastcgi_temp_file_write_size 256k;


        gzip on;
        gzip_min_length  1k;
        gzip_buffers     4 16k;
        gzip_http_version 1.1;
        gzip_comp_level 2;
        gzip_types     text/plain application/javascript application/x-javascript text/javascript text/css application/xml application/xml+rss;
        gzip_vary on;
        gzip_proxied   expired no-cache no-store private auth;
        gzip_disable   "MSIE [1-6]\.";
    
        #limit_conn_zone $binary_remote_addr zone=perip:10m;
        ##If enable limit_conn_zone,add "limit_conn perip 10;" to server section.
    
        server_tokens off;
        access_log off;
    
        server {
                listen       80;
                server_name  _;
                root /data/wwwroot/ds/public;
    
                add_header Access-Control-Allow-Origin $http_origin;
                add_header Access-Control-Allow-Credentials true;
                add_header Access-Control-Allow-Methods  GET,POST,PUT,DELETE,OPTIONS,PATCH;
                add_header Access-Control-Allow-Headers DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization;
    
                location / {
                index index.html index.htm index.php default.html default.htm default.php;
                #try_files $uri $uri/ /index.php?$query_string;
                try_files $uri $uri/ /index.php?$1;
                if (!-e $request_filename) {
                                #一级目录
                                rewrite ^/index.php(.*)$ /index.php?s=$1 last;
                                rewrite ^/(.*)$ /index.php?s=/$1 last;
                          }
                if ($request_method = 'OPTIONS') {
                                add_header Access-Control-Allow-Origin *;
                                add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS,PATCH;
                                add_header Access-Control-Allow-Credentials true;
                                add_header Access-Control-Allow-Headers DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization;
                                return 204;
                                }
                }
    
                error_page   500 502 503 504  /50x.html;
                location = /50x.html {
                        root   html;
                }
    
                # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
                #
                location ~ \.php$ {
                        fastcgi_pass   127.0.0.1:9000;
                        fastcgi_index  index.php;
                        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
                        include        fastcgi_params;
                }
    }


server {
    listen 8080;
    server_name _;
    root /data/wwwroot/test;
    index index.php index.html;

    location / {
        if (!-f $request_filename){
                rewrite (.*) /index.php;
        }
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }

}

}

```
## 四、PHP版本更新，7.3.33升级到7.4.27
```shell
#备份配置

/etc/opt/remi/php73

vi /etc/opt/remi/php73/php-fpm.d/www.conf
vi /etc/opt/remi/php73/php.ini

#安装php74
yum install -y php74 php74-php-fpm php74-php-gd php74-php-json php74-php-mbstring php74-php-mysqlnd php74-php-xml php74-php-xmlrpc php74-php-opcache php74-php-bcmath php74-php-zip php74-php-gearman php74-php-redis

#调整配置
vi /etc/opt/remi/php74/php-fpm.d/www.conf
vi /etc/opt/remi/php74/php.ini

# 处理连接
cp /usr/bin/php74 /usr/bin/php

# 关闭php73
systemctl stop php73-php-fpm.service
# 重启服务
systemctl restart php74-php-fpm.service
# 查看启动状态
systemctl status php74-php-fpm.service

#处理开机启动

systemctl disable php73-php-fpm.service
systemctl enable php74-php-fpm.service

#卸载
yum remove php73
yum remove php73-php*
yum remove php73-run*

#查看卸载情况
rpm -qa|grep php73

```

### N、更新ssh ssl【未处理，影响php环境安装】
由 OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017 升级到 OpenSSH_8.4p1, OpenSSL 1.1.1h  22 Sep 2020

脚本和离线安装包拷贝到root文件夹下，然后执行命令
	
	chmod 777 openssh8.4.sh
	
	./openssh8.4.sh