##### 1 查看docker状态

   sudo	systemctl	docker	status

>> 结果：

   正常Active列: active，
   问题Active列: inactive或者maintenance

>>解决

    重启 sudo	 systemctl	docker	restart

##### 2查看镜像历史

   docker	history


##### 3 下载第三方镜像 thedockerbook是第三方用户id,helloworld是仓库镜像名子
   sudo	docker	pull	thedockerbook/helloworld

##### 4 手动指定第三方仓库地址

    sudo	docker	pull	registry.example.com/myapp

##### 5 搜锁镜像

    sudo	docker	search	mysql

>> 可以使用管道符号，只显示 前10

    sudo docker search mysql | head -10

##### 6 使用容器进行交互式工作

>> docker run 接收一个镜像作为输入，然后基于它启动容器， 你可以传递 -t 和　-i标记，-i表示让容器从标准输入抓取信息，-t表示分配一个虚拟终端

    	sudo	docker	run	-i	-t	ubuntu:16.04	/bin/bash

>> 上面命令表示，启动交互容器，使用ubuntu:16.04作为镜像， /bin/bash作为命令

    root@742718c21816:/#

>> root后面的数字，是容器id，在docker术语里也叫作主机名

    root@435cf5d18ab2:/# hostname
    435cf5d18ab2
    root@435cf5d18ab2:/# id
    uid=0(root) gid=0(root) groups=0(root)
    root@435cf5d18ab2:/#  echo $PS1
    \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$
    root@435cf5d18ab2:/#

>> 暂时离开容器，而不是关闭容器 先按,ctrl+p 再按,ctrl+q

>> 使用 	 docker	ps 	 查看容器

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    435cf5d18ab2        ubuntu:16.04        "/bin/bash"         14 minutes ago      Up 14 minutes                           competent_fermat

* container id 表示关联的容器id ， 默认显示12位，可以使用 	 sudo	docker	ps	--no-trunc 全部显示
* IMAGE 表示由哪个镜像创建的
* COMMAND 表示容器启动时执行的命令
* CREATED 表示容器被创建时间
* STATUS 表示当前状态
* PORTS 表示关联这个容器的所有端口
* NAMES 表示 容器自动生成一个容器名， 有一个形容词和一个名字组成，或者是容器id，可以使用 --name手动配置

    docker run --name


>> docker	attach 命令回到我们的容器中， 我们可以使用容器id或者名字

    docker attach competent_fermat

>> 使用exit退出交互模式，并且停止容器


###### 跟踪容器改变

> 启动一个容器，创建文件夹

    $	sudo	docker	run	-i	-t	ubuntu:16.04	/bin/bash

    root@d5ad60f174d3:/#	cd	/home

    root@d5ad60f174d3:/home#	ls	-l
    total	0
    root@d5ad60f174d3:/home#	touch	{abc,cde,fgh}
    root@d5ad60f174d3:/home#	ls	-l
    total	0
    -rw-r--r--	1	root	root	0	Sep	29	10:54	abc
    -rw-r--r--	1	root	root	0	Sep	29	10:54	cde
    -rw-r--r--	1	root	root	0	Sep	29	10:54	fgh
    root@d5ad60f174d3:/home#

> docker允许我们暂时离开容器或者开启另一个docker所在主机的终端，使用docker diff子命令来查看文件系统
> 我们知道ubuntu容器有自己的主机名，是提示符的一部分，也是容器id， 我们直接使用docker diff 和这个容器id 来查看

    sudo	docker	diff	d5ad60f174d3

    C	/home
    A	/home/abc
    A	/home/cde
    A	/home/fgh

* /home是被修改的目录 用C标记
* /home/abc ,	 /home/cde , 和	 /home/fgh  是被添加的文件 用A标记
* 用D标记表示删除

> 如果我们使用一个镜像时，没有指定使用哪个，默认使用latest 镜像



##### 控制docker容器

> docker stop可以停止一个正在运行的容器，当用户使用这个命令 docker引擎发出SIGTERM(-15)给容器所在主进程，如果不能停止，就发出SIGKILL(-9)强制终止，

