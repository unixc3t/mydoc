### Managing Application Events with Mountable Engines

> 从rails初期开始,人们就想知道他们的application发生了什么,一个请求中多少查询被执行了,一个请求花了多长时间.

> 为了解决这个都关注的问题，一些开源项目和服务,例如footnotes和bullet，Scout和New Relic's RPM,被创建.因为所有这些不同的工具都需要从rails中提取信息,rails不断进化提供一个统一的方式发布定于application里发生的事件,这就是ActiveSupport::Notifications  api

> 在这章里,我们使用这个api订阅所有通过我们application执行的actions，存储他们到mongodb里,然后我们使用rails engine创建一组路由,控制器,视图,浏览这些存储的数据, 这个engine可以在rails application之间分享，并且挂载到指定的终端


###### 7.1 Mountable and Isolated Engines

> 在前面，我们创建了一个rails engine用来发送流数据到我们的程序，除了提供了一个控制器，这个engine还添加了路由到我们的application里，像live_assets那样的帮助方法,某种程度上,这个engine可以用来直接扩展rails application使用它自己的组件，然而，这种行为不一定可取

> 拿我们将要在这章创建的插件举例,它将提供它自己的模型,控制器,和视图, 插件代码不断增加,路由数量开始增加,帮助方法也不断增加,如果我们的插件实现了一个show_paginated_results()帮助方法,rails使用了我们的插件，我们不想我们的帮助方法在rails程序里被使用, 因为帮助方法是我们插件内部方法,更糟的是,如果application有自己的show_paginated_results()帮助方法, 它将会被我们的插件的同名帮助方法覆盖,导致错误发生

> rails解决了这些问题, 提供了可挂载的和独立的engines，一个可挂载的engine使用他自己的路由替代直接添加路由到我们的application 路由里, 一个隔离的 engine 构建他自己的命名空间，使用它自己的模型，控制器，试图，资源，和帮助方法, 我们使用rails plugin 命令,传递--mountable选项 生成我们的可挂载engine

    $ rails plugin new mongo_metrics --mountable

> 使用--mountable选项生成了一个可挂载的独立的engine，我们可以通过检查几个不同的文件来观察到这一点。我们打开插件的config/routes.rb 文件:

    mongo_metrics/config/routes.rb
    MongoMetrics::Engine.routes.draw do
    end

> 注意路由是如何通过引擎产生的，比较前面extend rails with　Engine那节，直接在application里放置路由

    live_assets/config/routes.rb
    Rails.application.routes.draw do
      get "/live_assets/:action", to: "live_assets"
    end

> 因为路由不再被直接添加到application里，这个engine需要被直接挂载到application路由中， 通过插件命令已经被自动挂载到test/dummy里了

    mongo_metrics/test/dummy/config/routes.rb
    Rails.application.routes.draw do
     mount MongoMetrics::Engine => "/mongo_metrics"
    end

> 这就是挂载我们引擎需要的全部，为了使用一个独立的engine，我们需要直接声明它作为独立的，并且选择一个命名空间, --mountable选项自动生成引擎使用MongoMetrics作为作为独立命名空间

    mongo_metrics/lib/mongo_metrics/engine.rb
    module MongoMetrics
      class Engine < ::Rails::Engine
        isolate_namespace MongoMetrics
      end
    end

> 因为我们声明了一个独立的命名空间,我们的控制器模型和帮助方法都应该定义在这个命名空间里, 确保从application里隔离出来，现在定义在engine里的帮助文件不会自动被引入application里，反之亦然，application里的也不会影响插件里的，它还设置了许多便利措施， 如果我们使用 Active Record 他将在所有模型表前缀使用mongo_metrics_ 并且确保rails生成的models, controllers, 和 helpers也在命名空间下

>除了这些改变, rails plugin命令使用--mountable选项也成成了一组额外文件，像资源清单文件和一个MongoMetrics::ApplicationController位于app/controllers/mongo_metrics/application_controller.rb
> 使我们的engine更接近一个全新的Rails应用程序

> 我们的插件已经设置好了,我们下一步开始探 ActiveSupport::Notifications API并且存储这些通知到数据库


#### 7.2 Storing Notifications in the Database

> 在我们实现存储通知逻辑到数据库之前，我们先看一下Notifications api

###### The Notifications API

> Notifications api包含两个方法，instrument() 和 subscribe() .前者当我们提交和发布一个事件时调用,例如action controller处理 如下

    ActiveSupport::Notifications.instrument("process_action.action_controller",
        format: :html, path: "/", action: "index") do
      process_action("index")
    end

> 第一个参数是被发布事件名称, 在这里我们叫做process_action.action_controller,第二个参数是一个hash，包含了关于这个事件的信息,叫做payload ,为了订阅这些通知，我们仅仅需要传递这个事件名字和代码块给subscribe() 如下

    event = "process_action.action_controller"
    ActiveSupport::Notifications.subscribe(event) do |*args|
      # do something
    end

> args是一个数组有五项

* name: 事件名称字符串形式
* started_at: 事件开始时的Time对象
* ended_at: 事件结束时的Time对象 
* instrumenter_id: 包含提交事件的唯一id
* payload: 提交事件时作为payload的信息，是一个hash形式

> 这就是我们需要知道的全部，下一步，我们看一下我们要存储通知的数据库

