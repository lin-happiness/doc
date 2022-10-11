未验证

Centos6.6升级到Centos7：
step 1：

[[email protected] ~]# cat /etc/yum.repos.d/upgrade.repo                                                 

[upgrade]

name=upgrade

baseurl=http://dev.centos.org/centos/6/upg/x86_64/

enable=1

gpgcheck=0
step 2：

[root@localhost ~]# yum install preupgrade-assistant-contents redhat-upgrade-tool preupgrade-assistant
step 3:

[root@localhost ~]# preupg
step 4：

[[email protected] ~]# rpm --import http://mirrors.163.com/centos/7.0.1406/os/x86_64/RPM-GPG-KEY-CentOS-7

[[email protected] ~]# redhat-upgrade-tool --network 7.0 --instrepo http://mirrors.163.com/centos/7.0.1406/os/x86_64/

(265/266): zlib-1.2.7-13.el7.x86_64.rpm                                                                       |  89 kB     00:00     

(266/266): zlib-devel-1.2.7-13.el7.x86_64.rpm                                                                 |  49 kB     00:00     

testing upgrade transaction

rpm transaction 100% [==============================================================================================================]

rpm install 100% [==================================================================================================================]

setting up system for upgrade

Finished. Reboot to start upgrade.
升级centos7过程其实非常的简单了，这个也是linux内核系统的一个优点了，升级系统可以直接使用简单的命令完以。