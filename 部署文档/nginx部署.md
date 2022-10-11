## nginx部署

### 1、下载与解压nginx
```shell
wget http://nginx.org/download/nginx-1.19.10.tar.gz
    
tar -zxvf nginx-1.19.10.tar.gz 
```
### 2、nginx依赖安装
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
### 3、编译与安装nginx
#### 进入解压后目录
```shell
cd  nginx-1.19.10/
```
#### configure
```shell
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
# 配置
# --prefix 指定安装目录
# --with-http_ssl_module 安装 https 模块
# 出现 creating objs/Makefile 代表编译成功
```
#### 编译并安装
```shell
#make 编译
#make install 安装
make && make install
```
### 3、测试编译安装的效果
#### 查看nginx的版本
```shell
/usr/local/nginx/sbin/nginx -v
```
结果
```shell
nginx version: nginx/1.19.10
```
### 4、查看nginx的配置编译参数
```shell
/usr/local/nginx/sbin/nginx -V
```
结果
```shell
nginx version: nginx/1.19.10
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC)
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
```

注意区分和上一条查看版本命令的区别： -v参数分别是小写和大写

### 4、配置nginx服务

#### 运行的准备工作:配置日志目录
```shell
mkdir /data/nginx
mkdir /data/nginx/logs
```
#### 运行的准备工作:创建nginx用户
```shell
groupadd nginx
    
useradd -g nginx -s /sbin/nologin -M nginx 

#-g:指定所属的group

#-s:指定shell,因为它不需要登录，所以用/sbin/nologin

#-M：不创建home目录,因为它不需要登录
```
#### 简单配置nginx
```shell
vi nginx.conf

#指定运行nginx的用户和组是:nginx

    user nginx nginx;

#发生错误时要写入到错误日志（目录用上面创建好的）

    error_log /data/nginx/logs/error.log;

#指定pid的路径

    pid logs/nginx.pid;

#日志格式（取消注释即可）

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

#指定访问日志的路径和格式（取消注释、修改路径）

    access_log  /data/nginx/logs/access.log  main;

```
#### 生成service文件
```shell
vi /usr/lib/systemd/system/nginx.service
```
内容
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
#### 启动服务
```shell
#重新加载服务文件
systemctl daemon-reload 

# 保存退出
# 尝试启动 nginx
systemctl start nginx
# 查看nginx是否启动
ps -ef | grep nginx
# 加入开机启动
systemctl enable nginx
# 不需要的时候可以禁止开机启动
systemctl disable nginx
```
#### 查看效果:
从浏览器访问安装机器的ip的配置端口即可：
#### 查看日志目录
```shell
ll /data/nginx/logs/
# 结果
total 8
-rw-r----- 1 root root 920 Apr 28 17:36 access.log
-rw-r----- 1 root root 274 Apr 28 17:36 error.log
```
日志已成功写入
### 5、修改Nignx缺省banner
#### 修改nginx源代码
```shell
vi /home/lin/nginx-1.19.10/src/http/ngx_http_header_filter_module.c
#修改前代码
static u_char ngx_http_server_string[] = "Server: nginx" CRLF;
static u_char ngx_http_server_full_string[] = "Server: " NGINX_VER CRLF;
static u_char ngx_http_server_build_string[] = "Server: " NGINX_VER_BUILD CRLF;
#修改后代码
static u_char ngx_http_server_string[] = "Server: unkowna" CRLF;
static u_char ngx_http_server_full_string[] = "Server: unkowna " CRLF;
static u_char ngx_http_server_build_string[] = "Server: unkowna" CRLF;
```
#### configure（参照安装时的参数）
```shell
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
```
#### 编译
```shell
sudo make 
```
#### 首次安装执行安装   
```shell
make install
```
#### 已安装的替换nginx
```shell
#备份
cp /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak
#停止服务
systemctl stop nginx.service
#拷贝新的编译的nginx
cp /home/lin/nginx-1.19.10/objs/nginx /usr/local/nginx/sbin/nginx
```
#### 修改nginx配置
```shell
# 在nginx.conf的http标签中添加server_tokens off;
vi /usr/local/nginx/conf/nginx.conf
# 修改前
    http {
    include       mime.types;
    default_type  application/octet-stream;
    
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log  /data/nginx/logs/access.log  main;
    
    sendfile        on;
    #tcp_nopush     on;
    
    #keepalive_timeout  0;
    keepalive_timeout  65;
# 修改后
    http {
    include       mime.types;
    default_type  application/octet-stream;
    
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log  /data/nginx/logs/access.log  main;
    
    server_tokens off;
    
    sendfile        on;
    #tcp_nopush     on;
    
    #keepalive_timeout  0;
    keepalive_timeout  65;

# 启动nginx
systemctl start nginx.service
```
通过curl查看结果
```shell
curl -I http://127.0.0.1:9191

#部署前
curl -I http://127.0.0.1:9191
HTTP/1.1 200 OK
Server: nginx/1.19.10
Date: Thu, 29 Apr 2021 00:54:39 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Wed, 28 Apr 2021 09:19:30 GMT
Connection: keep-alive
ETag: "608928a2-264"
Accept-Ranges: bytes

#部署后效果
HTTP/1.1 200 OK
Server: unkowna
Date: Thu, 29 Apr 2021 01:22:58 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Wed, 28 Apr 2021 09:19:30 GMT
Connection: keep-alive
ETag: "608928a2-264"
Accept-Ranges: bytes
```
### 7、配置反向代理

