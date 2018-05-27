#### Data volume

> 构建一个简单的镜像，挂载dockerfile所在的目录

    //dockerfile
    FROM UBUNTU:16.04
    VOLUME /MountPointDemo

    $ docker build -t mount-point-demo .

> 查看详细配置

    docker	build	-t	mount-point-demo	.
    "Volumes": {
                "/MountPointDemo": {}
            },

> 交互模式启动这个镜像

    docker	run	--rm	-it	mount-point-demo

    root@3f4a6c7d81b2:/# ls -ld /MountPointDemo/
    drwxr-xr-x 2 root root 4096 May 27 01:58 /MountPointDemo/

> data volume是docker文件系统的一部分,并且被挂载如下所示

    root@3f4a6c7d81b2:/# mount |  grep MountPointDemo
    /dev/sda2 on /MountPointDemo type ext4 (rw,relatime,errors=remount-ro,data=ordered)
  
>我们在host上打开一个新终端，然后执行docker inspect 容器id

    $ docker inspect -f '{{json .Mounts}}' 3f4a6c7d81b2 
    [{"Type":"volume",
    "Name":"2258769a59166ce27270a61e235676b3b934c4df4ed29278414c6d9267310b9d","Source":"/var/lib/docker/volumes/2258769a59166ce27270a61e235676b3b934c4df4ed29278414c6d9267310b9d/_data","Destination":"/MountPointDemo",
    "Driver":"local",
    "Mode":"",
    "RW":true,
    "Propagation":""}]

> data volume 映射到docker host目录，这个目录是可读可写模式，有docker引擎自动创建，自从1.9版本开始，volumes可以通过最外层的volume命令管理
> 上面演示了，volume在dockerfile中的作用， 我们可以使用docker run的 -v <container mount point path>子命令，

    docker run -v /MountPointDemo -it ubuntu:16.04

>，以上的两种场景，docker在Host上自动创建了一个/var/lib/docker/volumes目录,并且挂载到容器中，当使用docker rm移除容器时，引擎不会自动移除volume
>, 如果你想移除容器的同时移除volume,使用 docker rm -v 容器id

    	docker	rm	-v	8d22f73b5b46	

> 如果容器正在运行，你可以添加-f选项，来移除容器和volume
    	docker	rm	-fv	8d22f73b5b46	

