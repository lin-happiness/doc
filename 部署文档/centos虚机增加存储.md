## centos7虚机增加存储操作

#### 1、调整关闭操作系统调整虚拟机配置，增加需要增加的磁盘大小

vm中操作

#### 2、分配增加的存储


##### 2.1查看磁盘状态
```shell
fdisk -l

# lsblk：列出所有可用设备块信息
# vgdisplay -v：查看卷分组
```
##### 2.2使用fdisk命令，创建新分区
```shell
fdisk /dev/sda

1、命令行提示下输入【m】
	命令(输入 m 获取帮助)： m
    命令操作
    a toggle a bootable flag
    b edit bsd disklabel
    c toggle the dos compatibility flag
    d delete a partition
    l list known partition types
    m print this menu
    n add a new partition
    o create a new empty DOS partition table
    p print the partition table
    q quit without saving changes
    s create a new empty Sun disklabel
    t change a partition's system id
    u change display/entry units
    v verify the partition table
    w write table to disk and exit
    x extra functionality (experts only)
2、输入命令【n】添加新分区。
3、输入命令【p】创建主分区。
4、输入【回车】，选择默认大小，这样不浪费空间
5、输入【回车】，选择默认的start cylinder。
6、输入【w】，保持修改
```
##### 2.3重启linux
```shell
reboot
# 这时在/dev/目录下，才能看到了新的分区比如/dev/sda3
```
##### 2.4格式化/dev/sda3
```shell
mkfs.ext4 /dev/sda3
```
##### 2.5创建物理卷
```shell
pvcreate /dev/sda3
```
#查看新建的物理卷信息和大小
```shell
pvdisplay 
```
##### 2.6将添加新的物理卷，加载到卷组 centos 中
```shell
vgextend centos /dev/sda3
```
##### 2.7#增加逻辑卷 /dev/mapper/centos-root 大小，增加500M
```shell
lvextend -L +1.9G /dev/mapper/centos-root
```
##### 2.8重新识别 /dev/mappercentos-root 大小
```shell
xfs_growfs /dev/mapper/centos-root

#查看扩容后的大小 
df -h
```

