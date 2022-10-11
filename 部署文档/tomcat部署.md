# Tomcat部署及优化

## 一、Tomcat部署
### 1、部署java运行环境
参考：java环境部署

### 2、下载Tomcat安装包
    sudo wget https://mirrors.bfsu.edu.cn/apache/tomcat/tomcat-8/v8.5.65/bin/apache-tomcat-8.5.65.tar.gz
### 2、解压压缩包并移动到/usr/local目录下

    sudo tar -zxvf apache-tomcat-8.5.65.tar.gz

    sudo mv apache-tomcat-8.5.65/ /usr/local/tomcat8
    
    sudo chmod 755 -R /usr/local/tomcat8/
### 3、启动Tomcat测试

    sudo sh /usr/local/tomcat8/bin/startup.sh

访问测试（注意开放防火墙对应端口）

http://IP:8080


### 4、修改Tomcat服务器缺省banner 
编辑Tomcat（安装目录）/conf/server.xml 文件 ，找到我们应用程序端口对应的<Connector>元素，新增 server="自定义" 属性，覆盖掉原来的server属性。

    <Connector port="9090" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" server="unkown"/>


执行测试

    curl -I  http://127.0.0.1:9090
测试结果

    HTTP/1.1 200
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
    Date: Wed, 28 Apr 2021 07:55:59 GMT
    Server: unkown


### 5、配置Tomcat服务及开机启动
#### 5.1 修改bin/setclasspath.sh配置

    sudo vi /usr/local/tomcat8/bin/setclasspath.sh

在setclasspath.sh文件中的

    #Make sureprerequisite environment variables are set

这行前面增加下面两行:

    export  JAVA_HOME=/usr/local/java
    export  JRE_HOME=/usr/local/java/jre
修改后代码

    # Make sure prerequisite environment variables are set
    
    export  JAVA_HOME=/usr/local/java
    export  JRE_HOME=/usr/local/java/jre
    
    if [ -z "$JAVA_HOME" ] && [ -z "$JRE_HOME" ]; then


#### 5.2 创建tomcat.service
创建service文件

    sudo vi /etc/systemd/system/tomcat.service

配置内容

    [Unit]
    Description=Tomcat8
    After=syslog.target network.target remote-fs.target nss-lookup.target
    
    [Service]
    Type=oneshot
    ExecStart=/usr/local/tomcat8/bin/startup.sh
    ExecStop=/usr/local/tomcat8/bin/shutdown.sh
    ExecReload=/bin/kill -s HUP $MAINPID
    RemainAfterExit=yes
    
    [Install]
    WantedBy=multi-user.target

#### 5.3 通过服务命令启动Tomcat
    sudo systemctl start tomcat.service
#### 5.4 查看Tomcat服务状态
    sudo systemctl start tomcat.service    
#### 5.5 服务开机启动
    sudo systemctl enable tomcat.service
#### 5.6 常用命令
查看tomcat的状态

    sudo systemctl status tomcat.service

配置开机启动

    sudo systemctl enable tomcat.service

删除开机启动

    sudo systemctl disable tomcat.service

启动tomcat

    sudo systemctl start tomcat.service

停止tomcat

    sudo systemctl stop tomcat.service

重启tomcat

    sudo systemctl restart tomcat.service
    
查看systemctl的开机启动列表

    sudo systemctl list-unit-files | grep tomcat
    sudo systemctl list-unit-files | grep enabled

其中.service可以省略。
参考：https://blog.csdn.net/tiantang_1986/article/details/53704966
### 6、Tomcat介绍

#### Tomcat核心组件
通常意义上的 Web 服务器接受请求后，只是单纯地响应静态资源（如 HTML 文件、图 片文件等），不能在后端进行一定的处理操作。 Tomcat 是 Apache 下的一个子项目，它具 备 Web 服务器的所有功能，不仅可以监听接受请求并响应静态资源，而且可以在后端运行 特定规范的 Java 代码 Servlet，同时将执行的结果以 HTML 代码的形式返回客户端。

- web容器：web服务器
- servlet容器： 名为Catalina，处理servlet 代码
- JSP容器： 将JSP动态网页翻译成servlet代码


