linux资源限制配置文件是/etc/security/limits.conf；限制用户进程的数量对于linux系统的稳定性非常重要。
limits.conf文件限制着用户可以使用的最大文件数，最大线程，最大内存等资源使用量。
```shell
* soft nofile 655350  #任何用户可以打开的最大的文件描述符数量，默认1024，这里的数值会限制tcp连接
* hard nofile 655350
* soft nproc  655350  #任何用户可以打开的最大进程数
* hard nproc  650000
 
@student hard nofile 65535
@student soft nofile 4096
@student hard nproc 50  #学生组中的任何人不能拥有超过50个进程，并且会在拥有30个进程时发出警告
@student soft nproc 30
```
hard和soft两个值都代表什么意思呢？
soft是一个警告值，而hard则是一个真正意义的阀值，超过就会报错
## 一、所有用户创建的进程数:
```shell
ps h -Led -o user | sort | uniq -c | sort -n

# 结果
[root@localhost ~]# ps h -Led -o user | sort | uniq -c | sort -n
      1 chrony
      1 dbus
      5 postfix
      7 polkitd
     17 www
    193 root

```
## 二、系统最大打开文件描述符数:
查看
```shell
cat /proc/sys/fs/file-max

6553600
```
设置
```shell
vi /etc/sysctl.conf

fs.file-max = 6553600
```
## 三、进程最大打开文件描述符数
查看
ulimit -n默认查看的是soft limit
```shell
$ ulimit -n

170000
```
查看hard limit
```shell
ulimit -Hn

170000
```
设置
临时设置
```shell
# 通过ulimit -Sn设置最大打开文件描述符数的soft limit，注意soft limit必须小于hard limit

ulimit -Sn 160000

# 同时设置soft limit和hard limit。对于非root用户只能设置比原来小的hard limit。
$ ulimit -n 180000
```
永久设置
```shell
# root权限下，在/etc/security/limits.conf中添加如下两行，表示所有用户最大打开文件描述符数的soft limit为102400，hard limit为104800。重启生效
* soft nofile 102400
* hard nofile 104800
```
注意：设置nofile的hard limit还有一点要注意的就是hard limit不能大于/proc/sys/fs/nr_open，假如hard limit大于nr_open，注销后将无法正常登录。
## 四、查看当前系统使用的打开文件描述符数
```shell
cat /proc/sys/fs/file-nr
5664        0        186405
```
其中第一个数表示当前系统已分配使用的打开文件描述符数，第二个数为分配后已释放的（目前已不再使用），第三个数等于file-max。

## 五、知道了/etc/security/limits.conf中的参数含义之后，那么如何配置nofile，确定nofile的最大值呢。
解答：使用ulimt -n命令进行测试，如果小于系统允许的最大值，设置成功，大于最大值，系统会报错提示。
```shell
$ ulimit -n 1100000
-bash: ulimit: open files: cannot modify limit: Operation not permitted
$ ulimit -n 1048576
$ ulimit -n 1048577
-bash: ulimit: open files: cannot modify limit: Operation not permitted
$ ulimit -n 1048575
$ ulimit -n 1048576
```
## 六、ulimit -a/n/H/S 都有什么含义
```shell
ulimit -a 显示当前所有的资源限制
ulimit -H 设置硬件资源限制
ulimit -S 设置软件资源限制
ulimit -n 设置进程最大打开文件描述符数
ulimit -u <程序数目> 　用户最多可开启的程序数目
```
总结
```txt
a. 所有进程打开的文件描述符数不能超过/proc/sys/fs/file-max
b. 单个进程打开的文件描述符数不能超过user limit中nofile的soft limit
c. nofile的soft limit不能超过其hard limit
d. nofile的hard limit不能超过/proc/sys/fs/nr_open
```
## 参考
https://blog.csdn.net/zzddada/article/details/121699569

https://www.cnblogs.com/xuexiaohun/articles/6233430.html