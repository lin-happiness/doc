# 本地docker仓库harbor部署

## 1、下载离线安装文件（建议从github直接下载上传的服务器）
```shell
sudo wget https://github.com/goharbor/harbor/releases/download/v2.2.1/harbor-offline-installer-v2.2.1.tgz
```
## 2、解压安装包
```shell
sudo tar zxf harbor-offline-installer-v2.2.1.tgz
```
## 3、给予权限
```shell
sudo chmod 755  harbor
```
## 4、进入目录
```shell
cd harbor/
```
## 5、复制配置文件
```shell
sudo cp harbor.yml.tmpl harbor.yml
```
## 6、修改配置中的hostname，注释掉https，设置port、harbor_admin_password等个性化参数
```shell
sudo vi harbor.yml
```
修改内容
```txt
# Configuration file of Harbor

# The IP address or hostname to access admin UI and registry service.
# DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: 10.30.211.183

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 80

# https related config
#https:
  # https port for harbor, default is 443
 # port: 443
  # The path of cert and key files for nginx
  #certificate: /your/certificate/path
  #private_key: /your/private/key/path

# # Uncomment following will enable tls communication between all harbor components
# internal_tls:
#   # set enabled to true means internal tls is enabled
#   enabled: true
#   # put your cert and key files on dir
#   dir: /etc/harbor/tls/internal

# Uncomment external_url if you want to enable external proxy
# And when it enabled the hostname will no longer used
# external_url: https://reg.mydomain.com:8433

# The initial password of Harbor admin
# It only works in first time to install harbor
# Remember Change the admin password from UI after launching Harbor.
harbor_admin_password: P@ssw0rd

```

## 7、安装
```shell
sudo sh ./prepare
sudo sh ./install.sh
```
## 8、查看harbor的实例运行情况
```shell
sudo docker ps -a
```
## 9、访问harbor
```txt
http://10.30.211.183   admin/P@ssw0rd
```
## 11、测试

```shell
换一台安装过docker的服务器

#配置http镜像仓库可信任
vim /etc/docker/daemon.json
添加

{"insecure-registries": ["10.30.211.183"]}

#登录仓库
docker login 10.30.211.183 -uadmin -pP@ssw0rd

[root@localhost ~]# docker login 10.30.211.183 -uadmin -pP@ssw0rd
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded


#现在下载一个镜像nginx
docker pull nginx

#给镜像打tag
docker tag nginx:latest 10.30.211.183/chenghai/nginx

#上传镜像
docker push 10.30.211.183/chenghai/nginx

#再通过浏览器查看上传的镜像

```



## 11、其他
### 1）、docker-compose相关命令（需要再harbor目录下执行）
```shell
	删除实例
	sudo docker-compose down -v
	创建实例
	sudo docker-compose up -d
	停止实例
	sudo docker-compose stop
	启动实例
	sudo docker-compose start
	重启实例（不要使用，部分实例无法正常启动）
	sudo docker-compose restart
	查看实例
	sudo docker-compose ps
```
### 2）、参考
```txt
Harbor的github地址
https://github.com/goharbor/harbor

docker部署安装harbor 
https://www.cnblogs.com/caibao666/p/12661389.html
```