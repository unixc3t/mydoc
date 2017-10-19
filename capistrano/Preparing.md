### Preparing Your Application

> 1 将你的代码提交到外部的代码仓库 ，capistrano支持git mercurial svn

> 2　将密码移除版本仓库

> 如果你将密码提交到版本仓库，你需要查看git帮助文档　移除这些密码

> 理想情况，应该将config/database.yml修改成config/database.yml.example。你和你的团队应该拷贝这个example文件到他们的开发机上，剩下的database.就不会使用，我们能够在部署时链接这个生成数据库配置到某个地方

> 原始的　database.yml应该被添加到.gitignore中

    $ cp config/database.yml{,.example}
    $ echo config/database.yml >> .gitignore

> 3 Initialize Capistrano in your application

    $ cd my-project
    $ cap install

> 创建一组文件

    ├── Capfile
    ├── config
    │   ├── deploy
    │   │   ├── production.rb
    │   │   └── staging.rb
    │   └── deploy.rb
    └── lib
         └── capistrano
              └── tasks

> 新的Capfile会自动引入任何.rake文件，在lib/capistrano/tasks目录下

> 4 Configure your server addresses in the generated files.

> 我们仅仅是模拟环境下工作，你可以假设config/deploy/production不存在，大多数情况是这样的

> capistrano 打破了常规的任务，形成角色的概念，讨论一个典型的rails 程序，我们粗略概括为3个角色
> web, app,db,这三个角色令人困惑，web和app服务器分界线有一点模糊，例如 使用在apache中使用passenger，实际上将你的app服务器嵌入到你的WEB服务器上。

> 示例文件生成如下

    set :stage, :staging

    # Simple Role Syntax
    # ==================
    # Supports bulk-adding hosts to roles, the primary
    # server in each group is considered to be the first
    # unless any hosts have the primary property set.
    role :app, %w{example.com}
    role :web, %w{example.com}
    role :db,  %w{example.com}

    # Extended Server Syntax
    # ======================
    # This can be used to drop a more detailed server
    # definition into the server list. The second argument
    # is something that quacks like a hash and can be used
    # to set extended properties on the server.
    server 'example.com', roles: %w{web app}, my_property: :my_value

    # set :rails_env, :staging

> 服务器可以使用两种方式定义,使用隐式的role语法，或者显示的使用server语法，这两种结果在一个或多个服务器上用于每个角色的定义，app和 db是占位符，如果你使用capistrano/rails-*插件，并且有一定意义
>但是如果你部署简单的，想更自由，可以删除他们，如果他们对你无意义。

> 两种类型都可以指定properties,与role或者server相关的。这些属性包括ssh 端口，账号，等等，也可以制定所以属性，

      # using simple syntax
      role :web, %w{hello@world.com example.com:1234}

      # using extended syntax (which is equivalent)
      server 'world.com', roles: [:web], user: 'hello'
      server 'example.com', roles: [:web], port: 1234


> 5 Set the shared information in deploy.rb.

> deploy.rb用于存放，对于每个环境的通用配置信息，例如repo url ，如下

      set :application, 'my_app_name'
      set :repo_url, 'git@example.com:me/my_repo.git'
      ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }