## gitlab通过dokcer部署
## 一、docker方式部署
### 1、配置centos环境
参照：centos7基础配置
### 2、部署docker和docker compose环境
参照：docker环境部署
### 3、通过docker运行gitlab
```shell
# 官方
docker run -d  -p 443:443 -p 80:80 -p 9022:22 --name gitlab --restart always -v /data/gitlab/config:/etc/gitlab -v /data/gitlab/logs:/var/log/gitlab -v /data/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce
```


```shell
# 极狐
export GITLAB_HOME=/data/gitlab

docker run --detach \
  --hostname 10.30.211.195 \
  --publish 8443:443 --publish 8080:80 --publish 8022:22 \
  --name gitlabjh \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab-jh.tencentcloudcr.com/omnibus/gitlab-jh:latest
```





-d：后台运行
-p：将容器内部端口向外映射
--name：命名容器名称
-v：将容器内数据文件夹或者日志、配置等文件夹挂载到宿主机指定目录	

```txt
# 查看初始密码
cat /data/gitlab/config/initial_root_password
```



## 二、手工部署
如果你要汉化，先看汉化版本再决定安装哪个版本的gitlab-ce
### 1、安装相关依赖
```shell
yum -y install policycoreutils openssh-server openssh-clients postfix
```
### 2、设置pistfix开机自启(支持gitlab发信功能)
```shell
systemctl enable postfix 
systemctl start postfix
```
### 3、gitlab-ce 安装
```shell
1、下载安装包
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-12.3.9-ce.0.el7.x86_64.rpm
2、安装
 rpm -ivh gitlab-ce-12.3.9-ce.0.el7.x86_64.rpm
```
安装成功后调整配置
```shell
vi  /etc/gitlab/gitlab.rb

external_url 'http://gitlab.example.com' 改为自己的http://ip:端口(nginx的端口)
unicorn['port'] 修改端口(gitlab服务的端口，可以不设置)
注意:这两个端口不能相同，否者会显示502端口被占用
```
```txt
###网址和端口调整
## GitLab URL
##! URL on which GitLab will be reachable.
##! For more details on configuring external_url see:
##! https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-the-external-url-for-gitlab
external_url 'http://10.30.211.181'


###修改存放数据路径

### For setting up different data storing directory
###! Docs: https://docs.gitlab.com/omnibus/settings/configuration.html#storing-git-data-in-an-alternative-directory
###! **If you want to use a single non-default directory to store git data use a
###!   path that doesn't contain symlinks.**
git_data_dirs({
   "default" => {
     "path" => "/data/gitlab_data"
    }
})

```
### 4、使用gitlab-ce自动配置初始化相关信息
```shell
 配置
gitlab-ctl reconfigure
 启动
gitlab-ctl start
 停止
gitlab-ctl stop
 重启
gitlab-ctl restart
查看日志
gitlab-ctl tail
```
### 5、访问
```shell
首次访问修改密码
http://ip:port/
```

### 6、汉化

#### 6.1、备份之前的gitlab文件
```shell
cp -rp /opt/gitlab/embedded/service/gitlab-rails{,.bak_$(date +%F)}
```
#### 6.2、下载汉化包
```shell
wget https://gitlab.com/xhang/gitlab/-/archive/12-3-stable-zh/gitlab-12-3-stable-zh.tar.gz
```
#### 6.3、把汉化包覆盖过去
```shell
1、解压
 tar -zxvf gitlab-12-3-stable-zh.tar.gz
2、拷贝汉化包（\cp 不会提示覆盖）
 \cp -rf /data/gitlab-12-3-stable-zh/* /opt/gitlab/embedded/service/gitlab-rails/
```

#### 6.4、重新编译重启
```shell
gitlab-ctl reconfigure
gitlab-ctl start
```
#### 6.5、完成

如果你发现点进去之后还是英文,在设置里面有个语言选择简体中文即可

### 6.6、配置

```txt
1、配置钩子
root账号登录-【管理中心】-【设置】-【网络】-【外发请求】中下面两条全部勾选，否则添加web钩子的时候提示错误
Allow requests to the local network from web hooks and services
Allow requests to the local network from system hooks
2、
```





## 三、备注
```txt
#docker
https://blog.csdn.net/yanglinna/article/details/104293436/
#rpm 安装及汉化（版本：12.3）
https://blog.csdn.net/u014338913/article/details/108195717
```

