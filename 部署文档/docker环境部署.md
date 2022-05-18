## docker环境部署
### 1、centos7操作系统安装
参考
```txt
https://blog.csdn.net/qq_44714603/article/details/88829423
```
### 2、contos升级
```shell
    yum update -y
```
### 3、关闭防火墙
```shell
    systemctl stop firewalld
```
### 4、安装docker依赖包
```shell
    yum install -y yum-utils device-mapper-persistent-data lvm2
```
### 5、设置docker仓库
```shell
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
     
    yum clean all 
    yum makecache fast
```
### 6、安装docker
```shell
    yum -y install docker-ce docker-ce-cli containerd.io
```
### 7、设置docker开机自启动
```shell
    systemctl enable docker
```
### 8、启动docker
```shell
    systemctl start docker
```
### 9、配置docker加速
```shell
    vi /etc/docker/daemon.json
```
```txt
 添加内容，其中https://4vfegp0w.mirror.aliyuncs.com为个人阿里的加速连接，如果有自己的请使用自己的连接

    {"registry-mirrors":["https://4vfegp0w.mirror.aliyuncs.com"]}
```
```shell
    systemctl daemon-reload
     
    systemctl restart docker
```
### 10、安装docker compose
docker compose地址
```txt
https://github.com/docker/compose/releases
```
下载docker-compose
```shell
curl -L "https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
修改权限
```shell
    chmod +x /usr/local/bin/docker-compose
```
创建连接
```shell
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

 查看版本
```shell
    docker-compose --version
```
### 11、安装docker可视化管理工具portainer
```shell
    docker search portainer
     
    docker pull portainer/portainer
     
    docker images
     
    docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock --name Prtainer portainer/portainer  

#### [--restart=always  开机自启动容器]

    docker ps -a
```
```txt
    http://10.30.17.134:9000/    #密码：admin888
```


### 12、使用Dockerfile创建自己的docker镜像
```shell
    sudo mkdir compose_test
    sudo chmod 755 compose_test
    cd compose_test/
    sudo touch Dockerfile
    sudo chmod 755 Dockerfile
```
添加Dockerfile的脚本
```shell
    sudo vi Dockerfile
```
脚本示例
```shell
    # Set the base image to CentOS
    FROM centos:7
    # File Auther / Maintainer
    Maintainer lin 155202653@qq.com
    # Install necessary tools && redis
    RUN yum install -y gcc gcc-c++ make openssl openssl-devel wget\
    && wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz" \
    && tar -zxf redis.tar.gz \
    && cd redis-5.0.3 \
    && make && make PREFIX=/usr/local/redis install \
    && mkdir -p /usr/local/redis/conf/ \
    && cp redis.conf  /usr/local/redis/conf/ \
    && sed -i  '69s/127.0.0.1/0.0.0.0/' /usr/local/redis/conf/redis.conf \
    && sed -i  '88s/protected-mode yes/protected-mode no/' /usr/local/redis/conf/redis.conf
    # Expose ports
    EXPOSE 6379
    # Set the default command to execute when creating a new container
    ENTRYPOINT /usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
```
创建镜像
```shell
    sudo docker build -t centos_redis . #创建镜像，.表示在当前路径下查找dockerfile
```
结果
```shell
    [lin@VM-0-6-centos compose_test]$ sudo docker build -t centos_redis .
    Sending build context to Docker daemon   2.56kB
    Step 1/4 : FROM centos:7
     ---> 8652b9f0cb4c
    Step 2/4 : RUN yum install -y gcc gcc-c++ make openssl openssl-devel wget&& wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz" && tar -zxf redis.tar.gz && cd redis-5.0.3 && make && make PREFIX=/usr/local/redis install && mkdir -p /usr/local/redis/conf/ && cp redis.conf  /usr/local/redis/conf/ && sed -i  '69s/127.0.0.1/0.0.0.0/' /usr/local/redis/conf/redis.conf && sed -i  '88s/protected-mode yes/protected-mode no/' /usr/local/redis/conf/redis.conf
     ---> Running in 48af9d1dcabe
    Loaded plugins: fastestmirror, ovl
    Determining fastest mirrors
     * base: mirrors.163.com
     * extras: mirrors.163.com
     * updates: mirrors.163.com
    Resolving Dependencies
    ......
    ......
    ......
    make[1]: Leaving directory `/redis-5.0.3/src'
    cd src && make install
    make[1]: Entering directory `/redis-5.0.3/src'
        CC Makefile.dep
    make[1]: Leaving directory `/redis-5.0.3/src'
    make[1]: Entering directory `/redis-5.0.3/src'
    
    Hint: It's a good idea to run 'make test' ;)
    
        INSTALL install
        INSTALL install
        INSTALL install
        INSTALL install
        INSTALL install
    make[1]: Leaving directory `/redis-5.0.3/src'
    Removing intermediate container 48af9d1dcabe
     ---> 7104dc2b7d37
    Step 3/4 : EXPOSE 6379
     ---> Running in e19ab8864f9d
    Removing intermediate container e19ab8864f9d
     ---> 6dcb88cfe64a
    Step 4/4 : ENTRYPOINT /usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
     ---> Running in 0ed10ee51506
    Removing intermediate container 0ed10ee51506
     ---> 1cca1f9d7949
    Successfully built 1cca1f9d7949
    Successfully tagged centos_redis:latest
    [lin@VM-0-6-centos compose_test]$ sudo docker images
    REPOSITORY                      TAG           IMAGE ID       CREATED         SIZE
    centos_redis                    latest        1cca1f9d7949   4 minutes ago   575MB
    mynginx                         v1.0          3ec26d6717bd   2 hours ago     133MB

