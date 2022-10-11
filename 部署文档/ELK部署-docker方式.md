
## 一、elasticsearch部署

### 1、拉取镜像
    docker pull elasticsearch:7.12.1

### 2、创建宿主机文件路径
    mkdir -p /data/elasticsearch/config
    mkdir -p /data/elasticsearch/data
    mkdir -p /data/elasticsearch/logs
    mkdir -p /data/elasticsearch/plugins
    # 给予权限（有时候权限不足运行会报错）
    chmod 777 -R /data/elasticsearch
    
### 3、编辑配置文件

    vi /data/elasticsearch/config/elasticsearch.yml
配置文件内容


    cluster.name: "docker-cluster"
    network.host: 0.0.0.0
    http.cors.enabled: true
    http.cors.allow-origin: "*"

### 4、运行docker实例
    docker run -d --name elasticsearch --restart=always -p 9200:9200 -p 9300:9300  -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx128m" -v /data/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /data/elasticsearch/data:/usr/share/elasticsearch/data -v /data/elasticsearch/plugins:/usr/share/elasticsearch/plugins -v /data/elasticsearch/logs:/usr/share/elasticsearch/logs elasticsearch:7.12.1
    
参数解析

discovery.type=single-node为单实例运行
    
### 5、验证es是否正常
查看实例是否正常

    docker ps  -a
访问连接

    http://122.152.218.235:9200/
    
正确显示

    {
      "name" : "5fa8ae6a746d",
      "cluster_name" : "docker-cluster",
      "cluster_uuid" : "6381LYBCQF2RwTIo-hi8jA",
      "version" : {
        "number" : "7.12.1",
        "build_flavor" : "default",
        "build_type" : "docker",
        "build_hash" : "3186837139b9c6b6d23c3200870651f10d3343b7",
        "build_date" : "2021-04-20T20:56:39.040728659Z",
        "build_snapshot" : false,
        "lucene_version" : "8.8.0",
        "minimum_wire_compatibility_version" : "6.8.0",
        "minimum_index_compatibility_version" : "6.0.0-beta1"
      },
      "tagline" : "You Know, for Search"
    }

### 5、es可视化工具

#### 拉取镜像

    docker pull mobz/elasticsearch-head:5
#### 运行实例
    docker run -d --name=elasticsearch-head --restart=always -p 9100:9100 mobz/elasticsearch-head:5
    
#### 查看是否安装正常

查看实例是否正常

    docker ps  -a
访问连接

    http://122.152.218.235:9100/

通常这个时候并没有数据，只能看到默认主页

##### 备选方案（目前测试效果一样）

    docker pull mobz/elasticsearch-head:5-alpine
    
    docker run -d  --name=elasticsearch-head  --restart=always  -p 9100:9100  docker.io/mobz/elasticsearch-head:5-alpine


## 二、安装logstash

### 1、拉取镜像
    docker pull logstash:7.12.1

### 2、启动logstash实例
    docker run -d --name=logstash logstash:7.12.1
    
等待30秒，查看日志

    docker logs -f logstash

如果出现以下信息，说明启动成功。

    [2021-05-18T15:12:01,224][INFO ][org.logstash.beats.Server] Starting server on port: 5044
    

### 3、拷贝数据，授予权限

从实例中拷贝logstash的文件

    docker cp logstash:/usr/share/logstash /data/
创建配置文件路径

    mkdir /data/logstash/config/conf.d
分配权限（有时候权限不足运行会报错）

    chmod 777 -R /data/logstash
 

### 4、修改logstash配置文件
修改配置文件中的elasticsearch地址

    vi /data/logstash/config/logstash.yml
完整内容如下：

    http.host: "0.0.0.0"
    xpack.monitoring.elasticsearch.hosts: ["http://172.17.0.6:9200"]
    path.config: /usr/share/logstash/config/conf.d/*.conf
    path.logs: /usr/share/logstash/logs


根据实际情况修改elasticsearch地址

 
### 4、添加logstash收集日志的配置文件
新建文件syslog.conf，用来收集/var/log/messages

    vi /data/logstash/config/conf.d/syslog.conf
 
完整内容如下：

    input {
      file {
        #标签
        type => "systemlog-localhost"
        #采集点
        path => "/var/log/messages"
        #开始收集点
        start_position => "beginning"
        #扫描间隔时间，默认是1s，建议5s
        stat_interval => "5"
      }
    }
    
    output {
      elasticsearch {
        hosts => ["172.17.0.6:9200"]
        index => "logstash-system-localhost-%{+YYYY.MM.dd}"
     }
    }

根据实际情况修改elasticsearch地址

 
### 5、设置日志文件读取权限

    chmod 644 /var/log/messages
    chmod 777 -R /data/logstash

### 6、重新启动logstash实例

删除上面创建的没有映射宿主文件的实例

    docker rm -f logstash

运行新的logstash实例

    docker run -d  --name=logstash  --restart=always  -p 5044:5044   -v /data/logstash:/usr/share/logstash  -v /var/log/messages:/var/log/messages  logstash:7.12.1


### 7、重启完成之后，访问elasticsearch-head

    http://122.152.218.235:9100/


## 三、kibana部署

### 1、拉取镜像
docker pull kibana:7.12.1
### 2、创建配置文件
    vi /data/kibana/config/kibana.yml

完整配置内容：

    #
    # ** THIS IS AN AUTO-GENERATED FILE **
    #
    
    # Default Kibana configuration for docker target
    server.name: kibana
    server.host: "0"
    elasticsearch.hosts: [ "http://172.17.0.6:9200" ]
    xpack.monitoring.ui.container.elasticsearch.enabled: true
    i18n.locale: "zh-CN"

### 3、运行实例

    docker run -d  --name=kibana --restart=always  -p 5601:5601  -v /data/kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml kibana:7.12.1

### 4、查看是否安装正常

查看实例是否正常

    docker ps  -a
访问连接

    http://122.152.218.235:5601/

通常这个时候并没有数据，只能看到默认主页

### 5、通过创建索引模式展示日志数据
数据为logstash获取的日志文件

- 点击左侧菜单[Discover]
- 进入页面后，点击左侧[kibana]菜单下的[索引模式]
- 进入页面后，点击[创建 索引模式]，输入[logstash-system-localhost-*],点击下一步
- 进入页面后，点击[事件字段]选择[@timestamp],点击[创建索引模式]
- 再次点击[Discover]菜单，可以查看效果



#### 参考网址
docker安装kibana

https://blog.csdn.net/shykevin/article/details/108272260

 Elastic 中国社区官方博客
 
https://elasticstack.blog.csdn.net/

ELK日志分析系统，概述及部署

https://blog.csdn.net/Jun____________/article/details/116693522


#### 补充docker知识

在使用docker容器时，有时候里边没有安装vim，敲vim命令时提示

    vim: command not found

需要自行安装vim

    # 同步 /etc/apt/sources.list 和 /etc/apt/sources.list.d 中列出的源的索引
    apt-get update
    
    # 安装vim
    apt-get install -y vim


