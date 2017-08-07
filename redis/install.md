#### 安装配置

> 下载 http://download.redis.io/releases/redis-4.0.1.tar.gz
> 解压后进入目录
> 直接make 不需要./config
> 也可以选择执行 make test 测试一下
> 指定安装目录 
    make PREFIX=/usr/local/redis  install


#### 安装后文件介绍

* redis-benchmark  redis的性能测试工具
* redis-check-aof  检查aof日志的工具
* redis-check-rdb  检查rbd日志的工具
* redis-cli        连接客户端的工具
* redis-server     redis服务进程

#### 启动

> 复制配置文件到安装目录 cp 源码目录/redis.conf /usr/local/redis

> 使用redis-server启动

    redis-server  /配置文件目录

> redis client链接
    redis-cli

> 将redis配置文件 daemonize 修改为yes，设置为后台运行

### ubuntu ppa安装

> 终端添加仓库 

    sudo add-apt-repository ppa:chris-lea/redis-server

> 然后安装

    sudo apt-get install redis-server

> 安装后，重启电脑。redis自动启动，直接使用redis-cli链接
> 默认配置文件在 /etc/redis目录下
