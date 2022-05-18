# jenkins部署方式

### 1、通过yum安装（推荐）
```shell
    sudo wget -O /etc/yum.repos.d/jenkins.repo  https://pkg.jenkins.io/redhat/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    sudo yum upgrade
    sudo yum clean all
    sudo yum makecache
    sudo yum install jenkins java-1.8.0-openjdk
    sudo systemctl daemon-reload

    #如果java环境是手动部署的（参考java部署文档），需要再/usr/bin下创建java的软连接
    #ln -s /usr/local/java8/bin/java /usr/bin/java
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
```
#### 1.1 查看jenkins相关目录：
```shell
    sudo rpm -ql jenkins #查看jenkins安装相关目录
    进入安装目录
    cd /var/lib/jenkins
```
#### 1.2 更新jenkins配置
```shell
	sudo vi /var/lib/jenkins/hudson.model.UpdateCenter.xml
```
修改后
```shell
	<?xml version='1.1' encoding='UTF-8'?>
	<sites>
	  <site>
	    <id>default</id>
	    <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url>   #改为国内的网站
	  </site>
	</sites>
```
#### 1.3 配置下载插件加速
```shell
	cd /var/lib/jenkins/updates
```
通过命令修改default.json文件
```shell
	sudo sed -i 's/https:\/\/updates.jenkins.io\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json
	sudo sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json
```
#### 1.4 重启jenkins服务
```shell
    sudo systemctl  restart jenkins
```
#### 1.5 打开jenkins页面
```shell
    http://IP:8080
```
#### 1.6 登录页面提示初始密码获得位置，通过cat命令查看密码
```shell
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
#### 1.7 插件安装选择
插件选择“安装推荐的插件”，进入系统后可以根据需要自行安装其他插件

#### 1.8 默认汉化不完全问题处理
登录后进入【系统管理】【插件管理】【可选插件】查询local安装对应语言插件，需要选择安装后重启。

#### 1.9 修改密码
登录后在右上角用户名（使用管理员登录，用户名是admin）下拉中选择【设置】，可以设置密码  chenghai/linlefu  
#### 1.10 安装git
```shell
    sudo yum install git -y
```
#### 1.11 安装maven
参考maven部署文档




### 2、通过rpm文件安装    
#### 部署java
```shell
    sudo yum -y install java-1.8.0
```
#### 部署jenkins
```shell
    sudo chmod 755 jenkins-2.277.3-1.1.noarch.rpm
    sudo rpm -ivh jenkins-2.277.3-1.1.noarch.rpm
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
```
#### 配置jenkins
配置参考 1.1--1.10


### 3、使用war方式安装
下载war包安装
```shell
    sudo yum install -y java-1.8.0 
    sudo mkdir -p /usr/local/jenkins/ 
    sudo wget -c -O /usr/local/jenkins/jenkins.war http://mirrors.jenkins.io/war-stable/2.277.3/jenkins.war 
    sudo nohup java -jar /usr/local/jenkins/jenkins.war 
```
#### 配置jenkins
配置参考 1.1--1.10

### 4、docker部署(有问题 暂时不建议使用)
#### 拉取镜像
```shell
    sudo docker pull jenkins/jenkins:lts-centos7
```
#### 创建实例
```shell
    sudo docker run -d  --name jenkins --restart=always -u root -p 8080:8080  -v /var/jenkins_home:/var/jenkins_home jenkins/jenkins:lts-centos7

# docker run -d -p 10240:8080 -p 10241:50000 -v /var/jenkins_mount:/var/jenkins_home -v /opt/apache-maven-3.6.3:/usr/local/maven -v /etc/localtime:/etc/localtime --name myjenkins jenkins/jenkins

```
注意：启动时候，提示：该jenkins实例似乎已离线，需要修改配置

##### 4.1 更新jenkins配置
```shell
	sudo vi /var/jenkins_home/hudson.model.UpdateCenter.xml
```
修改后
```shell
	<?xml version='1.1' encoding='UTF-8'?>
	<sites>
	  <site>
	    <id>default</id>
	    <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url>   #改为国内的网站
	  </site>
	</sites>
```
##### 4.2 配置下载插件加速
```shell
	cd /var/jenkins_home/updates
```
通过命令修改default.json文件
```shell
	sudo sed -i 's/https:\/\/updates.jenkins.io\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json
	sudo sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json
```
##### 4.3 重启jenkins(jenkins为docker实例的name ，通过sudo docker ps -a查看)
```shell
	sudo docker restart jenkins
```
##### 4.4 登录
#### 查看管理员密码
```shell
	sudo cat /var/jenkins_home/secrets/initialAdminPassword
```
#### 插件选择“安装推荐的插件”，进入系统后可以根据需要自行安装其他插件

#### 4.5 其他
##### 4.5.1、进入容器内
```shell
sudo docker exec -i -t  jk /bin/bash
```
##### 4.5.2、安装插件

```txt
gitlab、Generic Webhook Trigger、Build Authorization Token、Maven Integration、BlueOcean
```

##### 4.5.3、配置gilab回调

```txt
1、勾选：Build when a change is pushed to GitLab. GitLab webhook URL: http://10.30.211.182:8080/project/test
2、选择【高级】，生成【Secret token】
3、将回调地址和token填写到gitlab对应项目的web钩子中（【设置】-【集成】）
```

##### 4.5.4配置ssh登录目标主机

```txt
1、使用jenkins的情况
#查看用户
[root@jenkins ~]# grep jenkins /etc/passwd
jenkins:x:997:995:Jenkins Automation Server:/var/lib/jenkins:/bin/false
# 切换
[root@jenkins ~]# su -s /bin/bash jenkins
# 生成jenkins的秘钥
bash-4.2$ ssh-keygen -o
# 将公钥推送给目标主机
bash-4.2$ ssh-copy-id root@10.30.211.183
#获得私钥
bash-4.2$ cat /var/lib/jenkins/.ssh/id_rsa

#将私钥配置到jenkins的凭证中
【添加凭证】-【SSH Username with private key】



```



### 参考

```txt
jenkins官网
https://www.jenkins.io/download/

jenkins安装包下载页面
http://mirrors.jenkins.io/redhat-stable/

jenkins详解
https://blog.csdn.net/qq_26848099/article/details/78901240

Jenkins的安装及中文展示、安装插件创建一个关联shell的任务
https://blog.csdn.net/yeyslspi59/article/details/107345085

Jenkins详细教程
https://www.jianshu.com/p/5f671aca2b5a

Gitlab+Jenkins+Docker+项目、实现一套完整的自动化上线服务
https://blog.csdn.net/yeyslspi59/article/details/108926990

gitlab+jenkins+harbor自动化打包部署maven项目
https://blog.51cto.com/u_14048416/2376850

https://www.dklwj.com/?id=51

https://www.jianshu.com/p/eeb15a408d88

https://www.cnblogs.com/topicjie/p/7107895.html

https://blog.csdn.net/zhangjunli/article/details/108436980
```