#### Nginx 代理服务的配置说明
- 设置 404 页面导向地址


    error_page  404 /404.html; #错误页
    proxy_intercept_errors on;    #如果被代理服务器返回的状态码为400或者大于400，设置的error_page配置起作用。默认为off。

- 代理只允许接受get


    proxy_method get;#支持客户端的请求方法

- 设置支持的http协议版本


    proxy_http_version 1.0 ; #Nginx服务器提供代理服务的http协议版本1.0，1.1，默认设置为1.0版本


- 关于代理配置的配置文件部分，仅供参考


    include       mime.types;   #文件扩展名与文件类型映射表
    default_type  application/octet-stream; #默认文件类型，默认为text/plain
    #access_log off; #取消服务日志    
    log_format myFormat ' $remote_addr–$remote_user [$time_local] $request $status $body_bytes_sent $http_referer $http_user_agent $http_x_forwarded_for'; #自定义格式
    access_log log/access.log myFormat;  #combined为日志格式的默认值
    sendfile on;   #允许sendfile方式传输文件，默认为off，可以在http块，server块，location块。
    sendfile_max_chunk 100k;  #每个进程每次调用传输数量不能大于设定的值，默认为0，即不设上限。
    keepalive_timeout 65;  #连接超时时间，默认为75s，可以在http，server，location块。
    proxy_connect_timeout 1;   #nginx服务器与被代理的服务器建立连接的超时时间，默认60秒
    proxy_read_timeout 1; #nginx服务器想被代理服务器组发出read请求后，等待响应的超时间，默认为60秒。
    proxy_send_timeout 1; #nginx服务器想被代理服务器组发出write请求后，等待响应的超时间，默认为60秒。
    proxy_http_version 1.0 ; #Nginx服务器提供代理服务的http协议版本1.0，1.1，默认设置为1.0版本。
    #proxy_method get;    #支持客户端的请求方法。post/get；
    proxy_ignore_client_abort on;  #客户端断网时，nginx服务器是否终端对被代理服务器的请求。默认为off。
    proxy_ignore_headers "Expires" "Set-Cookie";  #Nginx服务器不处理设置的http相应投中的头域，这里空格隔开可以设置多个。
    proxy_intercept_errors on;    #如果被代理服务器返回的状态码为400或者大于400，设置的error_page配置起作用。默认为off。
    proxy_headers_hash_max_size 1024; #存放http报文头的哈希表容量上限，默认为512个字符。
    proxy_headers_hash_bucket_size 128; #nginx服务器申请存放http报文头的哈希表容量大小。默认为64个字符。
    proxy_next_upstream timeout;  #反向代理upstream中设置的服务器组，出现故障时，被代理服务器返回的状态值。error|timeout|invalid_header|http_500|http_502|http_503|http_504|http_404|off
    #proxy_ssl_session_reuse on; 默认为on，如果我们在错误日志中发现“SSL3_GET_FINSHED:digest check failed”的情况时，可以将该指令设置为off。