#### Tomcat处理请求过程

![image](https://img-blog.csdnimg.cn/20200813143747579.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MjA5OTMwMQ==,size_16,color_FFFFFF,t_70#pic_center)

##### Tomcat 具体的处理请求过程如下所示。

- 用户在浏览器中输入网址 localhost:8080/test/index.jsp，请求被发送到本机端口 8080， 被在那里监听的
Coyote HTTP/1.1 Connector 获得；

- Connector 把该请求交给它所在的 Service 的
- Engine（Container）来处理，并等待 Engine 的回应；
- Engine 获得请求 localhost/test/index.jsp，匹配所有的虚拟主机 Host；
Engine 匹配到名为 localhost 的 Host（即使匹配不到也把请求交给该 Host 处理，因为 该 Host 被 定 义为 该 Engine 的 默 认 主 机 ） ， 名 为 localhost 的 Host 获 得 请 求/test/index.jsp，匹配它所拥有的所有 Context。Host 匹配到路径为/test 的 Context（如果匹配不到就把该请求交给路径名为“ ”的 Context 去处理）；
- path=“/test”的 Context 获得请求/index.jsp，在它的 mapping table 中寻找出对应的servlet。Context 匹配到 URL Pattern 为*.jsp 的 Servlet，对应于 JspServlet 类；
- 构造 HttpServletRequest 对象和 HttpServletResponse 对象，作为参数调用 JspServlet 的doGet()或 doPost(),执行业务逻辑、数据存储等；
- Context 把执行完之后的 HttpServletResponse 对象返回给 Host；
- Host 把 HttpServletResponse 对象返回给 Engine；
- Engine 把 HttpServletResponse 对象返回 Connector；
- Connector 把 HttpServletResponse 对象返回给客户 Browser。
#### Tomcat目录结构
![image](https://img-blog.csdnimg.cn/20200813114722898.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MjA5OTMwMQ==,size_16,color_FFFFFF,t_70#pic_center)


#### Tomcat 配置文件参数优化
Tomcat主配置文件server.xml 常用的配置参数

- maxThreads
- minSpareThreads
- maxSpareThreads
- URIEncoding
- connnectionTimeout
- enableLookups
- disableUploadTimeout
- connectionUploadTimeout
- acceptCount
- compression
- compressionMinSize
- compressableMimeType
- noCompressionUserAgents=“gozilla, traviata”
##### 如果对代码进行了动静分离处理，静态页面和图片等数据就不需做Tomcat 处理，也就不要在Tomcat 中配置压缩

### 7、Tomcat优化
#### server.xml文件说明


    <Server>代表整个Servlet容器组件，是最顶层元素，可以包含一个或多个<Service>元素
            <Service>包含一个<Engine>元素以及一个或多个<Connector>元素，这些<Connector>共享一个<Engine>
                <Connector/>代表和客户程序实际交互的组件，负责接收客户请求，以及向客户返回响应
                <Engine>每个<Service>元素只能包含一个<Engine>元素，它处理在同一个<Service>中所有<Connector>接收到的客户请求
                          <Host>在一个<Engine>中可以包含多个<Host>,它代表一个虚拟主机(即一个服务器程序可以部署在多个有不同IP的服务器主机上)，它可以包含一个或多个应用
                                  <Context>使用最频繁的元素，代表了运行在虚拟主机上的单个web应用
                         </Host>
               </Engine>
          </Service>
    </Server>



#### Tomcat 配置文件参数优化
关于 Tomcat 主配置文件 server.xml 里面很多默认的配置项，并不能满足业务需求，常 用的优化参数如下。

- maxThreads：Tomcat 使用线程来处理接收的每个请求，这个值表示 Tomcat 可创建的 最大的线程数，默认值是 200。

- minSpareThreads：最小空闲线程数，Tomcat 启动时的初始化线程数，表示即使没有 人使用也开这么多空线程等待，默认值是
- 10。

- maxSpareThreads：最大备用线程数，一旦创建的线程超过这个值，Tomcat 就会关闭 不再需要的 socket
- 线程。默认值是-1（无限制），一般不需要指定。

- URIEncoding：指定 Tomcat 容器的 URL 编码格式，Tomcat 语言编码格式这块不如 其它
- Web服务器软件配置方便，需要分别指定。

- connnectionTimeout：网络连接超时，单位：毫秒，设置为 0 表示永不超时，这样设置 有隐患的。通常默认 20000
- 毫秒就可以。

- enableLookups：是否反查域名，以返回远程主机的主机名，取值为：true 或 false， 如果设置为 false，则直接返回
- IP 地址，为了提高处理能力，应设置为 false。

- disableUploadTimeout：上传时是否使用超时机制。应设置为 true。

- connectionUploadTimeout：上传超时时间，毕竟文件上传可能需要消耗更多的时间，

- 该参数需要根据自己的业务需要自行调整，以使 Servlet 有较长的时间来完成它的执行， 需要与上一个参数一起配合使用才会生效。

- acceptCount：指定当所有可以使用的处理请求的线程都被使用时，可传入连接请求的
- 最大队列长度，超过这个数的请求将不予处理，默认为 100 个。

- compression：是否对响应的数据进行 GZIP 压缩，off 表示禁止压缩、on 表示允许压 缩（文本将被压缩）、force
- 表示所有情况下都进行压缩，默认值为 off。压缩数据后可 以有效的减少页面的大小，一般可以减小 1/3 左右，因而节省带宽。

- compressionMinSize：表示压缩响应的最小值，只有当响应报文大小大于这个值的时
- 候才会对报文进行压缩，如果开启了压缩功能，默认值就是 2048。

- compressableMimeType：压缩类型，指定对哪些类型的文件进行数据压缩。
- noCompressionUserAgents=“gozilla, traviata”：对于以下的浏览器，不启用压缩。 如果已经对代码进行了动静分离，静态页面和图片等数据就不需要 Tomcat 处理了，那 么也就不需要在 Tomcat 中配置压缩了。因为这里只有一台 Tomcat 服务器，而且压测的是 Tomcat 首页，会有图片和静态资源文件，所以这里启用压缩。

以上是一些常用的配置参数，还有好多其它的参数设置，还可以继续深入的优化，HTTP Connector 与 AJP Connector 的参数属性值，可以参考官方文档的详细说明进行学习。链接地址 http://tomcat.apache.org/tomcat-9.0-doc/config/http.html


#### 关闭Tomcat的监听端口,默认为8005
    <Server port="8005" shutdown="SHUTDOWN">

    #如果要禁用端口则修改为:
    <Server port="-1" shutdown="SHUTDOWN">
#### 链接器Connector 参数优化配置

#### Tomcat Connector三种运行模式（BIO, NIO, APR）
###### 1）BIO：一个线程处理一个请求。缺点：并发量高时，线程数较多，浪费资源。Tomcat7或以下在Linux系统中默认使用这种方式。

###### 2）NIO：利用Java的异步IO处理，可以通过少量的线程处理大量的请求。Tomcat8在Linux系统中默认使用这种方式。Tomcat7必须修改Connector配置来启动（conf/server.xml配置文件）：

<Connectorport="8080"protocol="org.apache.coyote.http11.Http11NioProtocol" connectionTimeout="20000"redirectPort="8443"/>
###### 3）APR(Apache Portable Runtime)：从操作系统层面解决io阻塞问题。Linux如果安装了apr和native，Tomcat直接启动就支持apr。

    <Connector 
        executor="tomcatThreadPool"  //连接数限制修改配置的名字
        port="8080"  //tomcat的端口,默认为8080
        #protocol:
        #Tomcat 8 设置 nio2 更好:org.apache.coyote.http11.Http11Nio2Protocol
        #Tomcat 6,7 设置 nio 更好：org.apache.coyote.http11.Http11NioProtocol
        #Tomcat 8 设置 APR 性能飞快：org.apache.coyote.http11.Http11AprProtocol 
        protocol="org.apache.coyote.http11.Http11Nio2Protocol" 
        connectionTimeout="60000" //Connector接受一个连接后等待的时间(milliseconds)，默认值是60000
        maxConnections="10000"  //这个值表示最多可以有多少个socket连接到tomcat上
        redirectPort="8443"  //SSL端口号
        enableLookups="false"  //禁用DNS查询
        acceptCount="100"  //当tomcat起动的线程数达到最大时，接受排队的请求个数，默认值为100
        maxPostSize="10485760" //设置由容器解析的URL参数的最大长度，-1(小于0)为禁用这个属性，默认为2097152(2M) 请注意， FailedRequestFilter 过滤器可以用来拒绝达到了极限值的请求。
        maxHttpHeaderSize="8192"  //http请求头信息的最大长度，超过此长度的部分不予处理。一般8K。
        compression="on"  //是否启用GZIP压缩 on为启用（文本数据压缩） off为不启用， force 压缩所有数据
        disableUploadTimeout="true" //这个标志允许servlet容器使用一个不同的,通常长在数据上传连接超时。 如果不指定,这个属性被设置为true,表示禁用该时间超时。
        compressionMinSize="2048" //当超过最小数据大小才进行压缩
        acceptorThreadCount="2" //用于接受连接的线程数量。增加这个值在多CPU的机器上,尽管你永远不会真正需要超过2。 也有很多非维持连接,您可能希望增加这个值。默认值是1。
        compressableMimeType= "text/html,text/plain,text/css,application/javascript,application/json,application/x-font-ttf,application/x-font-otf,image/svg+xml,image/jpeg,image/png,image/gif,audio/mpeg,video/mp4" //配置想压缩的数据类型
        URIEncoding="utf-8" //网站一般采用UTF-8作为默认编码。
        processorCache="20000" //协议处理器缓存的处理器对象来提高性能。 该设置决定多少这些对象的缓存。-1意味着无限的,默认是200。 如果不使用Servlet 3.0异步处理,默认是使用一样的maxThreads设置。 如果使用Servlet 3.0异步处理,默认是使用大maxThreads和预期的并发请求的最大数量(同步和异步)。
        tcpNoDelay="true" //如果设置为true,TCP_NO_DELAY选项将被设置在服务器套接字,而在大多数情况下提高性能。这是默认设置为true。
        connectionLinger="5" //秒数在这个连接器将持续使用的套接字时关闭。默认值是 -1,禁用socket 延迟时间。
        server="Server Version 11.0" //隐藏Tomcat版本信息，首先隐藏HTTP头中的版本信息
    />
    
#### 配置tomcat的管理用户
    sudo vi tomcat-users.xml
    
内容

    <role rolename="manager"/>
    <role rolename="manager-gui"/>
    <role rolename="admin"/>
    <role rolename="admin-gui"/>
    <user username="tomcat" password="tomcat" roles="admin-gui,admin,manager-gui,manager"/>


- 如果是tomcat7，配置了tomcat用户就可以登录系统了，但是tomcat8中不行，还需要修改另一个配置文件，否则访问不了，提示403


    sudo vi webapps/manager/META-INF/context.xml

将<Valve>的内容注释掉

    <Context antiResourceLocking="false" privileged="true" >
     <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
             allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
      <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
    </Context>

#### tomcat线程池
    默认值:被注释了了
    <!-- <Executor name="tomcatThreadPool" namePrefix="catalina-exec-" maxThreads="150" minSpareThreads="4"/> -->
    修改示例
    <Executor 
        name="tomcatThreadPool"  //被链接器配置识别的名字
        namePrefix="catalina-exec-" //所创建的每个线程的名称前缀，一个单独的线程名称为 namePrefix+threadNumber
        maxThreads="500" //最大并发数，默认设置 200，一般建议在 500 ~ 800，根据硬件设施和业务来判断
        minSpareThreads="30"  //omcat 初始化时创建的线程数，默认设置 25
        maxIdleTime="60000" //如果当前线程大于初始化线程，那空闲线程存活的时间，单位毫秒，默认60000=60秒=1分钟
        prestartminSpareThreads = "true" //在 Tomcat 初始化的时候就初始化 minSpareThreads 的参数值，如果不等于 true，minSpareThreads 的值就没啥效果了
        threadPriority=5 //线程池中线程优先级，默认值为5，值从1到10。
        maxQueueSize = (Int的最大值) //最大的等待队列数, 也就是在被执行前最大线程排队数目，默认为Int的最大值，也就是广义的无限。除非特殊情况，这个值不需要更改，否则会有请求不会被处理的情况发生
        className：线程池实现类，未指定情况下，默认实现类为org.apache.catalina.core.StandardThreadExecutor。如果想使用自定义线程池首先需要实现 org.apache.catalina.Executor接口。线程池配置完成后需要在 Connector中指定
    />

注：当tomcat并发用户量大的时候，单个jvm进程确实可能打开过多的文件句柄，这时会报java.net.SocketException:Too many open files错误。可使用下面步骤检查：

- ps -ef |grep tomcat 查看tomcat的进程ID，记录ID号，假设进程ID为10001
- lsof -p 10001|wc -l 查看当前进程id为10001的 文件操作数
- 使用命令：ulimit -a 查看每个用户允许打开的最大文件数

#### 自动部署功能
    <Host appBase="webapps" autoDeploy="true" name="localhost" unpackWARs="true">
    #如果想关闭自动部署功能
    <Host appBase="webapps" autoDeploy="false" name="localhost" unpackWARs="true">
    AJP端口配置
     <Connector 
         port="8009"   //端口,如果多个tomcat部署在一个服务器上,则要修改次处
         protocol="AJP/1.3" 
         address="127.0.0.1"  
         redirectPort="8443" />
#### 集群配置 Engine标签内
    #默认这条语句是被注释起来的:
    <!--
    <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"/>
    -->
    #开启集群,我们只需要吧这条注释放开就可以了
上面的情况是tomcat都部署到了不同的服务器上,所用才用默认的配置都是不会出错的,但是,如果我们在一台服务器上配置了多个tomcat,那么问题就来了,会有端口冲突的问题,所用我们得配置更多的信息

    <!--下面的代码是开启集群和实现session复制功能-->
    <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" channelSendOptions="6">
          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="192.168.100.63"    <!--这里填写本机IP地址-->
                      port="5000"    //不同的tomcat配置不同的端口
                      selectorTimeout="100" />
          </Channel>
     </Cluster>

#### 内存优化

优化内存，主要是在bin/catalina.bat或bin/catalina.sh 配置文件中进行。linux上，在catalina.sh中添加：

    JAVA_OPTS="-server -Xms1G -Xmx2G -Xss256K -Djava.awt.headless=true -Dfile.encoding=utf-8 -XX:MaxPermSize=256m -XX:PermSize=128M -XX:MaxPermSize=256M"

可通过jmap -heap process_id查看设置是否成功

其中：
- -server：启用jdk的server版本。
- -Xms：虚拟机初始化时的最小堆内存。
- -Xmx：虚拟机可使用的最大堆内存。 #-Xms与-Xmx设成一样的值，避免JVM因为频繁的GC导致性能大起大落
- -XX:PermSize：设置非堆内存初始值,默认是物理内存的1/64。
- -XX:MaxNewSize：新生代占整个堆内存的最大值。
- -XX:MaxPermSize：Perm（俗称方法区）占整个堆内存的最大值，也称内存最大永久保留区域。
- java8开始，PermSize被MetaspaceSize代替，MetaspaceSize共享heap，不会再有java.lang.OutOfMemoryError：PermGen space，可以不设置
- Headless=true：   适用于Linux系统，与图形操作有关，如生成验证码含义是当前的是无显示器的服务器，应用中如果获取系统显示有关的参数会抛出异常，windows系统可不用设置

##### 1）错误提示：java.lang.OutOfMemoryError:Java heap space

Tomcat默认可以使用的内存为128MB，在较大型的应用项目中，这点内存是不够的，有可能导致系统无法运行。常见的问题是报Tomcat内存溢出错误，Outof Memory(系统内存不足)的异常，从而导致客户端显示500错误，一般调整Tomcat的-Xms和-Xmx即可解决问题，通常将-Xms和-Xmx设置成一样，堆的最大值设置为物理可用内存的最大值的80%。

    set JAVA_OPTS=-Xms512m-Xmx512m 
##### 2）错误提示：java.lang.OutOfMemoryError: PermGenspace

PermGenspace的全称是Permanent Generationspace,是指内存的永久保存区域，这块内存主要是被JVM存放Class和Meta信息的,Class在被Loader时就会被放到PermGenspace中，它和存放类实例(Instance)的Heap区域不同,GC(Garbage Collection)不会在主程序运行期对PermGenspace进行清理，所以如果你的应用中有很CLASS的话,就很可能出现PermGen space错误，这种错误常见在web服务器对JSP进行precompile的时候。如果你的WEB APP下都用了大量的第三方jar, 其大小超过了jvm默认的大小(4M)那么就会产生此错误信息了。解决方法：

    setJAVA_OPTS=-XX:PermSize=128M
3）在使用-Xms和-Xmx调整tomcat的堆大小时，还需要考虑垃圾回收机制。如果系统花费很多的时间收集垃圾，请减小堆大小。一次完全的垃圾收集应该不超过3-5 秒。如果垃圾收集成为瓶颈，那么需要指定代的大小，检查垃圾收集的详细输出，研究垃圾收集参数对性能的影响。一般说来，你应该使用物理内存的 80% 作为堆大小。当增加处理器时，记得增加内存，因为分配可以并行进行，而垃圾收集不是并行的。

### 8、Tomcat监控工具之probe

#### probe介绍

probe也叫psi-probe，是lambdaprobe的一个分支版本，用于Tomcat应用状态的监控、数据库连接监控、应用监控、日志信息监控（可以查看所有Tomcat自身的日志信息和Tomcat所管理的应用打印的日志信息，并可根据日志级别过滤所需的日志信息）、监控集群运行状态(部分Tomcat版本可用)、监控所以线程的状态、统计Tomcat连接等。

#### 下载war包
地址：https://github.com/psi-probe/psi-probe/releases

#### 安装

- 解压，将probe.war放在Tomcat的webapps目录下。

- 配置tomcat的权限，修改CATALINA_HOME/conf/tomcat-users.xml，即在<tomcat-users></tomcat-users>标签内添加


     <role rolename="manager"/> <role rolename="poweruser"/> <role rolename="tomcat"/> <role rolename="poweruserplus"/> <role rolename="probeuser"/> <user   username="tomcat"password="tomcat"roles="manager,poweruser,probeuser,poweruserplus" />
#### 配置参数

在windows环境下，修改bin/catalina.bat并添加set

    JAVA_OPTS=-Dcom.sun.management.jmxremote
    
在linux环境下，修改bin/catalina.sh并添加export

    JAVA_OPTS=$JAVA_OPTS" -Dcom.sun.management.jmxremote"

#### 启动tomcat访问probe
浏览器访问：http://ip:8080/probe

使用tomcat-users.xml中配置的用户名与密码登录，可以看到probe的监控界面。

英文版(点击下方中国国旗可切换为中文)



### 9、参考

Tomcat安装、配置、优化及负载均衡详解
https://www.cnblogs.com/rocomp/p/4802396.html

Tomcat优化性能调优及代码优化建议
https://www.jianshu.com/p/ca6ed42ec561

tomcat8常用配置说明
https://www.jianshu.com/p/8b1c75951f70

Tomcat7优化配置
https://blog.csdn.net/linuxnews/article/details/52724604

tomcat bio nio apr 模式性能测试
https://blog.csdn.net/wanglei_storage/article/details/50225779

Tomcat7性能优化
https://www.cnblogs.com/xbq8080/p/6417671.html

解析Tomcat的启动脚本--catalina.bat
https://www.jb51.net/article/99869.htm

解析Tomcat的启动脚本--startup.bat
https://www.jb51.net/article/99857.htm

Tomcat监控工具之probe
https://blog.csdn.net/qq_34177158/article/details/93715391

centos 7.6 —— 部署Tomcat&基于域名构建虚拟主机
https://blog.csdn.net/weixin_42099301/article/details/107972294

Java bin 目录下的工具

https://github.com/judasn/Linux-Tutorial/blob/master/markdown-file/Java-bin.md
