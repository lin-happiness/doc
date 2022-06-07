## nmon

### nmon介绍
```txt
(Nigel’s Monitor)是由IBM公司提供的、免费监控AIX系统与Linux系统资源的工具，该工具可以将服务器系统资源消耗的数据收集起来并输出一个特定的文件，再使用分析工具(nmon analyser)进行数据统计分析。

Nmon工具包括两部分nmon工具和nmon分析工具，该工具可以在IBM官方网上下载。

nmon主要记录以下方面的数据：
	CPU占用率;
	内存使用情况;
	磁盘I/O速度、传输和读写比率;
	文件系统的使用率;
	网络I/O速度、传输和读写比率、错误统计率与传输包的大小;
	消耗资源最多的进程;
	计算机详细信息和资源;
	页面空间和页面I/O速度;
	用户自定义的磁盘组;
	网络文件系统;
```
### 1、nmon工作流程
```txt
第一步：执行nmon工具命令，nmon工具会将输出的内容显示到计算机屏幕同时生成一份nmon文件;
第二步：将生成的nmon文件导出到操作系统(Windows、centos、mac等)，使用分析工具对生成的数据文件进行分析;
第三步：分析工具会将收集到的数据绘制成相关的图表，供分析使用;
```
### 2、安装
```shell
# nmon安装
yum install -y nmon

#实时查看系统信息（交互方式）
nmon

# 抓去分析到root文件夹下（测试是否正常）
nmon -s1 -c300 -f -m /root/

# nmon分析工具（linux）下载解压
wget http://sourceforge.net/projects/nmon/files/nmonchart40.tar
tar -xvf nmonchart40.tar
# ./nmonchart文件为执行程序
# 如果系统缺少ksh需要手动安装，缺少ksh错误提示：-bash: ./nmonchart: /usr/bin/ksh: bad interpreter: No such file or directory
yum install -y ksh

#实例--分析收集文件生成html（测试是否正常）
./nmonchart /root/VM-0-6-centos_220602_1019.nmon /root/test.html
```
### 3、 nmon命令说明
#### 3.1、nmon命令以记录方式获得系统信息：
```shell
# 交互方式：
nmon [ -h ]
nmon [ -s < seconds > ] [ -c < count > ] [ -b ] [ -B ] [ -g < filename > ] [ -k disklist ] [ -C < process1:process2:..:processN > ]
#在记录方式下，此命令会生成 nmon 文件。可以通过打开这些文件来直接进行查看，也可以使用后处理工具(例如，nmon 分析器)来查看。在记录期间，nmon 工具会与 shell 断开连接，以确保该命令即使在您注销的情况下仍然继续运行。
```
#### 3.2、nmon命令以记录方式获得系统信息交互方式：
```shell

nmon [ -f | -F filename | -x | -X | -z ] [ -r < runname > ] [ -t | -T | -Y ] [ -s seconds ] [ -c number ] [ -w number ] [ -l dpl ] [ -d ] [-g filename ] [ -k disklist ] [ -C ] [ -G ] [ -K ] [ -o outputpath ] [ -D ] [ -E ] [ -J ] [ -V ] [ -P ] [ -M ] [ -N ] [ -W ] [ -S ] [ -^ ] [ -O ] [ -L ] [ -I percent ] [ -A ] [ -m < dir > ] [ -Z priority ]
```
```txt
▲ 注：在记录方式下，仅指定-f、-F、-z、-x或-X标志的其中之一作为第一个参数。
▲ 描述：nmon命令显示和记录本地系统信息。此命令可以采用交互方式或记录方式运行。如果指定-F、-f、-X、-x和-Z标志中的任何一个，那么nmon命令处于记录方式。否则nmon命令处于交互方式。
nmon命令以交互方式提供下列视图：
系统资源视图(使用r键);
进程视图(使用t和u键);
AIO 进程视图(使用A键);
处理器使用情况小视图(使用c键);
处理器使用情况大视图(使用C键);
共享处理器逻辑分区视图(使用p键);
NFS 面板(使用N键);
网络接口视图(使用n键);
WLM 视图(使用W键);
磁盘繁忙情况图(使用o键);
磁盘组(使用g键);
ESS 虚拟路径统计信息视图(使用e键);
JFS 视图(使用j键);
内核统计信息(使用k键);
长期处理器平均使用率视图(使用l键);
大页分析(使用L键);
调页空间(使用P键);
卷组统计信息(使用V键);
磁盘统计信息(使用D键);
磁盘统计信息及图形(使用d键);
内存和调页统计信息(使用m键);
适配器 I/O 统计信息(使用a键);
共享以太网适配器统计信息(使用O键);
冗余检查良好/警告/危险视图(使用v键);
详细信息页统计信息(使用M键);
光纤通道适配器统计信息(使用^键);
```
### 4、 结果分析
#### 4.1、window
```shell
# 第一步：运行nmon记录命令，将收集系统运行机制时的数据。（被检测服务器上执行）
nmon –f –r test –s 10 –c 15
# 第二步：将生成的.nmon的文件转换为.csv文件，命令如下:（被检测服务器上执行）
sort test.nmon > test.csv
# 第三步：将.csv文件传输到本地计算，并使用nmon分析工具对结果数据进行分析。
```
#### 4.2、linux
```shell
# 第一步：运行nmon记录命令，将收集系统运行机制时的数据。（被检测服务器上执行）
nmon –f –r test –s 10 –c 15
# 第二步：使用nmon分析工具对结果数据进行分析。
./nmonchart test.nmon /root/test.html

```