#### Nginx代理服务配置参考(验证通过)
```shell
    http {
    include       mime.types;
    default_type  application/octet-stream;
    
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log  /data/nginx/logs/access.log  main;
    
    server_tokens off;
    
    sendfile        on;
    #tcp_nopush     on;
    
    #keepalive_timeout  0;
    keepalive_timeout  65;
    
    gzip  on;
    client_max_body_size 50m;  #缓冲区代理缓冲用户端请求的最大字节数,可以理解为保存到本地再传给用户
    client_body_buffer_size 256k;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    proxy_connect_timeout 300s; #nginx跟后端服务器连接超时时间(代理连接超时)
    proxy_read_timeout 300s; #连接成功后，后端服务器响应时间(代理接收超时)
    proxy_send_timeout 300s;
    proxy_buffer_size 64k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
    proxy_buffers 4 32k; #proxy_buffers缓冲区，网页平均在32k以下的话，这样设置
    proxy_busy_buffers_size 64k; #高负荷下缓冲大小（proxy_buffers*2）
    proxy_temp_file_write_size 64k;  #设定缓存文件夹大小，大于这个值，将从upstream服务器传递请求，而不缓冲到磁盘
    proxy_ignore_client_abort on; #不允许代理端主动关闭连接
    
    server {
        listen       80;
        server_name  base.sdchedu.cn;
    
       # 同步请求
       location /sync {
            proxy_pass       http://10.30.211.105:8080; #服务空中课堂访问地址
            proxy_redirect   off;
            proxy_set_header Host                        $host;                      # header添加请求host信息
            proxy_set_header X-Real-IP                   $remote_addr;               # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For             $proxy_add_x_forwarded_for; # 增加代理记录
            add_header       Access-Control-Allow-Origin *;
        }
    
       #拦截所有请求
       location /upload {
            proxy_pass http://10.30.211.113:8080; #服务空中课堂访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }
    }
    
    server {
        listen       80;
        server_name  dm.chsedu.cn;
       #拦截所有请求
       location / {
            proxy_pass http://IP:8080; #代码服务
            allow 223.78.120.140;#ip白名单
            allow 223.78.120.141;#ip白名单
            deny all;#白名单意外IP禁止访问
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }
    
    }
# 配置80转发到443端口（http转https）
     server {
        listen 80;
        server_name  college-aiapi.tencentyt.com;
        rewrite ^(.*)$ https://${server_name}$1 permanent;
    }

    server {

        listen       443;
        server_name  college-aiapi.tencentyt.com;

        ssl on;

        ssl_certificate /usr/local/nginx/sslfile/college-aiapi.tencentyt.com_bundle.crt;
        ssl_certificate_key /usr/local/nginx/sslfile/college-aiapi.tencentyt.com.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4:!RSA;
        ssl_session_timeout 180m;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.191:8080; #职校版ai接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }

    }
    }
```



### 8、配置负载均衡