> 我们来试验这个命令，我们开启第一个终端，启动一个容器

    $	sudo	docker	run	-i	-t	ubuntu:16.04	/bin/bash
    root@da1c0f7daa2a:/#

> 然后我们打开第二个终端 执行

    $	sudo	docker	stop	da1c0f7daa2a
    da1c0f7daa2a

> 第一个终端显示

    root@da1c0f7daa2a:/#	exit
    $

> docker ps 默认只显示运行的容器，我们使用 docker ps -a 显示所有状态的容器

    $ docker ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
    357ac35c6702        ubuntu:16.04        "/bin/bash"         2 minutes ago       Exited (0) 2 minutes ago                       gifted_dubinsky

> docker start 可以启动一个或者多个停止的容器， 停止状态的容器是指由docker stop终止的或者强制终止的
> 我们可以启动前面停止的容器

    $	sudo	docker	start	da1c0f7daa2a
    da1c0f7daa2a
    $

> docker start 不会启动容器后，登录容器 你可以使用docker attach 容器id登录，或者在 docker start 加上 -a直接登录

    $	sudo	docker	attach	da1c0f7daa2a
    root@da1c0f7daa2a:/#

    $ docker ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
    357ac35c6702        ubuntu:16.04        "/bin/bash"         25 minutes ago      Up 2 minutes                                    gifted_dubinsky

> docker restart 命令是 stop和start功能的组合 ，先停止再启动

    docker restart 357ac35c6702
    //然后使用attach再次登录
    docker attach 357ac35c6702

> docker pause 和 docker unpause 两个命令 暂停容器中所有执行的程序和恢复容器所有进程 我们看一个例子

   第一个终端我们启动容器，我们写一个循环5秒钟打印一次时间
   sudo	docker	run	-i	-t	ubuntu:16.04	/bin/bash

   $ docker run -i -t ubuntu:16.04 /bin/bash
    root@7f1d6799491e:/#  while true;dodate;sleep 5;done
    root@7f1d6799491e:/# while true; do date; sleep 5; done
    Thu Mar 15 14:41:40 UTC 2018
    Thu Mar 15 14:41:45 UTC 2018
    Thu Mar 15 14:41:50 UTC 2018
    Thu Mar 15 14:41:55 UTC 2018


    我们在第二个终端暂停这个容器

    $ docker pause 7f1d6799491e
    7f1d6799491e

> 当我们停止了这个容器，时间不再打印， 我们使用ps 查看

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                  PORTS               NAMES
    7f1d6799491e        ubuntu:16.04        "/bin/bash"         2 minutes ago       Up 2 minutes (Paused)                       determined_euclid

> 然后我们使用 unpause 恢复容器的进程。 时间继续打印

    $ docker unpause 7f1d6799491e
    7f1d6799491e

> 实验结束，我们停止容器

    $ docker stop 7f1d6799491e
    7f1d6799491e


##### 管理容器


> 容器停止后，虽然可以再次使用，但是很多时候我们硬盘上很多容器不会再次使用，这样就造成了空间浪费，docker提供了删除这些容器的命令， docker run提供了当容器启动后，然后到达停止状态时，自动清理容器，我们需要添加--rm参数

    	 sudo	docker	run	-i	-t	--rm  ubuntu:16.04	/bin/bash

> 另一个办法是 使用docker ps -a显示所有容器，使用docker rm 删除指定容器


    $	sudo	docker	ps	-a
    CONTAINER	ID									IMAGE									COMMAND							CREATED
    STATUS															PORTS
    NAMES
    7473f2568add							ubuntu:16.04		"/bin/bash"		5	seconds	ago
    Exited	(0)	3	seconds	ago
    jolly_wilson
    $	sudo	docker	rm	7473f2568add
    7473f2568add
    $

> 可以将 docker rm 和docker ps组合使用

    $	sudo	docker	rm	$(sudo	docker	ps	-aq)

