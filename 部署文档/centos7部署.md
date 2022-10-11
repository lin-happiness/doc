## 部署准备
### 1、linux更新
	命令：yum update -y
### 2、调整防火墙，腾讯云默认防火墙是关闭状态，打开端口根据业务需要调整

开启防火墙 

	systemctl start firewalld

开启添加80,443端口 

	firewall-cmd --zone=public --add-port=80/tcp --permanent
	firewall-cmd --zone=public --add-port=443/tcp --permanent

重新载入配置

	firewall-cmd --reload
查看防火墙端口配置情况

	firewall-cmd --zone=public --list-ports
删除端口

	firewall-cmd --zone=public --remove-port=80/tcp --permanent

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


添加端口只对部分IP开放（选配）

    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.10.21" port protocol="tcp" port="3306" accept'
使上面配置生效

    firewall-cmd --reload
查看当前配置信息

    firewall-cmd --list-all

去除端口只对部分IP开放

    firewall-cmd --permanent --remove-rich-rule='rule family="ipv4" source address="10.30.16.29" port protocol="tcp" port="3306" accept'


### 3、安装htop iftop iotop lsof
	yum install -y epel-release htop iftop iotop lsof nlode

### 4、应授各管理予用户所需的最小权限；	不符合要求	使用root账户进行登录管理操作；默认umask权限不符合要求。
	vi /etc/bashrc
	source /etc/bashrc
	vi /etc/profile
	source /etc/profile

代码示例

    #/usr/share/doc/setup-*/uidgid file
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 002
    else
       umask 022
    fi

修改为
	
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 027
    else
       umask 027
    fi
#### 注意：ubuntu18特殊性
需要再文件/etc/profile.d/bash_completion.sh中添加umask 027 才能通过腾讯基线检测

### 5、设置登录超时自动退出功能
编辑/etc/bashrc和/etc/profile文件（以及系统上支持的任何其他Shell的适当文件），并添加或编辑任何umask参数

	vi /etc/bashrc
	vi /etc/profile

其中300表示超过300秒无操作即断开连接

	TMOUT=300

刷新bashrc,profile

	source /etc/bashrc
	source /etc/profile

### 6、空口令账户设置
禁止SSH空密码用户登录
编辑文件/etc/ssh/sshd_config，将PermitEmptyPasswords配置为no:

	vi /etc/ssh/sshd_config

重启ssh

	systemctl restart sshd

其他调整
	
	vi /etc/ssh/sshd_config
	
	ClientAliveInterval 300
	ClientAliveCountMax 0
	MaxAuthTries 4 
重启ssh

	systemctl restart sshd

### 7、创建操作用户
创建组

	groupadd chenghai
创建用户

	useradd -g chenghai chenghai
设置密码

	passwd chenghai

sudo命令的授权管理

	ls -l /etc/sudoers
	
	-r--r----- 1 root root 4328 Sep 30  2020 /etc/sudoers
只有只读的权限，如果想要修改的话，需要先添加w权限

	chmod -v u+w /etc/sudoers
	
	mode of "/etc/sudoers" changed from 0440 (r--r-----) to 0640 (rw-r-----) 
然后就可以添加内容了，在下面的一行下追加新增的用户

	vi /etc/sudoers
	 
	## Allow root to run any commands anywher  
	root    ALL=(ALL)       ALL  
	chenghai  ALL=(ALL)       ALL  #这个是新增的用户

wq保存退出。
	
将写权限收回。

	chmod -v u-w /etc/sudoers
	
	mode of "/etc/sudoers" changed from 0640 (rw-r-----) to 0440 (r--r-----) 

新用户登录，使用sudo：

	sudo cat /etc/passwd
	
	We trust you have received the usual lecture from the local System
	Administrator. It usually boils down to these three things:
	#1) Respect the privacy of others. 
	#2) Think before you type. 
	#3) With great power comes great responsibility. 

### 8、密码错误锁定账号设置
编辑/etc/pam.d/password-auth 和/etc/pam.d/system-auth 文件，以符合本地站点策略：
	
	auth required pam_faillock.so preauth audit silent deny=5 unlock_time=900
	auth [success=1 default=bad] pam_unix.so
	auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900
	auth sufficient pam_faillock.so authsucc audit deny=5 unlock_time=900

### 9、其他命令汇总
查看端口使用情况
    
    # 安装
    yum install net-tools
    # 查看全部端口
    netstat -natp
    # 查看8080端口
    netstat -natp | grep 8080

### 10、杀毒软件

#### 更新YUM源，yum安装clamav

    yum -y install epel-release
    
    yum install –y clamav clamav-update

#### 更新病毒库

    freshclam

#### 扫描病毒

    clamscan -ri / -l clamscan.log --remove     # 这里递归扫描根目录 / ，发现感染文件立即删除

- -r 递归扫面子文件 
- –i 只显示被感染的文件 
- -l 指定日志文件 
- --remove 删除被感染文件 
- --move隔离被感染文件



### 11、杀毒软件（安全狗）

```shell

  wget http://down.safedog.cn/safedog_linux64.tar.gz

  tar zxvf safedog_linux64.tar.gz

  cd safedog_an_linux64_2.8.21207/

  chmod +x *.py
 
  ./install.py
   setenforce 0
 
  vi /etc/selinux/config

  yum -y install mlocate
 
  yum install psmisc -y

  ./install.py
  
sdui
```

### 11、登录配置

    vi /etc/login.defs