#### 负载均衡原理
```txt
- 原理说明

如果你的nginx服务器给2台web服务器做代理，负载均衡算法采用轮询，那么当你的一台机器web程序iis关闭，也就是说web不能访问，那么nginx服务器分发请求还是会给这台不能访问的web服务器，如果这里的响应连接时间过长，就会导致客户端的页面一直在等待响应，对用户来说体验就打打折扣，这里我们怎么避免这样的情况发生呢。这里我配张图来说明下问题。

![image](https://www.runoob.com/wp-content/uploads/2018/08/398358-20160219104130363-660910928.jpg)

如果负载均衡中其中web2发生这样的情况，nginx首先会去web1请求，但是nginx在配置不当的情况下会继续分发请求道web2，然后等待web2响应，直到我们的响应时间超时，才会把请求重新分发给web1，这里的响应时间如果过长，用户等待的时间就会越长。

下面的配置是解决方案之一。

    proxy_connect_timeout 1;   #nginx服务器与被代理的服务器建立连接的超时时间，默认60秒
    proxy_read_timeout 1; #nginx服务器想被代理服务器组发出read请求后，等待响应的超时间，默认为60秒。
    proxy_send_timeout 1; #nginx服务器想被代理服务器组发出write请求后，等待响应的超时间，默认为60秒。
    proxy_ignore_client_abort on;  #客户端断网时，nginx服务器是否终端对被代理服务器的请求。默认为off。
- 如果使用upstream指令配置啦一组服务器作为被代理服务器，服务器中的访问算法遵循配置的负载均衡规则，同时可以使用该指令配置在发生哪些异常情况时，将请求顺次交由下一组服务器处理。


    proxy_next_upstream timeout;  #反向代理upstream中设置的服务器组，出现故障时，被代理服务器返回的状态值。

状态值可以是：

    error|timeout|invalid_header|http_500|http_502|http_503|http_504|http_404|off
    
    error：建立连接或向被代理的服务器发送请求或读取响应信息时服务器发生错误。
    timeout：建立连接，想被代理服务器发送请求或读取响应信息时服务器发生超时。
    invalid_header:被代理服务器返回的响应头异常。
    off:无法将请求分发给被代理的服务器。
    http_400，....:被代理服务器返回的状态码为400，500，502，等。
- 如果你想通过http获取客户的真是ip而不是获取代理服务器的ip地址，那么要做如下的设置。


    proxy_set_header Host $host; #只要用户在浏览器中访问的域名绑定了 VIP VIP 下面有RS；则就用$host ；host是访问URL中的域名和端口  www.taobao.com:80
    proxy_set_header X-Real-IP $remote_addr;  #把源IP 【$remote_addr,建立HTTP连接header里面的信息】赋值给X-Real-IP;这样在代码中 $X-Real-IP来获取 源IP
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;#在nginx 作为代理服务器时，设置的IP列表，会把经过的机器ip，代理机器ip都记录下来，用 【，】隔开；代码中用 echo $x-forwarded-for |awk -F, '{print $1}' 来作为源IP
关于X-Forwarded-For与X-Real-IP的一些相关文章可以查看：[HTTP 请求头中的 X-Forwarded-For](https://www.runoob.com/w3cnote/http-x-forwarded-for.html) 。

```
#### Nginx负载均衡方式介绍
```shell
- 轮询

轮询方式是Nginx负载默认的方式，顾名思义，所有请求都按照时间顺序分配到不同的服务上，如果服务Down掉，可以自动剔除，如下配置后轮训10001服务和10002服务。

    upstream  backend-server {
           server    localhost:10001;
           server    localhost:10002;
    }

- 权重

指定每个服务的权重比例，weight和访问比率成正比，通常用于后端服务机器性能不统一，将性能好的分配权重高来发挥服务器最大性能，如下配置后10002服务的访问比率会是10001服务的二倍。

参考1

    upstream  backend-server {
           server    localhost:10001 weight=1 ;
           server    localhost:10002 weight=2;
    }

参考2

    upstream  backend-server {
            #server 192.168.10.11:8080 weight=2 max_fails=2 fail_timeout=2;
            #server 192.168.10.12:8080 weight=1 max_fails=2 fail_timeout=1;    
    }

- iphash

每个请求都根据访问ip的hash结果分配，经过这样的处理，每个访客固定访问一个后端服务，如下配置（ip_hash可以和weight配合使用）

    upstream  backend-server {
           ip_hash; 
           server    localhost:10001 weight=1;
           server    localhost:10002 weight=2;
    }

- url_hash

按访问url的hash结果来分配请求，使每个url定向到同一个（对应的）后端服务器，后端服务器为缓存时比较有效

    upstream backend-server {
        server localhost:10001;
        server localhost:10002;
        hash $request_uri;
        hash_method crc32;
    }

- fair

按后端服务器的响应时间来分配请求，响应时间短的优先分配。

    upstream  backend-server {
           server    localhost:10001 weight=1;
           server    localhost:10002 weight=2;
           fair;  
    }

- 最少连接

将请求分配到连接数最少的服务上

    upstream  backend-server {
           least_conn;
           server    localhost:10001 weight=1;
           server    localhost:10002 weight=2;
    }
```
#### Nginx配置参考
```shell
#以轮训为例

    http {
    upstream  backend-server {
       server    localhost:10001;
       server    localhost:10002;
    }
    server {
       listen       10000;
       server_name  localhost;
    
       location / {
        proxy_pass http://backend-server1;
        proxy_redirect default;
      }
    }
    server {
       listen       10002;
       server_name  localhost;
    
       location / {
        proxy_pass http://backend-server2;
        proxy_redirect default;
      }
    }
    }
```
### 9、更新了ssh和ssl后安装nginx


