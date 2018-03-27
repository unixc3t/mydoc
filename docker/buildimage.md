##### 使用dockerfile构建镜像

> 1 Dockerfile文件

    FROM busybox:latest
    CMD echo Hello World!
> 2 在Dockerfile文件目录下执行

    sudo docker build .


    发送构建上下文给后台程序
    Sending build context to Docker daemon  2.048kB
    Step 1/2 : FROM busybox:latest
    ---> f6e427c148a7
    Step 2/2 : CMD echo Hello World!
    ---> Running in 50c5dc18d109
    Removing intermediate container 50c5dc18d109
    ---> 8475be0c7a62
    构建成功后返回,一个Id为8475be0c7a62镜像
    Successfully built 8475be0c7a62
    ~/projects/docker > rudy@rudy [php:7.2.2 -phpbrew]
    $

> 3 我们使用 这个镜像构建容器执行一下

    $ docker run 8475be0c7a62
    Hello World!

> 4 我们查看镜像

    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    <none>              <none>              8475be0c7a62        21 minutes ago      1.15MB
    busybox             latest              f6e427c148a7        2 weeks ago         1.15MB
    ubuntu              16.04               00fd29ccc6f1        3 months ago        111MB
    hello-world         latest              f2a91732366c        3 months ago        1.85kB

> 因为我们没有指定仓库名和tag所有都是none,我们可以使用docker tag 指定

    $ docker tag 8475be0c7a62 busyboxplus
    ~/projects/docker > rudy@rudy [php:7.2.2 -phpbrew]
    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    busyboxplus         latest              8475be0c7a62        26 minutes ago      1.15MB
    busybox             latest              f6e427c148a7        2 weeks ago         1.15MB
    ubuntu              16.04               00fd29ccc6f1        3 months ago        111MB
    hello-world         latest              f2a91732366c        3 months ago        1.85kB
> 另一种方案是，构建的时候使用 -t选项　指定

    	docker	build	-t	busyboxplus	 .

> 默认tag使用latest，标准的语法是　<image name>:<tag name>

> 默认docker build寻找当前目录中的Dockerfile，　你也可以使用-f选项　指定Dockerfile的目录和名字


##### 快速预览Dockerfile的语法

###### 指令
> dockerfile的指令有两部分组成， 一个是指令本身，后面跟着参数 

  #	Comment	
  INSTRUCTION	arguments	

>  INSTRUCTION可以被写成任何形式，大小写不敏感，然而最佳实践是使用大写 区别他和参数，如下

    FROM	busybox:latest	
    CMD	echo	Hello	World!!	

> FROM是一个指令，后面 是参数， CMD是一个指令，后面是参数

###### 注释

> docker注释以#开头 后面指令被当做参数，#前面不能有空格

> 一个有效的注释总是以#作为一行的第一个字符

    #	This	is	my	first	Dockerfile	comment	

> #符号可以作为参数一部分

    CMD	echo	###	Welcome	to	Docker	###	

> 可以在dockerfile中添加空行，提高可读性


###### The	parser	directives

> 有名字可知，这个parser指令通知dockerfile解析器，解析dockerfile内容，这个parser指令是可选的，但是必须位于dockerfile文件第一行，转义字符是唯一受支持的指令

> 我们使用转义字符去转义字符，或者扩展一行到多行， 在Unix平台， \是转义字符，在window中\是路径分隔符，而`是转义字符，默认，dockerfile parser认为 \是转义字符，你可以在window系统上使用转义解析指令覆盖这个，如下

# escpae=`



#####FROM命令

> 语法

    FROM	<image>[:<tag>|@<digest>]	

> image: 镜像名字， 作为基础镜像
> tag 或者 digest :这两个是可选的属性， 指定一个docker镜像，通过tag属性或者digest属性,如果这两个都没有，默认使用latest

> 下面是例子，默认使用latest作为tag的值，因为没有直接声明tag和digest在镜像名字后面，

    FROM	centos	

>  下面这个例子指定了ubuntu的tag
   FROM	ubuntu:16.04	

> 下面这个例子是使用了digest

   FROM	ubuntu@sha256:8e2324f2288c26e1393b63e680ee7844202391414dbd48497e9a4fd997cd3cbf	

> docker允许在一个dockerfile中使用多个from命令，来构建多个image，docker会拉出所有from命令指定的image,
> docker没有提供命名每个镜像的方法，强烈不推荐在一个dockerfile中使用多个from

