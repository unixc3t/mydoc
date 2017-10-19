### Configuration


##### Location

> 配置变量可以是全局的或者指定某个阶段

* global
    config/deploy.rb
* stage specific
    config/deploy/<stage_name>.rb

#### Access

>每个变量被设置为一个指定值

    set :application, 'MyLittleApplication'

    # use a lambda to delay evaluation
    set :special_thing, -> { "SomeThing_#{fetch :other_config}" }

> 可以从配置中在任何时候得到变量值

    fetch :application
    # => "MyLittleApplication"

    fetch(:special_thing, 'some_default_value')
    # will return the value if set, or the second argument as default value

> 例如一个变量存储一个数组，可以使用append添加值,　尤其用在 :linked_dirs and :linked_files上

     append :linked_dirs, ".bundle", "tmp"
    

>使用remove从数组移除一个元素值

#### Variables

> 下面的变量可以被设置

* :application
      应用程序名字

* :deploy_to
      default：-> {"/var/www/#{fetch{:application}}"}
      这个路径是远程服务器上程序应该被部署到的路径

* :scm
      default:git
      使用的源码控制工具
      可以使用:git :hg :svn

* :repo_url
      版本仓库的url
      必须是一个有效的url
      例如 set :repo_url, 'git@example.com:me/my_repo.git'
      访问一个不是标注ssh端口的repo,set :repo_url,'ssh://git@example.com:30000/~/me/my_repo.git'
      使用svn和某一个分之，set :repo_url, -> { "svn://myhost/myrepo/#{fetch(:branch)}" }
       如果你使用除Git之外的工具将仓库移动到新的url，修改变量的值，已经部署过的远程服务器不能自动响应这个改动，你需要手动重新配置远程服务器上的仓库，(修改:repo_path),或者删除仓库，使用rm -rf repo

* ：branch 
      default: 'master'
      来自scm需要部署的分之

* :svn_username
      使用svn时的验证名称
* :svn_password
       使用svn时验证密码

* :svn_revision
      最新的版本是3.5
      当使用:svn是，设置你想部署的版本号

* repo_path
      default: -> {“#{fetch(:deploy_to)}/repo”}
      这个路径代码仓库在远程服务上的位置

*  repo_tree
      default： None 表示部署整个仓库
      被部署的仓库子树
      仅支持 git和hg

*  :linked_files
      default: []
      列出了部署期间，应用程序共享目录中被链接到release中的目录的文件

*  :linked_dirs
    default:[]
    列出了部署期间，被链接到releases目录的目录

* :defualt_env

    defautl: {}
    执行命令期间的默认shell环境
    可以被手动设置

*  keep_releases

    default: 5
    保存的回滚半本数

*  tmp_dir
    default: '/tmp'
    部署时。临时存储数据目录
    如果你是一个共享web书籍，可以设置为/home/user/tmp/capistrano

* local_user
     default: -> {Etc.getlogin}
     本地机器用户名用于revision log
  

* :pty 
    default: false
    用于sshkit

* :log_level
    defualt: :debut
    用于sshkit
    其他可选值　:info,:warn和:error

* :format
     default :airbrussh
     用于sshkit
     其他可选值　：ｄｏｔ和：ｐｒｅｔｔｙ
     