#### 安装nginx——ssl插件
```shell
# 修改配置文件
vi /root/nginx-1.19.10/auto/lib/openssl/conf

# 说明 ：
# 修改1:

    CORE_INCS="$CORE_INCS $OPENSSL/openssl/include"
    CORE_DEPS="$CORE_DEPS $OPENSSL/openssl/include/openssl/ssl.h"
    
    if [ -f $OPENSSL/ms/do_ms.bat ]; then
        # before OpenSSL 1.1.0
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/ssleay32.lib" //修改lib为lib64
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/libeay32.lib"
    else
        # OpenSSL 1.1.0+
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/libssl.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/openssl/lib/libcrypto.lib"
    fi
    
# 修改为

    CORE_INCS="$CORE_INCS $OPENSSL/include"
    CORE_DEPS="$CORE_DEPS $OPENSSL/include/openssl/ssl.h"
    
    if [ -f $OPENSSL/ms/do_ms.bat ]; then
        # before OpenSSL 1.1.0
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib64/ssleay32.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib64/libeay32.lib"
    else
        # OpenSSL 1.1.0+
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib64/libssl.lib"
        CORE_LIBS="$CORE_LIBS $OPENSSL/lib64/libcrypto.lib"
    fi

# 修改2
	CORE_INCS="$CORE_INCS $OPENSSL/.openssl/include"
	CORE_DEPS="$CORE_DEPS $OPENSSL/.openssl/include/openssl/ssl.h"
	CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libssl.a"
	CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libcrypto.a"

# 修改为：
	CORE_INCS="$CORE_INCS $OPENSSL/include"
	CORE_DEPS="$CORE_DEPS $OPENSSL/include/openssl/ssl.h"
	CORE_LIBS="$CORE_LIBS $OPENSSL/lib64/libssl.a"
	CORE_LIBS="$CORE_LIBS $OPENSSL/lib64/libcrypto.a"

#### 配置编译安装

./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-openssl=/usr/local
    
make
make install

```
## 参考

```txt
centos8平台编译安装nginx1.19.10 
https://www.cnblogs.com/architectforest/p/12755195.html

详细记录一次Tomcat服务器和Nginx服务器的缺省banner的修改全过程
https://blog.csdn.net/honyer455/article/details/86491269

Nginx实现负载均衡
https://www.jianshu.com/p/4c250c1cd6cd

Nginx 反向代理与负载均衡详解
https://www.runoob.com/w3cnote/nginx-proxy-balancing.html

Nginx 配置详解
https://www.runoob.com/w3cnote/nginx-setup-intro.html

Nginx如何封禁IP和IP段的实现
https://www.jb51.net/article/190752.htm
```

