## redmine 部署
### 1、配置centos环境
参照：centos7基础配置
### 2、部署docker和docker compose环境
参照：docker环境部署
### 3、创建文件夹
    mkdir compose
### 4、配置docker-compose.yml文件
    vi docker-compose.yml
    
配置文件代码
    version: '2'
    
    services:
      mysql:
        image: sameersbn/mysql:5.7.22-1
        environment:
        - DB_USER=redmine
        - DB_PASS=abc.123
        - DB_NAME=redmine_production
        volumes:
        - /redmine/mysql:/var/lib/mysql
    
      redmine:
        image: sameersbn/redmine:4.1.1-8
        depends_on:
        - mysql
        environment:
        - TZ=Asia/Shanghai
    
        - DB_ADAPTER=mysql2
        - DB_HOST=mysql
        - DB_PORT=3306
        - DB_USER=redmine
        - DB_PASS=abc.123
        - DB_NAME=redmine_production
    
        - REDMINE_PORT=80
        - REDMINE_HTTPS=false
        - REDMINE_RELATIVE_URL_ROOT=
        - REDMINE_SECRET_TOKEN=
    
        - REDMINE_SUDO_MODE_ENABLED=false
        - REDMINE_SUDO_MODE_TIMEOUT=15
    
        - REDMINE_CONCURRENT_UPLOADS=5
    
        ports:
        - "80:80"
        volumes:
        - /redmine/redmine_data:/home/redmine/data
        - /redmine/redmine_logs:/var/log/redmine



### 5、通过docker-compose启动docker实例
    docker-compose up -d
