## CentOS7安装maven
### 1、maven安装包下载
    sudo wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz

### 2、安装包解压
    sudo tar -xf apache-maven-3.6.3-bin.tar.gz -C /usr/local/
    sudo mv /usr/local/apache-maven-3.6.3/ /usr/local/maven3.6
    sudo chmod 755 -R /usr/local/maven3.6

### 3、maven加入环境变量
在/etc/profile文件最下方加入新的一行export

    sudo vi /etc/profile
    添加内容
    PATH=$PATH:/usr/local/maven3.6/bin
    配置生效
    source /etc/profile

### 4、配置生效验证
    which mvn
显示/usr/local/maven3.6/bin/mvn就说明配置成功了

### 5、JAVA环境
运行maven需要Java环境----系统安装有jdk，并且在系统中配置了JAVA_HOME。