```

创建并运行容器
```shell
    sudo docker run -d --name myredis -p 6379:6379  centos_redis:latest
查看容器

    [lin@VM-0-6-centos compose_test]$ sudo docker ps -a
    CONTAINER ID   IMAGE                 COMMAND                  CREATED         STATUS         PORTS                                       NAMES
    e9f01f32e977   centos_redis:latest   "/bin/sh -c '/usr/lo…"   5 seconds ago   Up 4 seconds   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp   myredis
```


### 13、通过docker-compose管理docker
```shell
    vi docker-compose.yml
```
添加compose的脚本（待补充）

参考redmine部署


### 14、docker相关命令

#### 从dockerhub中查询镜像  
```shell
    docker search [keyword]
```
运行
```shell
    sudo docker search nginx
```
结果
```shell
    NAME                               DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
    nginx                              Official build of Nginx.                        14793     [OK]
    jwilder/nginx-proxy                Automated Nginx reverse proxy for docker con…   2019                 [OK]
```

​    
#### 从dockerhub拉取指定镜像
```shell
    docker pull [images]:[version]
```
运行
```shell
    sudo docker pull nginx:latest
```
结果
```shell
    latest: Pulling from library/nginx
    f7ec5a41d630: Pull complete
    aa1efa14b3bf: Pull complete
    b78b95af9b17: Pull complete
    c7d6bca2b8dc: Pull complete
    cf16cd8e71e0: Pull complete
    0241c68333ef: Pull complete
    Digest: sha256:75a55d33ecc73c2a242450a9f1cc858499d468f077ea942867e662c247b5e412
    Status: Downloaded newer image for nginx:latest
    docker.io/library/nginx:latest
```
#### 查看镜像信息列表（镜像是静态的）
```shell
docker images
```
运行
```shell
    sudo docker images
```
结果
```shell    
    REPOSITORY                      TAG           IMAGE ID       CREATED       SIZE
    nginx                           latest        62d49f9bab67   2 weeks ago   133MB
```
#### 给镜像打上标签
```shell
    docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]
```
运行
```shell
    sudo docker tag nginx mynginx:v1.0
    
    sudo docker images
```
结果
```shell
    REPOSITORY                      TAG           IMAGE ID       CREATED       SIZE
    mynginx                         v1.0          62d49f9bab67   2 weeks ago   133MB
    nginx                           latest        62d49f9bab67   2 weeks ago   133MB
```
#### 创建docker容器
```shell
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

OPTIONS说明
```txt
    -a stdin: 指定标准输入输出内容类型，可选 STDIN/STDOUT/STDERR 三项；
    -d: 后台运行容器，并返回容器ID；
    -i: 以交互模式运行容器，通常与 -t 同时使用；
    -P: 随机端口映射，容器内部端口随机映射到主机的端口
    -p: 指定端口映射，格式为：主机(宿主)端口:容器端口
    -t: 为容器重新分配一个伪输入终端，通常与 -i 同时使用；
    --name="nginx-lb": 为容器指定一个名称；
    --dns 8.8.8.8: 指定容器使用的DNS服务器，默认和宿主一致；
    --dns-search example.com: 指定容器DNS搜索域名，默认和宿主一致；
    -h "mars": 指定容器的hostname；
    -e username="ritchie": 设置环境变量；
    --env-file=[]: 从指定文件读入环境变量；
    --cpuset="0-2" or --cpuset="0,1,2": 绑定容器到指定CPU运行；
    -m :设置容器使用内存最大值；
    --net="bridge": 指定容器的网络连接类型，支持 bridge/host/none/container: 四种类型；
    --link=[]: 添加链接到另一个容器；
    --expose=[]: 开放一个端口或一组端口；
    --volume , -v: 绑定一个卷
    --privileged容器将拥有访问主机所有设备的权限
```
通常情况下 [command] 填下/bin/bash即可。