##### MAINTAINER 命令

> MAINTAINER是一个提供信息的命令, 这个命令用来设置镜像作者，docker没有限制在文件什么地方使用这个命令,
> 强烈推荐在FROM指令后面使用这个命令

> <author's deatils>可以替换成任何文本,
> 强烈推荐使用镜像作者和作者邮箱来作为描述信息

    MAINTAINER	<author's	detail>	

> 下面是一个例子

    MAINTAINER	Dr.	Peter	<peterindia@gmail.com>	


##### COPY命令

> copy可以让你从docker宿主机复制文件到镜像的文件系统里，语法如下

    COPY	<src>	...	<dst>	

* src: 可以使当前构建文件的上下文，或者指定其他目录
* ...: 多个源文件，也可以使用通配符
* dst: 被构建镜像的目标路径， 源文件被拷贝的地方，如果多个文件被拷贝，这个路径必须是文件目录，目录以/结尾

> 被拷贝的地址使用绝对路径，如果不是绝对路径，copy命令假设目录是从root开始,copy指令可以创建一个新目录，或者在创建镜像时复写文件系统

> 下面例子，从构建文件上下文中拷贝html目录，到镜像/var/www/html

    COPY	html	/var/www/html

> 下面例子是，两个文件 chttpd.conf 和 magic，拷贝到镜像的/etc/httpd/conf/目录

    COPY	httpd.conf	magic	/etc/httpd/conf/	

> ADD 命令

> add命令类似copy命令，除了提供copy指令的功能以外，还可以处理tar文件也远程url，可以理解成add是copy的类固醇
> 下面是语法

    ADD	<src>	...	<dst>	

> add命令参数非常类似于copy命令

* src: 构建文件上下文或者指定的目录里的文件或者目录，不同的是，这个文件可以是构建上下文中的tar或者远程tar文件

* ...: 多个源文件，也可以使用通配符

* dst:文件或者目录被拷贝到镜像的路径

> 下面例子，拷贝多个源文件到不同的目标目录， 我们在构建上下文中有一个tar文件，包含http配置文件和页面，下面是结构

    $	tar	tf	web-page-config.tar
    etc/httpd/conf/httpd.conf
    var/www/html/index.html
    var/www/html/aboutus.html
    var/www/html/images/welcome.gif
    var/www/html/images/banner.gif		

> 下面的命令，是dockerfile文件中的，用来备考tar文件到目标镜像，并且从root目录开始解压 

    ADD	web-page-config.tar	/		

> 所以， add可以拷贝tar文件这个功能，可以拷贝多个文件到镜像


##### 	ENV命令

> env指令可以设置新镜像中的环境变量，一个环境变量就是一个键值对， 可以被任何脚本或者程序访问，linux使用环境变量来启动配置

> 下面是语法

    ENV	<key>	<value>	

    ENV	DEBUG_LVL	3	
    ENV	APACHE_LOG_DIR	/var/log/apache	


##### ARG命令

> arg命令可以让你定义构建镜像时传递的变量， docker build 子命令支持 --build-arg标记，传递一个值给arg定义的变量，如果你传递的变量没有在dockerfile中定义，就构建失败，换句话说，构建参数必须定义在dockerfile中，如果你想在构建时传递变量值

> 语法如下

    ARG	<variable>[=<default	value>]	

* variable: 构建参数变量
* default value: 你可以指定默认值

> 如下示例

    ARG	usr	
    ARG	uid=1000	

> 下面是构建时的例子

    docker	build	--build-arg	usr=app	--build-arg	uid=100	.	


##### environment 变量

> 环境变量可以通过env或者arg命令声明， 可以在 	 ADD ,	 COPY ,	 ENV ,	 EXPOSE ,	 LABEL ,	 USER ,	 WORKDIR ,	 VOLUME ,	 STOPSIGNAL ,	and	 ONBUILD 中使用，

> 例子

    ARG	BUILD_VERSION	
    LABEL	com.example.app.build_version=${BUILD_VERSION}		


##### USER 命令

> user命令 设置设置新镜像启动时的用户id或者username， 默认容器使用root作为用户id或者uid
> 本质上，user命令就是修改默认user id从root到这个命名指定的

    USER	<UID>|<UName>	

> user命令要么接收uid要么是uname作为参数

