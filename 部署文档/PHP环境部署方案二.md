## 注意：lnmp一句话脚本可能和腾讯云服务器冲突导致cpu负载过大
# lnmp一句话脚本方式部署
## 1、升级操作系统从centos7.8升级到CentOS Linux release 7.9.2009 (Core)
	yum update -y
## 2、安装wget  腾讯云默认已安装
	yum install -y wget
## 3、部署php环境
	 wget http://soft.vpser.net/lnmp/lnmp1.7.tar.gz -cO lnmp1.7.tar.gz && tar zxf lnmp1.7.tar.gz && cd lnmp1.7 && ./install.sh lnmp
	 
运行提示

	+------------------------------------------------------------------------+
	|          LNMP V1.7 for CentOS Linux Server, Written by Licess          |
	+------------------------------------------------------------------------+
	|           For more information please visit https://lnmp.org           |
	+------------------------------------------------------------------------+
	|    lnmp status manage: lnmp {start|stop|reload|restart|kill|status}    |
	+------------------------------------------------------------------------+
	|  phpMyAdmin: http://IP/phpmyadmin/                                     |
	|  phpinfo: http://IP/phpinfo.php                                        |
	|  Prober:  http://IP/p.php                                              |
	+------------------------------------------------------------------------+
	|  Add VirtualHost: lnmp vhost add                                       |
	+------------------------------------------------------------------------+
	|  Default directory: /home/wwwroot/default                              |
	+------------------------------------------------------------------------+

## 4、安装ftp【最新正式环境未安装，调整部署结构，使用COS替换ftp】

	wget http://soft.vpser.net/lnmp/lnmp1.7.tar.gz -cO lnmp1.7.tar.gz && tar zxf lnmp1.7.tar.gz && cd lnmp1.7
	./pureftpd.sh
	
运行提示

	+------------------------------------------------------------------------+
	|  use command: lnmp ftp {add|list|del|show} to manage FTP users.        |
	+------------------------------------------------------------------------+

	Enter ftp account name: ai
	Enter password for ftp account ai: P@ssw0rd_chenghai
	Enter directory for ftp account ai: /home/www/

修改PureFTPd 的 FTP端口
修改默认的 21 端口相对会比较安全一点，如果Linux服务器用的是 Pureftpd 则修改端口号的方法如下

	vi /usr/local/pureftpd/etc/pure-ftpd.conf
	
找到
	
	# Bind 127.0.0.1,21
	
修改为
	
	Bind 0.0.0.0,2121
	
以上的 2121 即为新端口。
之后重启Pureftpd即可，如果用的是lnmp则执行以下命令。

	/etc/init.d/pureftpd restart


## 4、安装unoconv-office文档转成pdf【最新正式环境未安装，调整部署结构，使用COS的文档预览】
	
	yum install -y unoconv

安装是否成功

	unoconv --version
	
乱码处理  
在/usr/share/fonts/下新建文件夹 win 并设置权限【755】，将 windows 下的 C:\Windows\Fonts下字体全部拷贝到其中。然后创建索引并更新字体缓存	

## 5、调整防火墙，腾讯云默认防火墙是关闭状态，打开端口根据业务需要调整
	 
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

## 6、安装htop iftop iotop lsof

	yum install -y htop iftop iotop lsof
## 7、安装了unzip

	yum install unzip	
	
## 8、添加opcache ./addons.sh install opcache【影响PHP运行并发】
	
## N、更新ssh ssl【未处理，影响php环境安装】
由 OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017 升级到 OpenSSH_8.4p1, OpenSSL 1.1.1h  22 Sep 2020

脚本和离线安装包拷贝到root文件夹下，然后执行命令
	
	 chmod 777 openssh8.4.sh
	./openssh8.4.sh
	