```xml

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;
    client_max_body_size 500m;  #缓冲区代理缓冲用户端请求的最大字节数,可以理解为保存到本地再传给用户
    client_body_buffer_size 256k;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    proxy_connect_timeout 300s; #nginx跟后端服务器连接超时时间(代理连接超时)
    proxy_read_timeout 300s; #连接成功后，后端服务器响应时间(代理接收超时)
    proxy_send_timeout 300s;
    proxy_buffer_size 64k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
    proxy_buffers 4 32k; #proxy_buffers缓冲区，网页平均在32k以下的话，这样设置
    proxy_busy_buffers_size 64k; #高负荷下缓冲大小（proxy_buffers*2）
    proxy_temp_file_write_size 64k;  #设定缓存文件夹大小，大于这个值，将从upstream服务器传递请求，而不缓冲到磁盘
    proxy_ignore_client_abort on; #不允许代理端主动关闭连接



    include blockips.conf;#封锁IP


    server {
        listen       80;
        server_name  pm.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.17.133; #服务禅道项目管理访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

        location /prepare {
            proxy_pass http://10.30.211.125/prepare; #坚果ai重构接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }


    }

 server {
        listen       80;
        server_name  supervisor.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.130; #服务禅道项目管理访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }

    }



    server {
        listen       80;
        server_name  dm.chsedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.17.144; #代码服务
            allow 223.78.120.140;
            allow 49.232.235.182;
            allow 58.87.100.249;
            allow 122.152.218.235;
            allow 140.75.152.101;
            allow 223.166.21.149;
            allow 140.75.133.59;
            deny all;
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

    }

    server {
        listen       80;
        server_name  iotlan.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.127; #物联管控访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

    }

server {
        listen       80;
        server_name  iotlan1.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.127:90; #物联管控访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

    }





 server {
        listen       80;
        server_name  iotlan2.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.127:8001; #物联管控访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

    }

 server {
        listen       80;
        server_name  iotlan3.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.127:6001; #物联管控访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

    }



    server {
        listen 80;
        server_name  oa.sdchedu.cn;
        rewrite ^(.*)$ https://${server_name}$1 permanent;
    }

    server {
       # listen       80;
       # server_name  oa.sdchedu.cn;

       #拦截所有请求
       #location / {
       #     proxy_pass http://10.30.211.120; #oa访问地址
       #     proxy_redirect off;
#           proxy_set_header Host $host; #header添加请求host信息
#            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
#            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
#           add_header Access-Control-Allow-Origin *;
#        }


        listen       443 ssl;
        server_name  oa.sdchedu.cn;

        #ssl on;

        ssl_certificate /usr/local/nginx/sslfile/oa.sdchedu.cn_bundle.crt;
        ssl_certificate_key /usr/local/nginx/sslfile/oa.sdchedu.cn.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_session_timeout 180m;


       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.120; #OA访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }





    }

    server {
        listen       80;
        server_name  zhjs.sdchedu.cn;

        client_max_body_size    500M;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.116:8080; #智慧教室接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           #  add_header Access-Control-Allow-Origin *;
        }

    }

 server {
        listen       80;
        server_name  sc.sdchedu.cn;


 #拦截所有请求
       location / {
            proxy_pass http://10.30.211.116:80; #智慧教室接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

       location /oss/group {
            proxy_pass http://10.30.211.116:8080; #智慧教室接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *; #服务端已经配置跨域
        }

       location /login {
            proxy_pass http://10.30.211.116:8080; #智慧教室接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *; #服务端已经配置跨域
        }
    }





    server {
        listen       80;
        server_name  aiapi.sdchedu.cn;

        location /WW_verify_z3WXD3UcJbgXg5RM.txt {
            alias /usr/local/nginx/html/WW_verify_z3WXD3UcJbgXg5RM.txt;
        }

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.125:8080; #坚果ai重构接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }

    }

 server {
        listen       80;
        server_name  th.sdchedu.cn;

       # location /WW_verify_z3WXD3UcJbgXg5RM.txt {
       #     alias /usr/local/nginx/html/WW_verify_z3WXD3UcJbgXg5RM.txt;
       # }

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.128; #teacher-honor教师荣誉接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
            add_header Access-Control-Allow-Origin *;
        }

    }


 server {
        listen       80;
        server_name  mp.sdchedu.cn;

        location /WW_verify_z3WXD3UcJbgXg5RM.txt {
            alias /usr/local/nginx/html/WW_verify_z3WXD3UcJbgXg5RM.txt;
        }

       #拦截所有请求
       location / {
            proxy_pass http://10.30.18.20; #teacher-honor教师荣誉接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
#            add_header Access-Control-Allow-Origin *;
        }

    }

    server {
        listen       443 ssl;
        server_name  zhjs.sdchedu.cn;

        client_max_body_size    500M;

        #ssl on;

        ssl_certificate /usr/local/nginx/sslfile/1_zhjs.sdchedu.cn_bundle.crt;
        ssl_certificate_key /usr/local/nginx/sslfile/2_zhjs.sdchedu.cn.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_session_timeout 180m;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.116:8080; #智慧教室接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           #  add_header Access-Control-Allow-Origin *;
        }

    }

 server {
        listen       443 ssl;
        server_name  aiapi.sdchedu.cn;

#       ssl on;

        ssl_certificate /usr/local/nginx/sslfile/1_aiapi.sdchedu.cn_bundle.crt;
        ssl_certificate_key /usr/local/nginx/sslfile/2_aiapi.sdchedu.cn.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_session_timeout 180m;



        location /WW_verify_z3WXD3UcJbgXg5RM.txt {
            alias /usr/local/nginx/html/WW_verify_z3WXD3UcJbgXg5RM.txt;
        }

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.125:8080; #坚果ai重构接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }

 #拦截所有请求
       location /prepare {
            proxy_pass http://10.30.211.125/prepare; #坚果ai重构接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }


    }


 server {
        listen       80;
        server_name  consumption.sdchedu.cn;

       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.131; # 消费系统访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }

    }


    server {
        listen 80;
        server_name  college-aiapi.tencentyt.com;
        rewrite ^(.*)$ https://${server_name}$1 permanent;
    }

    server {

        listen       443  ssl;
        server_name  college-aiapi.tencentyt.com;

 #       ssl on;

        ssl_certificate /usr/local/nginx/sslfile/college-aiapi.tencentyt.com_bundle.crt;
        ssl_certificate_key /usr/local/nginx/sslfile/college-aiapi.tencentyt.com.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_session_timeout 180m;


       #拦截所有请求
       location / {
            proxy_pass http://10.30.211.191:8080; #职校版ai接口访问地址
            proxy_redirect off;
            proxy_set_header Host $host; #header添加请求host信息
            proxy_set_header X-Real-IP $remote_addr; # header增加请求来源IP信息
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 增加代理记录
           # add_header Access-Control-Allow-Origin *;
        }

    }

}



```




