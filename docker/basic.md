##### 1 查看docker状态
   
   sudo	service	docker	status	

>> 结果：

   正常Active列: active，  
   问题Active列: inactive或者maintenance 

>>解决 
    
    重启 sudo	service	docker	restart	

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
