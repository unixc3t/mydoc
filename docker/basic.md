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