* uid: 用户数字Id
* uname: 有效的用户名

>下面例子,设置启动时用户id是73 

    USER	73	

> 虽然建议你在passwd文件中有一个有效的用户id， 但这个user id也可以包含任何随机数字值,然而，
>username如果指定了，就必须匹配passwd文件中的有效用户名，否则，docker run命令会失败，显示如下错误信息

    finalize	namespace	setup	user	get	supplementary	groups	Unable	to	find	user


##### WORKDIR命令

> workdir命令改变当前动作目录，从/变成指定的目录， 后面的指令 run cmd将工作在workdir指定的目录中

> 下面是语法

    WORKDIR	<dirpath>	

> dirpath是被设置的工作目录，这个目录可以是相对目录，或者绝对目录，如果是相对目录，他会相对前面workdir设置的目录，如果指定的目录没有在目标镜像中找到，就会创建这个目录

> 下面例子

    WORKDIR	/var/log	

##### VOLUME命令

> volume命令在目标镜像创建了一个目录，可以被用来挂载来自docker宿主机的volumes或者其他容器

> volume命令有两种语法，第一种exec或者json数组，数组中的值必须使用双引号

    	VOLUME	["<mountpoint>"]	

> 第二种是 shell

      VOLUME	<mountpoint>	

> 	 <mountpoint> 是在新镜像中创建的挂载点


##### EXPOSE命令

> expose命令开放一个容器的网络端口用于容器和外部世界通讯

>语法如下

    EXPOSE	<port>[/<proto>]	[<port>[/<proto>]...]

* port： 暴露给外部世界的端口
* proto: 可选项，用于指定协议，例如 tcp,udp, 如果没有传输协议指定，使用tcp

> expose指令允许你指定多个端口，在一行里

> 下面是一个例子，在dockerfile文件中，暴露了7373端口为upd协议，8080端口为tcp协议,

    EXPOSE	7373/udp	8080	


##### LABEL命令

> label指令让你添加键值对作为镜像的元数据，可以在以后用来管理镜像

    LABEL	<key-1>=<val-1>	<key-2>=<val-2>	...	<key-n>=<val-n>	

> label可以有一个或多个键值对，虽然一个dockerfile文件可以有多个label指令， 推荐使用一个label指令，后面多个键值对

    LABEL	version="2.0"		
						release-date="2016-08-05"	

> 上面例子，很简单，但是容易引起命名冲突， 推荐使用域名翻转作为命名空间标记key，

    LABEL	org.label-schema.schema-version="1.0"		
						org.label-schema.version="2.0"		
						org.label-schema.description="Learning	Docker	Example"		


##### 	RUN命令

> run命令是构建时真正的主力, 可以运行任何命令, 通常推荐一个run命令后面跟着多个命令，这样减少docker镜像的层数，因为在dockerfile中，每调用一次这个命令就创建一层

> run命令有两种语法类型

    run <command>

> command是构建期间可以执行的shell命令，如果这种语法被使用，以/bin/sh -c形式执行

> 第二种语法形式

    	RUN	["<exec>",	"<arg-1>",	...,	"<arg-n>"]	

* exec: 在构建期间执行的命令
* <arg-1>,	...,	<arg-n>: 这些事可变数量的参数

> 和第一种类型不同，这种类型不会调用 /bin/sh -c ,这种shell处理方式，例如变量替换，通配符替换
> 都不会发生在这种方式里， 如果shell处理对你来说很重要，鼓励你使用这种，如果你仍然喜欢exec 类型，使用你首选的shell作为可执行文件，并将命令作为参数提供。

    RUN	["bash",	"-c",	"rm",	"-rf",	"/tmp/abc"] .

> 下面是例子， 我们使用run命令，添加欢迎语在目标镜像的.bashrc文件中，

    RUN	echo	"echo	Welcome	to	Docker!"	>>	/root/.bashrc	

> 第二个例子是dockerfile文件，包含了构建一个apache2应用的镜像，

> 1 使用 ubuntu:14.04

    FROM	ubuntu:14.04	

> 2 作者信息

    	MAINTAINER	Dr.	Peter	<peterindia@gmail.com>	

> 3 使用 run命令， 同步仓库，安装apache2 ，清理文件

    	#	Install	apache2	package	
						RUN	apt-get	update	&&	\	
									apt-get	install	-y	apache2	&&	\
									apt-get	clean	