# chkconfig: - 85 15
# description: nginx is a World Wide Web server. It is used to serve
#!/bin/sh
# Name:nginx4comex
# nginx - this script starts and stops the nginx daemon
#
# description:  Nginx is an HTTP(S) server, HTTP(S) reverse \
#               proxy and IMAP/POP3 proxy server
# processname: nginx
# config:      /usr/local/nginx/conf/nginx.conf
# pidfile:     /usr/local/nginx/nginx.pid
#
# Created By http://comexchan.cnblogs.com/

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

NGINX_DAEMON_PATH="/usr/local/nginx/sbin/nginx"
NGINX_CONF_FILE="/usr/local/nginx/conf/nginx.conf"
NGINX_LOCK_FILE="/var/lock/subsys/nginx.service"
prog=$(basename $NGINX_DAEMON_PATH)

start() {
    [ -x $NGINX_DAEMON_PATH ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    echo -n $"Starting $prog: "
    daemon $NGINX_DAEMON_PATH -c $NGINX_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $NGINX_LOCK_FILE
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $NGINX_LOCK_FILE
    return $retval
}

restart() {
    configtest || return $?
    stop
    start
}

reload() {
    configtest || return $?
    echo -n $"Reloading $prog: "
    killproc $NGINX_DAEMON_PATH -HUP
    RETVAL=$?
    echo
}

force_reload() {
    restart
}

configtest() {
  $NGINX_DAEMON_PATH -t -c $NGINX_CONF_FILE
}

rh_status() {
    status $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
            ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
        exit 2
esac