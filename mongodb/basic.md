> 文件说明

* mongorestore 导入bson数据
* bsondump  导出bson结构
* mongo  客户端程序交互终端
* mongod 服务端程序类似mysqld,数据库核心进程
* mongodump  整体数据库导出类似mysqldump
* mongoexport 导出json,csv,tsv格式数据、
* mongoimport 导入json,csv,tsv数据
* mongos 查询路由器，集群时用
* mongotop 诊断工具
* mongostats 状态查看

##### 使用

> 启动mongod服务,制定数据库目录和log文件位置

    /bin/mongod --dbpath fold --logpath file --fork(后台模式运行) --port 27017

> 编写一个bash脚本方便使用

    #!/bin/sh 

    mongod --dbpath  /home/rudy/pro/mongodb3.4.5/database --logpath /home/rudy/pro/mongodb3.4.5/log/db.log --fork

> 然后启动客户端

  /bin/mongo

> 常用命令

   use database 选择数据库
   show dbs 查看当前数据库
   show tables/collections 查看数据库的表 mongodb中的表叫做collection

> mongodb中可以隐世创建数据库，当你use一个不存在的库，然后在这个库下创建collection就可以创建这个库

   use test
   db.createCollection('user')

> 插入一条数据,可以自己指定_id，或者让系统自动生成

    db.user.insert({name:'jack'})

> 查看数据

    db.user.find()

> 删除一个collection

  db.user.drop()

> 删除一个数据库 database

  db.dropDatabase //db指代use database时的database