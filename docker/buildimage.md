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