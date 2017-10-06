#### 安装

> 参考官方文档，这里忽略安装erlang如果需要请查看这篇文章[安装erlang](https://gist.github.com/rubencaro/6a28138a40e629b06470)


> 添加仓库

    echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list

> 添加公钥

    wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
  
> 另一个

    wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -

> 更新

      sudo apt-get update

> 安装 

      sudo apt-get install rabbitmq-server –y

> 激活管理插件，并且重启

      sudo rabbitmq-plugins enable rabbitmq_management
      sudo service rabbitmq-server restart