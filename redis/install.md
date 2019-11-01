#### 安装配置

> 下载 http://download.redis.io/releases/redis-4.0.1.tar.gz
> 解压后进入目录
> 直接make 不需要./config
> 也可以选择执行 make test 测试一下
> 指定安装目录 
    make PREFIX=/usr/local/redis  install

> docker run --name myredis -p 6379:6379 -v /home/rudy/pro/database/redis/data:/data  -v /home/rudy/pro/database/redis/conf/redis.conf:/etc/redis/redis.conf  --privileged=true  -d redis redis-server


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


#### 常用key操作



> 查询相应的key pattern，pattern可以是模糊查询,* 匹配任意字符,? 匹配单个字符,[] 匹配中括号中任意一个字符

    keys * //得到当前所有key
    keys s*
    keys site
    keys sit[ey]
    keys si?e

> randomkey 随机得到一个key

    randomkey

> 查看key类型,string ,link ,set, order set,hash

    type key

> 判断key 是否存在

    exists key

> 删除给定的一个或多个Key(多个key用空格隔开),删除成功返回1，当key不存在时，返回0；例：del no-exist-key foo。


#### redis结构

> redis默认创建16个 database,从0开始编号。到15，默认是在0号数据库操作

> 选择编号１数据库

   select 1

> 将key移动到指定数据库中;例：move foo 1，将foo从db0移动到db1，移动陈工返回1，移动失败返回0。

    move key db

> 为key设置超时时间（单位：秒），当key过期时，会被系统自动删除；例：expire foo 30。

    expire key seconds

> 以秒为单位返回key的剩余生存时间（time to live），当key不存在时返回-2，当key存在未设置生存时间时返回-1，过期返回－１；例：ttl foo。

    ttl key



>　移除指定key的生存时间，永久有效
     persist key
