【*  配置文件方式启动 docker mongo

> 先创建  host目录，将数据库目录和日志目录创建好

    host主机:  /home/rudy/pro/mongodb

>   mongod目录中有data/db和log/mongod.log和mongod.conf,这里注意，data目录和mongod.log权限问题，需要o+wx权限


    .
    ├── data
    |    └── db
    ├── log
    │   └── mongod.log
    └── mongod.conf

>下面是mongod.conf配置文件的内容，/etc/mongo是docker容器的mongo目录，这个目录我们在运行时，使用-v把他映射到host目录,所以
> 把/etc/mongo理解成host的映射的目录

    systemLog:
      destination: "file"
      path: "/etc/mongo/log/mongod.log"
      logAppend: true
    storage:
      dbPath: "/etc/mongo/data/db"
      directoryPerDB: true

* 启动命令


    docker run --name mongo_rudy  -p 27017:27017 -v /home/rudy/pro/mongodb:/etc/mongo -dit mongo  --config /etc/mongo/mongod.conf