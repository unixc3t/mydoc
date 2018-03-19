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



#####The	FROM	instruction

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

> docker允许在一个dockerfile中使用多个from命令，来构建多个image，docker会拉出所有from命令指定的image