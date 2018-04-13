### understanding Docker Hub

#####注册账号密码

>在下面网址注册
    https://hub.docker.com/ 


> 可以在命令行登录账号密码

    docker login
    Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
    
    Username: rudy
    Password: 
    Login Succeeded


##### Pushing	images	to	Docker	Hub

> 我们在本地构建镜像，然后使用下面命令发布到Hub

    docker	commit
    docker	commit with dockerfile

> 实例
> 我们使用rudygeek命名运行的容器，使用ubuntu作为基础镜像，执行下面命令

      docker run -i --name="rudygeek" -t ubuntu /bin/bash
      Unable to find image 'ubuntu:latest' locally
      latest: Pulling from library/ubuntu
      d3938036b19c: Pull complete 
      a9b30c108bda: Pull complete 
      67de21feec18: Pull complete 
      817da545be2b: Pull complete 
      d967c497ce23: Pull complete 
      Digest: sha256:c09309f66d6057443818be3fdf6870d2a85300387aa50a76ab079dc83df54f22
      Status: Downloaded newer image for ubuntu:latest

> 我们然后创建一个新目录和文件

      root@9534c6671747:/# mkdir mynewdir
      root@9534c6671747:/# ls
      bin  boot  dev  etc  home  lib  lib64  media  mnt  mynewdir  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
      root@9534c6671747:/# cd mynewdir/
      root@9534c6671747:/mynewdir# echo 'this is my new container to make image and then push'
      this is my new container to make image and then push
      root@9534c6671747:/mynewdir# ls
      root@9534c6671747:/mynewdir# ll
      total 8
      drwxr-xr-x 2 root root 4096 Apr 13 03:09 ./
      drwxr-xr-x 1 root root 4096 Apr 13 03:09 ../


> 再打开一个终端，这时容器正在运行，使用docker commit 构建镜像，

      docker commit -m="NewImage for second edition" rudygeek rudygeek/image
      sha256:0b00767b2fffcec696767a27cb652208cf01ebb6c96b6a5397f43d8f612c66a7

> 第一个rudygeek是容器名， 第二个rudygeek,这里是你自己在docker hub上的账户名

> 查看镜像

    $ docker images -a
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    rudygeek/image      latest              0b00767b2fff        58 seconds ago      113MB
    ubuntu              latest              c9d990395902        8 hours ago         113MB


> 在终端登录docker hub ，按照前面讲的

    docker login

> 推送镜像到 docker hub

    docker push rudygeek/image
    The push refers to repository [docker.io/rudygeek/image]
    ce9c4daebda4: Pushed 
    a8de0e025d94: Mounted from library/ubuntu 
    a5e66470b281: Mounted from library/ubuntu 
    ac7299292f8b: Mounted from library/ubuntu 
    e1a9a6284d0d: Mounted from library/ubuntu 
    fccbfa2912f0: Mounted from library/ubuntu 
    latest: digest: sha256:990a7702970caead9a20eed82659aac4ad27d7157578410a54bb01406e218d24 size: 1564


> 然后登录docker hub验证是否推送成功


> 测试结束，我们移除本地镜像，首先我们先停止容器，然后删除容器，再移除镜像

    $ docker stop rudygeek
    rudygeek
    ~ > rudy@rudy [php:7.2.2 -phpbrew]
    $ docker rm rudygeek
    rudygeek
    ~ > rudy@rudy [php:7.2.2 -phpbrew]
    $ docker rmi rudygeek/image
    Untagged: rudygeek/image:latest
    Untagged: rudygeek/image@sha256:990a7702970caead9a20eed82659aac4ad27d7157578410a54bb01406e218d24
    Deleted: sha256:0b00767b2fffcec696767a27cb652208cf01ebb6c96b6a5397f43d8f612c66a7
    Deleted: sha256:7fa61b9da0b2cca151f5fdaf13b1a18d7b8347c8cabcf6e18ead5d19c0c0a4df

> 现在我们拉取docker hub上面的镜像，然后运行， newcontainerforhub是容器名称

    $ docker run -i --name="newcontainerforhub" -t rudygeek/image /bin/bash
    Unable to find image 'rudygeek/image:latest' locally
    latest: Pulling from rudygeek/image
    d3938036b19c: Already exists 
    a9b30c108bda: Already exists 
    67de21feec18: Already exists 
    817da545be2b: Already exists 
    d967c497ce23: Already exists 
    6bce7624a656: Pull complete 
    Digest: sha256:990a7702970caead9a20eed82659aac4ad27d7157578410a54bb01406e218d24
    Status: Downloaded newer image for rudygeek/image:latest
    root@56c6c2a3a1f1:/# 


> 我们使用rudygeek/image镜像创建了一个容器，本地没有找到。所有去docker hub上拉取，

> 最后我们从docker hub上删除在谷歌镜像

> 注意，删除时输入 rudygeek/image ，这个名字后面的image


##### 使用dockerfile构建实例


    ###########################################	
    #	Dockerfile	to	build	a	new	image	
    ###########################################	
    #	Base	image	is	Ubuntu	
    FROM	ubuntu:latest
    #	create	'mynewdir'	and	'mynewfile'	
    RUN	mkdir	mynewdir	
    RUN	touch	/mynewdir/mynewfile	
    #	Write	the	message	in	file	
    RUN	echo	'this	is	my	new	container	to	make	image	and	then	push	to	hub' > /mynewdir/mynewfile	

> 执行指令

    $ docker build -t="rudygeek/autoimage" .
    Sending build context to Docker daemon  1.479MB
    Step 1/4 : FROM ubuntu:latest
    ---> c9d990395902
    Step 2/4 : RUN  mkdir   mynewdir
    ---> Running in 28f54338384b
    Removing intermediate container 28f54338384b
    ---> 30e53a858490
    Step 3/4 : RUN  touch   /mynewdir/mynewfile
    ---> Running in 41a31c45c0f0
    Removing intermediate container 41a31c45c0f0
    ---> 55b29c0ca9fb
    Step 4/4 : RUN  echo    'this   is      my      new     container       to      make    image   and     then    push    to      hub' > /mynewdir/mynewfile
    ---> Running in c19d0a03844f
    Removing intermediate container c19d0a03844f
    ---> 584013207f96
    Successfully built 584013207f96
    Successfully tagged rudygeek/autoimage:latest

> 然后使用这个镜像运行


    $ docker run -i --name="dockerfile" -t rudygeek/autoimage
    root@d21d0ab3d588:/# ls
    bin  boot  dev  etc  home  lib  lib64  media  mnt  mynewdir  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
    root@d21d0ab3d588:/# ls mynewdir/
    mynewfile

    root@d21d0ab3d588:/# cat /mynewdir/mynewfile 
    this	is	my	new	container	to	make	image	and	then	push	to	hub


> 重新终端登录docker hub 上传镜像


    $ docker push rudygeek/autoimage
    The push refers to repository [docker.io/rudygeek/autoimage]
    25e005706bd8: Pushed 
    76588e80d13c: Pushed 
    ae933b7ba0c8: Pushed 
    a8de0e025d94: Pushed 
    a5e66470b281: Pushed 
    ac7299292f8b: Pushed 
    e1a9a6284d0d: Pushed 
    fccbfa2912f0: Mounted from library/ubuntu 
    latest: digest: sha256:29f7546bcd2e501849ea4e34e5c356c6f9efc971f9659d110c54bec1f076e657 size: 1978

> 然后登录docker hub查看是否上传成功


##### Automating	the	build	process	for images

> 我们可以在本地构建，docker hub也有能力自动构建，使用来自github和bitbucket的dockerfile文件 自动构建支持public和private仓库,