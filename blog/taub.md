## Translating Applications Using Key-Value Back Ends

> 国际化框架(i18n)在rails 2.2版本被加入，在增加rails被世界各地广泛采用中扮演重要角色。虽然我们可以简单的创建采用不同语言的程序，但是最大问题就是维护这些翻译数据,一些公司利用翻译团队，其他的采用协作方式允许用户自行翻译程序，这两种情况下，开发一个Web接口来帮助翻译处理是很常见的。

> 默认I18n在YAML文件中存储在翻译数据。通过web接口管理这些数据很难，事实上,使用yaml需要一个机制，当yml文件更新了，需要告诉服务器同步重新加载yaml文件,你可以想象得到,这样的解决方案很快会变得很复杂

> 幸运的是,i8n框架带来了不同的后端支持，允许我们存储翻译数据在其他地方不仅仅是在yaml文件里， 这使得通过web接口更容易管理翻译数据，即时更新网站翻译。不需要同步yaml文件。缺点是，从数据库检索翻译数据替代内存hash，会影响性能

> 使用key-value存储方案，可以既简单又满足性能需求，在这章，我们存储翻译数据在redis中，使用key-value后端检索翻译数据。此外，我们将构建一个简单的sinatra application来管理这些翻译数据

> 和前面不一样，我们将开发一个完整的rails app替代开发插件， 在学习和分析了railties和engine之后，我们现在可以从不同的视角开发rail app

#####8.1 Revisiting Rails::Application

> 前面章节,我们讨论了Rails::Engine和展示了它类似一个rails application的行为， 当我们看rails source源码的时候,我们看到如下代码

    module Rails
      class Application < Engine
        # ...
      end
    end

> rails::Application类继承了rails::Engine, 这意味着一个application能做所有engine能做的事，附加了一些特殊行为

* application负责所有引导(例如读取active support ，设置加载路径,配置logger)

* application有自己的路由和中间件栈

* application 负责初始化所有插件

* 如果请求改变，application 负责重新加载代码和路由 

* application在适当时候加载任何和生成器

> 为了近距离了解这些功能，让我们开发一个翻译app

    $ rails new translator

> 我们讨论了onfig/boot.rb , config/application.rb ,和 config/environment.tb 的职责，实际上
> boot文件负责设置我们的加载路径，application文件负责定义我们的rails applciation,environment文件最终调用initialize!()方法初始化app.

    translator/1_app/config/environment.rb
    # Load the rails application.
    require File.expand_path('../application', __FILE__)
    # Initialize the rails application.
    Translator::Application.initialize!

> 在前面，Extending Rails with Engines 那节，我们已经展示engines提供的一组初始化程序，用来驱动engine启动，所以rails app提供这样的初始化程序也不奇怪

    module Translator
      class Application < Rails::Application
        initializer "translator.say_hello" do
          puts "hello on initialization"
        end
      end
    end

> 查看rails app中有效的初始化程序，在我们新生成的app里打开rails console 输入下面

  Rails.application.initializers.map(&:name)

> 这里不一样的地方是application不仅包含它自己的初始化程序，也包含定义在railties和engines的，rails app初始化就是一个一个的执行这些程序

> rails application其他所有都是围绕boot,application,environment构建，如果我们打开rakefile 我们看到下面代码

    translator/1_app/Rakefile
    require File.expand_path('../config/application', __FILE__)
    Translator::Application.load_tasks

> 首先,定义了rails application的application文件被引入,接下来，load_tasks()被调用,加载所有app提供的的rake 任务，插件，和rails自身， 注意我们此时没有引入environment文件,这让基本的rake命令快速运行，因为他们不用来初始化app，他们只是定义它。

> 然而许多任务需要app被初始化，例如rake db:migrate仅在database被配置后工作，这个任务引入config/environment.rb 初始化我们的app, 无论合适你需要在rake任务中访问数据库或者任何你的app的类，你都需要依赖:environment任务

> 最后，我们看一下我们app根目录下的config.ru文件，它require 这个environment文件，初始化app，运行当前app，作为一个rack application

    translator/1_app/config.ru
    # This file is used by Rack-based servers to start the application.
    require ::File.expand_path('../config/environment',
    run Rails.application

> app 初始化过程被分解到许多文件里，但是仅限于我们需要不同的钩入点,config.ru文件需要整个environment提前加载，但是rakefile加载则不需要，然而，没有什么能阻止我们将所有这些文件合并到单个文件Rails应用程序中！

#### The Single-File Rails Application

>构建一个rails app到一个单独文件，帮助我们理解如何设置和初始化rails， 让我们看一个但文件rails app范例并且讨论一下。创建一个空的目录，然后添加一个config.ru文件，输入下面内容

    translator/config.ru
    # We will simply use rubygems to set our load paths
    require "rubygems"
    # Require our dependencies
    require "rails"
    require "active_support/railtie"
    require "action_dispatch/railtie"
    require "action_controller/railtie"

    class SingleFile < Rails::Application
      # Set up production configuration
      config.eager_load = true
      config.cache_classes = true

      # A key base is required for our app to boot
      config.secret_key_base = "pa34u13hsleuowi1aisejkez12u39201pluaep2ejlkwhkj"
      # Define a basic route
      routes.append do
        root to: lambda { |env|
          [200, { "Content-Type" => "text/plain" }, ["Hello world"]]
        }
      end
    end
    SingleFile.initialize!
    run Rails.application

> 我们通过在config.ru目录下执行rackup命令初始化application. 打开你的浏览器，输入地址localhost:9292，你会看到"hello world"显示出来

> 一个单文件rails  app 与常规的rails app 没有太多不同,设置加载路径，这里我们使用rubyGems替代了bundler, 然后通过挨个读取依赖，替代了通常在config/application.rb中的require "rails/all"
> 最后定义初始化程序，运行app

> 注意rails 需要我们定义一些配置选项, 例如confsig.secret_key_base，这对于我们已经很熟悉，仅有的新方法就是routes.append

> 通常开发者访问路由的唯一方法是draw().可以在config/routes.rb中看到

    Translator::Application.routes.draw do
      # ...
    end

> draw()方法使用代码重载方式工作，每次路由文件改变， 之前的路由都被清楚，然后被重现加载config/routes.rb中的路由和插件。 然而，有一些情况, 一些路由可能定义在初始化阶段或者一个不会被重新加载的文件里， 对于这种情况，rails提供了 routes.prepend和routes.append方法定义这样的路由

> 例如 如果你使用routes.draw定义路由在config/application.rb里面，在开发阶段不会被重新加载，你在config/routes.rb的改变会立刻导致路由重新被加载，但是定义在application里的就会被遗忘

> 对于单个文件的rails app的请求和其他rails app请求一样, web服务器调用SingleFile#call()方法，穿过中间件栈到达路由，在我们的例子里，路由简单的匹配根action

> 我们现在理解了application的职责，并且知道如何构建railties和engines，现在是时候回头构建使用i18n api我们的翻译后端