#### Streaming Server Events to Clients Asynchronously

> 前面章节，我们已经分析了rails render stack的里里外外，你已经了解到当一个请求到达控制器,控制器
> 收集请求信息给需要渲染的模板， 模板从解析器中得到，然后编译渲染，嵌入到布局文件中, 最后，你得到了ruby字符串形式的模板，这个字符串设置到http response中，返回给客户端

> 这种工作方式对大多数程序都不错。然而，有一些情况,我们需要发送我们的response以较小的字节片，有时这些较小的字节片，可能是无限的，我们需要一直需要发送，直到服务端和客户端链接中断为止。


> 无论什么时候我们发送一个response以字节片方式，我们都叫服务端数据流到客户端，因为rails以更传统的请求响应场景构建，流服务被添加并且不断被改良，这章我们来探究一下

> 为了探究streaming是如何工作的，我们编写一个rails plugin，当我们的css样式改变时，发送数据给浏览器端，浏览器将会使用这些信息重新加载当前页面的样式， 允许开发者看到当他们修改页面时，页面同时改变，不需要手动刷新页面。

> 因为这个插件有自己的控制器，asserts，routes和其他，我们将基于rails engines提供的强大能力，添加功能作为rails application一部分，另一方面打包成gem分享到其他项目


###### 5.1 Extending Rails with Engines

> rails 引擎允许我们的插件有自己的控制器，模型，帮助方法，试图，资源，和路由，就像一个符合规则的rails application.让我们生成一个插件叫做live_assets,使用rails 插件生成器，但是这次 我们传递--full 标记，用于生成model 控制器和路由目录

    $ rails plugin new live_assets --full

> 除了生成器给我们创建的常规文件，--full标签也生成下面这些文件

* 一个app目录，里面有controller,models,和其他在一个rails application里能看到的目录

* 一个config/routes.rb文件用于路由

* 一个空的test/integration/navigation_test.rb文件，用于添加我们的测试


>最重要的文件是lib/live_assets/engine.rb.让我们仔细看一下这个文件。

    live_assets/lib/live_assets/engine.rb
      module LiveAssets
        class Engine < ::Rails::Engine
        end
      end

> 创建了一个engine类，我们需要继承Rails::Engine并且确保我们的新engine尽可能快的被加载， 这个生成器已经替我们做了在lib/live_assets.rb中添加

    live_assets/lib/live_assets.rb
    require "live_assets/engine"
    module LiveAssets
    end

> 创建一个Rails::Engine十分类似创建一个Rails::Railtie.因为Rails::Engine相比较Rails::Railtie只不过多了一些默认初始化设置，和paths程序接口 我们下节看到


###### Paths

> 一个Rails::Engine没有硬编码路径，这意味着我们不需要放置我们的models和controllers在app/目录下，我们可以把他们放到任何位置。例如。我们配置我们的engine读取我们的控制器从lib/controllers目录，替代app/controllers，如下

      module LiveAssets
        class Engine < Rails::Engine
         paths["app/controllers"] = ["lib/controllers"]
        end
      end

> 我们也可以让rails读取我们的controllers从app/controllers和lib/controllers两个目录里

    module LiveAssets
      class Engine < Rails::Engine
        paths["app/controllers"] << "lib/controllers"
      end
    end

>这些路径有一样的语义在rails application里，如果你有一个控制器叫做LiveAssetsController在app/controllers/live_assets_controller.rb里，或者在lib/controllers/live_assets_controller.rb里，这个控制器都会被自动加载，当你需要这个控制器的时候， 不如要显示的required

> 现在，我们遵守传统路径,粘贴我们的控制器到app/controllers,所以不应用前面的改变，通过查看rails源码，我们可以检查所有自定义路径

![](11.png)

> 上面的代码片段展示了哪些指定的路径应该被热加载,哪个不被热加载，添加列表路径到
> locales,migrations等等，然而声明一个路径是不够的，还要用路径做些事情


######  Initializers

> 一个engine有几个初始化程序，负责启动engine， 这些初始化器相当底层，不会与你application的config/initializers下的任何一个混淆。 让我们看一个例子

    rails/railties/lib/rails/engine.rb
      initializer :add_view_paths do
        views = paths["app/views"].existent
        unless views.empty?
          ActiveSupport.on_load(:action_controller){ prepend_view_path(views) }
          ActiveSupport.on_load(:action_mailer){ prepend_view_path(views) }
        end
      end

> 初始化器负责添加我们的engine views,通常定义在app/views里，ActionController::Base 和 ActionMailer::Base一被加载 允许一个rails application使用engine中定义的模板， 可以看一下engine中的全部初始器，我们可以打开一个控制台，在test/dummy下，输入下面

    Rails::Engine.initializers.map(&:name) # =>
      [:set_load_path, :set_autoload_paths, :add_routing_paths,
      :add_locales, :add_view_paths, :load_environment_config,
      :append_assets_path, :prepend_helpers_path,
      :load_config_initializers, :engines_blank_point]

> 使用engine和使用rails application十分类似，我们都知道怎样构建实现我们的流插件