特殊情况下，如需要在centos镜像中使用systemctl. 则应添加--privileged并设置[command ]为init（有时候启动不了，不是必须情况不要使用）

运行（一般将配置文件和数据通过-v参数映射到宿主机）
```shell
    sudo docker run -d --name mynginx -p 9292:80 -v /data/mynginx:/data  nginx:latest


# 需要提前把配置文件拷贝到宿主机
    docker run -d --name nginx -p 80:80 -v /data/nginx/conf:/etc/nginx  -v /data/nginx/html:/usr/share/nginx/html  nginx:latest
    
```
结果
```shell
    sudo docker ps -a
    
    CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
    1b55ff302630   nginx:latest   "/docker-entrypoint.…"   7 seconds ago   Up 6 seconds   0.0.0.0:9292->80/tcp, :::9292->80/tcp   mynginx

```

#### 查看运行中的所有容器
```shell
    docker ps -a # -a 列出所有容器，不加-a只列出运行中的容器
```
运行
```shell
    sudo docker ps -a
```
结果
```shell
    CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
    1b55ff302630   nginx:latest   "/docker-entrypoint.…"   7 seconds ago   Up 6 seconds   0.0.0.0:9292->80/tcp, :::9292->80/tcp   mynginx
```
#### 启动/停止已部署的容器服务
```shell
    docker start/stop
```
运行停止
```shell
    sudo docker stop 1b55ff302630
```
结果
```shell
    1b55ff302630
    [lin@VM-0-6-centos ~]$ sudo docker ps -a
    CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                     PORTS     NAMES
    1b55ff302630   nginx:latest   "/docker-entrypoint.…"   2 minutes ago   Exited (0) 2 seconds ago             mynginx
```
运行启动
```shell
    sudo docker start 1b55ff302630
```
结果
```shell
    1b55ff302630
    [lin@VM-0-6-centos ~]$ sudo docker ps -a
    CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
    1b55ff302630   nginx:latest   "/docker-entrypoint.…"   3 minutes ago   Up 6 seconds   0.0.0.0:9292->80/tcp, :::9292->80/tcp   mynginx
```

#### 将宿主机内的指定文件传输至容器内部的指定地址
```shell
    docker cp [YourHostFilePath] [containerID]:[DockerPath]

```
运行
```shell
    sudo docker cp 1.txt 8b7640995472:/home/
```
结果
```shell
    sudo docker exec -it 8b7640995472  /bin/bash
    root@8b7640995472:/# ls /home/
    1.txt
```
#### 进入容器的终端交互模式
当镜像通过run 启动后，便会载入到一个动态的container(容器)中运行，此时若需要进入终端交互模式：
```shell
    sudo docker exec -it [containerID] /bin/bash
```
运行
```shell
    sudo docker exec -it 8b7640995472  /bin/bash
```
结果
```shell
    root@8b7640995472:/# ls
    bin   data  docker-entrypoint.d   etc   lib    media  opt   root  sbin  sys  usr
    boot  dev   docker-entrypoint.sh  home  lib64  mnt    proc  run   srv   tmp  var
```

 exit命令退出容器

#### 镜像制作（将修改后的容器重新打包成镜像）
```shell
    docker commit [containerID] [ImageName]:[Version]
```
运行
```shell
    sudo docker commit -a "lin" -m "my nginx" 8b7640995472 mynginx:v1.0
```
结果

```shell    sha256:3ec26d6717bd9f0e9db84867056fc932841a39ebd8d9ef36b70cb2eee2f90bc9
    [lin@VM-0-6-centos ~]$ sudo docker images
    REPOSITORY                      TAG           IMAGE ID       CREATED         SIZE
    mynginx                         v1.0          3ec26d6717bd   2 seconds ago   133MB
```
参数说明

    -a :提交的镜像作者；
    -c:使用Dockerfile指令来创建镜像；
    -m:提交时的说明文字；
    -p:在commit时，将容器暂停。

