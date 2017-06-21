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
> 同样直接隐世创建collection,db.不存在collection名字.insert({})，collection会默认被创建

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

> mongodb存储的基本单元是文档，也就是document，文档是json对象

    db.collection.insert(
       <document or array of documents>,
      {
        writeConcern: <document>,
        ordered: <boolean>
      }
    )
> 删除文档 需要给定查询表达式,以json对象形式，如果不传递将清空整个collection

    db.collection.remove() 

> 只删除一行传递参数true

  db.stu.remove({name:'ja'},true)

> 整体替换更新 改谁？ 改成什么样？ 选项 ,新文档整体修改了旧文档

  db.st.update({name:'dalang'},{name:'wdalang'})

> 更新某个属性而不是整体,只修改一行

  db.st.update({name:'dalang'},{$set:{name:'wdalang'}})

* $set 改某个列
* $unset 删除某个列
* $rename 重命名个了列
* $inc 自动增长某个列

  db.stu.update({name:'dalang'},{$set:{name:'wudalan'},$unset:{age:1},$rename:{old,new},$inc:{age:12}})

> 添加multi:true 修改多行

  db.stu.update({name:'jack'},{$set:{gender:'f'}},{multi:true})

> upsert 没有就插入，有就修改
  db.stu.update({name:'jack'},{$set:{gender:'f'}},{upsert:true})

> $setOnInsert 表示当查找条件没找到就会插入，但是只插入了你修改的字段，这时候你还想同时添加其他字段，使用这个属性

      db.products.update(
      { _id: 1 },
      {
        $set: { item: "apple" },
        $setOnInsert: { defaultQty: 100 }
      },
      { upsert: true }
    )

> 显示所有文档的name属性值，不显示id

    db.stu.find({},{name:1,_id:0})

> 根据查询表达式显示匹配的文档的name 类似 select name from table where age=12

    db.stu.find({age:12},{name:1})

##### 查询表达式

> 属性为某个值的文档

    db.goods.find({goods_id:3})

> 查询某个属性不等于某个值的文档,只查出name

    db.goods.find({cat_id:{$nq:3}},{name:1})

> 查出价格大于3000上产品,小于用$lt，小于等于$lte,$nin是not in ,$in是 in ，$all指数组所有项都匹配
> $not 就是 not ，$or 就是or， $and 就是and

    db.goods.find({shop_price:{$gt:3000}},{name:1})

> 查出属性是4或11的数据

    db.goods.find({cat_id:{$in:[4,11]}})
> 不是4或11
    db.goods.find({cat_id:{$nin:[4,11]}})

> 价格大于100小于500产品

    db.goods.find({$and:[{shop_price:{$gte:100}},{shop_price:{$lte:500}}]});

> 属性不等于3也不等于11

    db.goods.find({$and:[{cat_id:{$ne:11}},{cat_id:{$ne:3}}]});
    db.goods.find({cat_id:{$nin:[3,11]}});
    db.goods.find({$nor:[{cat_id::11},{cat_id:3}]});

> $exists 某列存在则为真，$mod 满足某求余条件则为真，$type数据类型为某类型则为真

> 找出good_id值 对于求余数为0的数据

    db.goods.find({good_id:{$mod:[5,0]}})

> 找出有年龄属性的数据

    db.goods.find({age:{$exists:1})

> 找出年龄属性是字符串的数据

  db.goods.find({age:{$type:2}})

> 找出属性值都包含b,c的数据

  db.goods.find({bobby:{$all:[b,c]}})

> 使用$where条件,遍历每个document对象，取出属性来比较，效率低,但可读性好，方便写

    db.goods.find({$where:'this.shop_price>5000'}})

> 取出价格大于100并且小于300，或大于4000小于5000

  db.goods.find({$or:[{$and:[{price:{$gt:100}},{price:{$lt:300}}]},{$and:[{price:{$gt:4000}},{price:{$lt:5000}}]}]})

  db.goods.find({$where:'this.price>200 && this.price<300 or this.price > 3000 && this.price< 5000'})

> 正则匹配

    db.goods.find({goods_name:{$regex:/^nokia/}})
