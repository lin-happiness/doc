### 搭建NFS文件共享系统
#### 1、概述：
NFS(Network File System)意为网络文件系统，它最大的功能就是可以通过网络，让不同的机器不同的操作系统可以共享彼此的文件。

##### 1.1 准备
Centos7 服务器两台：
NFS服务器ip：10.30.211.112。
客户端ip：10.30.211.142。



#### 2、NFS服务器配置
##### 2.1 安装NFS服务
首先使用yum安装nfs服务：
```shell
yum -y install rpcbind nfs-utils
```
###### 2.1.1 创建共享目录
在服务器上创建共享目录，并设置权限。
```shell
mkdir /share/
chmod 755 -R /share/
```

##### 2.2 配置NFS
nfs的配置文件是 /etc/exports 

```shell
vi /etc/exports
# /etc/exports后在配置文件中加入一行
/share/ 10.30.211.142/22(rw,no_root_squash,no_all_squash,sync)
# 保存好配置文件后，需要执行以下命令使配置立即生效：
exportfs -r
```
```txt
这行代码的意思是把共享目录/share/共享给10.30.211.142这个客户端
注：客户端ip后需加上端口号，否则无法操作
ip 后面括号里的内容是权限参数，其中：
rw 表示设置目录可读写。
sync 表示数据会同步写入到内存和硬盘中，相反 rsync 表示数据会先暂存于内存中，而非直接写入到硬盘中。
no_root_squash NFS客户端连接服务端时如果使用的是root的话，那么对服务端分享的目录来说，也拥有root权限。
no_all_squash 不论NFS客户端连接服务端时使用什么用户，对服务端分享的目录来说都不会拥有匿名用户权限。
如果有多个共享目录配置，则使用多行，一行一个配置。
```

##### 2.3 设置防火墙
NFS的防火墙除了固定的port111、2049外，还有其他服务如rpc.mounted等开启的不固定的端口，因此我们需要设置NFS服务的端口配置文件。
```shell
vi /etc/sysconfig/nfs
# 将下列内容的注释去掉，如果没有则添加
RQUOTAD_PORT=1001
LOCKD_TCPPORT=30001
LOCKD_UDPPORT=30002
MOUNTD_PORT=1002

# 保存好后，将端口加入到防火墙允许策略中。执行：

firewall-cmd --zone=public --add-port=111/tcp --add-port=111/udp --add-port=2049/tcp --add-port=2049/udp --add-port=1001/tcp --add-port=1001/udp --add-port=1002/tcp --add-port=1002/udp --add-port=30001/tcp --add-port=30002/udp --permanent

firewall-cmd --reload
```

##### 2.4 启动服务

```shell
# 按顺序启动rpcbind和nfs服务：(此顺序不能颠倒，否则后续会报错)
systemctl start rpcbind
systemctl start nfs（centos7）
# systemctl start nfs-server（centos8）
# 加入开机启动：
systemctl enable rpcbind
systemctl enable nfs（centos7）
# systemctl enable nfs-server（centos8）

# nfs服务启动后，可以使用命令 rpcinfo -p 查看端口是否生效。
rpcinfo -p
# 我们可以使用 showmount 命令来查看服务端(本机)是否可连接,出现下面结果表明NFS服务端配置正常。

[root@localhost ~]# showmount -e localhost
Export list for localhost:
/share 10.30.211.142/22
```

#### 3、客户端配置
##### 3.1 安装rpcbind服务
客户端只需要安装rpcbind服务即可，一般无需安装nfs或开启nfs服务。
```shell
yum -y install rpcbind
```
##### 3.2 挂载远程nfs文件系统
```shell
# 查看服务端已共享的目录:
# 无法使用showmount命令则此步骤建议使用命令安装rpcbind、nfs-utils
# 因为有些虚拟机可能会内置showmount命令，同时若安装nfs，需确保与nfs服务器端版本一致
yum -y install rpcbind nfs-utils

showmount -e 10.30.211.112
# 出现下面结果表明NFS服务端配置正常
[root@localhost ~]# showmount -e 10.30.211.112
Export list for 10.30.211.112:
/share 10.30.211.142/22

# 建立挂载目录，执行挂载命令：
mkdir -p /mnt/share
#如果不加 -onolock,nfsvers=3 则在挂载目录下的文件属主和组都是nobody，如果指定nfsvers=3则显示root。
mount -t nfs 10.30.211.112:/share /mnt/share/ -o nolock,nfsvers=3,vers=3

#如果要解除挂载，可执行命令：
umount /share
```


##### 3.3 开机自动挂载
```shell
# 如果按本文上面的部分配置好，NFS即部署好了，但是如果你重启客户端系统，发现不能随机器一起挂载，需要再次手动操作挂载，这样操作比较麻烦，因此我们需要设置开机自动挂载。我们不要把挂载项写到/etc/fstab文件中，因为开机时先挂载本机磁盘再启动网络，而NFS是需要网络启动后才能挂载的，所以我们把挂载命令写入到/etc/rc.d/rc.local文件中即可。

vi /etc/rc.d/rc.local

#在文件最后添加一行：
mount -t nfs 10.30.211.112:/share /mnt/share/ -o nolock,nfsvers=3,vers=3
```
##### 3.4 测试验证
```shell
# 查看挂载结果，在客户端输入
df -h

[root@localhost ~]# df -h
文件系统                 容量  已用  可用 已用% 挂载点
devtmpfs                 3.9G     0  3.9G    0% /dev
tmpfs                    3.9G     0  3.9G    0% /dev/shm
tmpfs                    3.9G  8.9M  3.9G    1% /run
tmpfs                    3.9G     0  3.9G    0% /sys/fs/cgroup
/dev/mapper/centos-root   96G  1.9G   95G    2% /
/dev/sda1                2.0G  194M  1.9G   10% /boot
10.30.211.112:/share      94G  4.6G   90G    5% /mnt/share
tmpfs                    783M     0  783M    0% /run/user/0


# 看到最后第二行，就说明已经挂载成功了。
# 接下来就可以在客户端上进入目录/mnt/share下，新建/删除文件，然后在服务端的目录/data/share查看是不是有效果了
```


#### 4、参考：
```txt
https://www.yht7.com/news/154271
```

 