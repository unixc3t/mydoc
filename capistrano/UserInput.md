### User Input

> 用户输入在任务中或者配置阶段

    # used in a configuration
    ask(:database_name, "default_database_name")

    # used in a task
    desc "Ask about breakfast"
    task :breakfast do
       ask(:breakfast, "pancakes")
       on roles(:all) do |h|
          execute "echo \"$(whoami) wants #{fetch(:breakfast)} for breakfast!\""
       end
    end

> 当使用ask得到用户输入数据，可以传递echo:false防止输入数据被显示出来,这个选项用于防止敏感信息被显示

    ask(:database_password, 'default_password', echo: false)

> 符号可以作为参数传递，作为文本打印出来　用户输入被保存为变量

    ask(:database_encoding, 'UTF-8')
    # Please enter :database_encoding (UTF-8):

    fetch(:database_encoding)
    # => contains the user input (or the default)
    #    once the above line got executed
    
> 你可以使用ask设置server-或者role-指定配置变量

    ask(:password, nil)
    server 'example.com', user: 'ssh_user_name', port: 22, password: fetch(:password), roles: %w{web app db}

> 注意: ask不会立刻提示用户，这些询问会在第一次fetch相关设置时使用，意味着你能够询问许多变量，
> 但是仅有在这些变量被用在task中时才会提示用户输入