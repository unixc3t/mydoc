#### Structure

> capistrano 在远程服务器上使用严格的目录结构来组织代码和部署需要的相关数据,根目录可以使用配置变量
> :deploy_to 来设置

> 假设你的config/deploy.rb包含下面

    set :deploy_to, '/var/www/my_app_name'

>  /var/www/my_app_name 里面的目录结构如下

    ├── current -> /var/www/my_app_name/releases/20150120114500/
    ├── releases
    │   ├── 20150080072500
    │   ├── 20150090083000
    │   ├── 20150100093500
    │   ├── 20150110104000
    │   └── 20150120114500
    ├── repo
    │   └── <VCS related data>
    ├── revisions.log
    └── shared
        └── <linked_files and linked_dirs>

> current 是一个软链接(参考linux软连接概念)指向了最新的release版本,当成功部署后这个链接指向最新的部署成功版本，否则指向上一个部署成功的版本

> releases 存储了所有部署的文件在一个以时间戳命名的文件夹里, current链接指向了这些文件夹

> repo 存储了版本控制配置信息，例如git仓库的原始内容

> revisions.log用来记录每次的部署和回滚, 每条记录由时间戳和执行者组成(执行者是:local_user的值)vcs的分分支名和相关版本号也会列出

> shared 包含了linked_files和linked_dirs被链接到每个release版本，这些持久化数据跨越deployments和releases，应该存放例如数据库配置文件，静态资源和持久化数据

> 应用程序被完整的包含在:deploy_to路径中，如果你计划部署多个程序到同一个服务器，选择不同的:deploy_to路径