#### 提交镜像到云仓库
```shell
    docker push [ImageID] [repertory_address]
```
#### 删除容器
```shell
    docker rm [containerID]
```
运行
```shell
    sudo docker rm 1b55ff302630
```
结果（运行中的容器不能直接删除，需要加参数-f）
```shell
    Error response from daemon: You cannot remove a running container 1b55ff30263004803caeb1d44a1baf89e3747b574ae644d6e96156b7c972dc10. Stop the container before attempting removal or force remove
```
运行
```shell
    [lin@VM-0-6-centos ~]$ sudo docker rm 1b55ff302630 -f
```
结果
```shell
    1b55ff302630
    [lin@VM-0-6-centos ~]$ sudo docker ps -a
    CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
#### 删除镜像
```shell
    docker rmi [imageID]
```
运行前
```shell
    [lin@VM-0-6-centos ~]$ sudo docker images
    REPOSITORY                      TAG           IMAGE ID       CREATED       SIZE
    mynginx                         v1.0          62d49f9bab67   2 weeks ago   133MB
    nginx                           latest        62d49f9bab67   2 weeks ago   133MB
```
运行
```shell
    sudo docker rmi 62d49f9bab67
```
结果（tag过image id有重复的情况下出现下面错误）
```shell
    Error response from daemon: conflict: unable to delete 62d49f9bab67 (must be forced) - image is referenced in multiple repositories
```
解决方案:

- 通过镜像名称和tag删除
```shell

    sudo docker rmi mynginx:v1.0
    
    Untagged: mynginx:v1.0
```
- 通过加-f参数强制删除
```shell

    sudo docker rmi -f 62d49f9bab67
    
    Untagged: mynginx:v1.0
    Untagged: nginx:latest
    Untagged: nginx@sha256:75a55d33ecc73c2a242450a9f1cc858499d468f077ea942867e662c247b5e412
    Deleted: sha256:62d49f9bab67f7c70ac3395855bf01389eb3175b374e621f6f191bf31b54cd5b
    Deleted: sha256:3444fb58dc9e8338f6da71c1040e8ff532f25fab497312f95dcee0f756788a84
    Deleted: sha256:f85cfdc7ca97d8856cd4fa916053084e2e31c7e53ed169577cef5cb1b8169ccb
    Deleted: sha256:704bf100d7f16255a2bc92e925f7007eef0bd3947af4b860a38aaffc3f992eae
    Deleted: sha256:d5955c2e658d1432abb023d7d6d1128b0aa12481b976de7cbde4c7a31310f29b
    Deleted: sha256:11126fda59f7f4bf9bf08b9d24c9ea45a1194f3d61ae2a96af744c97eae71cbf
    Deleted: sha256:7e718b9c0c8c2e6420fe9c4d1d551088e314fe923dce4b2caf75891d82fb227d
```


### 15、docker-compose相关命令 

构建建启动nignx容器
```shell
    docker-compose up -d nginx
```
登录到nginx容器中
```shell
    docker-compose exec nginx bash
```
删除所有nginx容器,镜像
```shell
    docker-compose down
```
显示所有容器
```shell
    docker-compose ps
```
重新启动nginx容器
```shell
    docker-compose restart nginx
```
在php-fpm中不启动关联容器，并容器执行php -v 执行完成后删除容器
```shell
    docker-compose run --no-deps --rm php-fpm php -v  
```
构建镜像 
```shell
    docker-compose build nginx
```
不带缓存的构
```shell
    docker-compose build --no-cache nginx
```
查看nginx的日志 
```shell
    docker-compose logs  nginx
```
查看nginx的实时日志
```shell
    docker-compose logs -f nginx                   
```
验证（docker-compose.yml）文件配置，当配置正确时，不输出任何内容，当文件配置错误，输出错误信息
```shell
    docker-compose config  -q
```
以json的形式输出nginx的docker日志
```shell
    docker-compose events --json nginx       
```
暂停nignx容器
```shell
    docker-compose pause nginx
```
恢复ningx容器
```shell
    docker-compose unpause nginx
```
删除容器（删除前必须关闭容器）
```shell
    docker-compose rm nginx   
```
停止nignx容器
```shell
    docker-compose stop nginx
```
启动nignx容器
```shell
    docker-compose start nginx
```
### 参考
```txt
docker命令

https://www.runoob.com/docker/docker-command-manual.html

docker命令行大全详解（更新中）

https://blog.csdn.net/talkxin/article/details/83061973

Docker入门（一）

https://blog.csdn.net/miss1181248983/article/details/82705183

Docker入门（二）

https://blog.csdn.net/miss1181248983/article/details/82774115

docker-compose教程（安装，使用, 快速入门）

https://blog.csdn.net/pushiqiang/article/details/78682323
```