> $()里面的命令列出所有容器，不管是退出的还是运行的，但是删除的时候会报错，因为不能删除正在运行的容器，除非你使用-f选项强制删除,docker　rm　不能删除正在运行的容器，　我们可以使用　-f 选项过滤出退出状态的容器

    $	sudo	docker	rm	$(sudo	docker	ps	-aq	-f	state=exited)

> 命令太冗长，docker提供了简写命令移除停止的全部容器，这个命令是在　1.13版本引入的

    	 docker	container	prune

       $ docker container prune
        WARNING! This will remove all stopped containers.
        Are you sure you want to continue? [y/N] y
        Deleted Containers:
        7f1d6799491ef331671b1dc7dcc9434f72d4360821e7c9105a6499446b55552f
        357ac35c6702e420ea3376a0b811dc2ff82e1125ecfd0e491a83a00c5bb766a3
        ed44d0e8982c7ee62fadc980332929b63f1d50815cbb9f7b9e1148d38f8257bc
        435cf5d18ab2deb851eccb0026878f5006240dada68697d805676f4454812fc0
        94a2e03eb9a34d34178dc577a4e90a290ad23582edc82b9774d89f901a7607f9
        1b57c6477ac8a8da7f6e85215b5e2f026324ca6bb116f053d8faf84ec5dd6e41
        869a4b14e59c6689fdbe3ac161dd2bf21a3f9fdbe335a9839a5d7c7cef818438

        Total reclaimed space: 95.96MB
> 释放系统空间
    docker system prune -a

##### 从容器构建镜像

> 我们使用　ubuntu:16.04　作为我们基本镜像　安装webget程序，然后将容器转换成镜像

> 1　启动容器

      		$	sudo	docker	run	-i	-t	ubuntu:16.04	/bin/bash

> 2　我们使用　which　 wget命令验证　容器里是否安装了这个wget程序，如果什么都没有返回表示没有安装

    root@472c96295678:/#	which	wget
		root@472c96295678:/#

> 3　因为我们是基于一个新的ubuntu镜像的容器，我们需要与ubuntu仓库同步，　所以我们使用apt-get update
> 我们本身就是root身份，这里就不需要sudo了

  	root@472c96295678:/#	apt-get	update

> 4　同步完后，我们安装wget

  		root@472c96295678:/#	apt-get	install	-y	wget

> 5 我们安装后，使用which wget确认一下

    		root@472c96295678:/#	which	wget
				/usr/bin/wget

> 6 任何软件的安装都会修改镜像的基本组成，我们可以使用docker diff命令跟踪查看，我们打开第二个终端，使用 docker diff

    $	sudo	docker	diff	472c96295678

>   上面的命令会显示对于这个镜像的几百行的修改，这些修改包括仓库更新，wget二进制数据，和一些库文件

> 7 最后，我们最重要的一个步骤，docker commit 可以在一个正在运行的容器上，或者停止的容器上执行，
> 如果在一个运行的容器上运行， docker会 pause这个容器 避免数据不一致， 我们推荐在一个停止的容器上运行这个命令
> 我们使用下面命令将一个容器变成一个镜像

    			$	sudo	docker	commit	472c96295678	\
										learningdocker/ubuntu_wget
						sha256:a530f0a0238654fa741813fac39bba2cc14457aee079a7ae1f
						e1c64dc7e1ac25

> 我们的镜像使用 learningdocker/ubuntu_wget来命名


> 使用 docker images来查看我们的镜像

##### 以后台方式启动容器

> docker run 命令支持　-d选项，后台形式启动容器，我们使用前面的打印时间脚本，

    $	sudo	docker	run	-d	ubuntu	\
				/bin/bash	-c	"while	true;	do	date;	sleep	5;	done"
      0137d98ee363b44f22a48246ac5d460c65b67e4d7955aab6cbb0379ac421269b


> docker logs 可以查看输出

    $	sudo	docker	logs	\
    0137d98ee363b44f22a48246ac5d460c65b67e4d7955aab6cbb0379ac421269b
    Sat	Oct		4	17:41:04	UTC	2016
    Sat	Oct		4	17:41:09	UTC	2016
    Sat	Oct		4	17:41:14	UTC	2016
    Sat	Oct		4	17:41:19	UTC	2016