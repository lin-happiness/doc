## CentOS7安装java
### 1、java安装包下载
    通过oracle下载后上传

### 2、安装包解压
    sudo tar -xf jdk-8u291-linux-x64.tar.gz -C /usr/local/
    sudo mv /usr/local/jdk1.8.0_291/ /usr/local/java8
    

### 3、maven加入环境变量
在/etc/profile文件最下方加入新的一行export

    sudo vi /etc/profile
    添加内容
    export JAVA_HOME=/usr/local/java8
    export JRE_HOME=$JAVA_HOME/jre
    export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
    export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

    配置生效
    source /etc/profile

### 4、配置生效验证
    which java
显示/usr/local/java8/bin/java就说明配置成功了

### 5、yum安装jdk方式
OpenJDK不包含Deployment（部署）功能：部署的功能包括：Browser Plugin、Java Web Start、以及Java控制面板，所以java项目尽量不要使用openjdk，可能存在未知问题。

    sudo yum -y install java-1.8.0-openjdk
    
删除openjdk

    rpm -qa | grep jdk

可以获取openjdk的版本信息,分别执行下面操作进行删除

    sudo yum -y remove java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64
    sudo yum -y remove java-1.8.0-openjdk-headless-1.8.0.292.b10-1.el7_9.x86_64
