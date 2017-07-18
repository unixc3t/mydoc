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



#### 5.2 Live Streaming

> 看一下streaming如何工作，让我们创建一个控制器叫做LiveAssetsController,文件位置app/controllers/live_assets_controller.rb，引入了ActionController::Live功能，发送hello world间断。

    live_assets/1_live/app/controllers/live_assets_controller.rb
    class LiveAssetsController < ActionController::Base
      include ActionController::Live
      def hello
      while true
      response.stream.write "Hello World\n"
      sleep 1
      end
      rescue IOError
      response.stream.close
      end
    end

> 我们的控制器提供了一个action叫做hello(),每秒发送一个Hello world, 如果有任何原因，导致链接在server和client中断，response.stream.write会失败抛出IOError. 我们需要捕获它，关闭流

> 我们需要一个路由配置

    live_assets/1_live/config/routes.rb
      Rails.application.routes.draw do
      get "/live_assets/:action", to: "live_assets"
      end


> 我们准备尝试发送流到客户端,然而，因为rails engine不能运行自己，我们需要启动它在test/dummy中，此外流功能不会工作在webrick中，webrick是ruby和rails使用默认服务器，webrick将缓存我们发送到客户端响应,
> 所以我们不会看到任何东西，对于这个原因，我们使用puma，添加到我们的gemspec作为开发依赖

> 最后。我们进入test/dummy目录，执行rail s ,rails现在启动 替代了webrick

    Booting Puma
    Rails 4.0.0 application starting in development on http://0.0.0.0:3000
    Call with -d to detach
    Ctrl-C to shutdown server
    
>大多数浏览器会尝试缓存流相应，或者需要一段时间，他们决定是否要展示我们的内容， 所以测试我们的流发送到末端，我们使用curl 通过命令行

    $ curl -v localhost:3000/live_assets/hello
    > GET /live_assets/hello HTTP/1.1
    > User-Agent: curl/7.24.0 (x86_64-apple-darwin12.0)
    > Host: localhost:3000
    > Accept: */*
    >
    < HTTP/1.1 200 OK
    < X-Frame-Options: SAMEORIGIN
    < X-XSS-Protection: 1; mode=block
    < X-Content-Type-Options: nosniff
    < X-UA-Compatible: chrome=1
    < Cache-Control: no-cache
    < Content-Type: text/html; charset=utf-8
    < X-Request-Id: f21f8c0d-d496-4bfa-944c-cd01b44b87ee
    < X-Runtime: 0.003120
    < Transfer-Encoding: chunked
    <
    Hello World
    Hello World


> 每秒，你都会看到Hello world 出现在屏幕上，这意味着流推送正在工作， 按住CTRL+C中断传输，我们进一步学习一个更复杂的例子

###### Server-Sent Events

> 开发者总是需要在浏览器里收到服务端的更新，很长一段时间里，轮询是最通用的解决这个问题的技术。在轮询的时候，浏览器频繁发送请求到服务器端，询问是否有新数据,如果没有新数据，服务端返回一个空响应，浏览器再开始新的请求,根据频率，浏览器最终向服务器发送许多请求，产生大量开销。

>不断发展,长轮询技术出现,使用这个技术,浏览器定期的发送请求给服务端,如果没有更新服务器端在发送空响应之前，等待一段时间，虽然比传统的轮询执行的好一些，浏览器之间存在交叉兼容性问题。
> 此外,许多代理和服务端如果一段时间没有通讯就会发生链接丢失，这种方法就失效了


> 为了解决开发者的需求，html标准引入了两个api， Server Sent Events (SSE) 和 WebSockets，WebSockets允许客户端和服务器端交换信息在同一个连接上，但是因为是新协议，或许需要改变你的开发栈来支持他,两一个，Server sent Event，是一个单向通讯通道。从服务端到客户端,可以使用任何web服务器，只要能够支持流响应(stream response),基于这些原因sse使我们这章节选择的方案。

> sse基础就是event stream format，下面是一个对http请求的事件流响应


    HTTP/1.1 200 OK
    Content-Type: text/event-stream

    event: some_channel
    data: {"hello":"world"}

    event: other_channel
    data: {"another":"message"}

> 数据的界定通过两个新行，每个信息有一个event和他关联的数据，在这个例子中, 数据时json，但它也可以是文本，当流推送的时候，我们需要从服务端返回一个格式, 让我们创建一个新的action叫做sse在我们的LiveAssetsController里，发送一个reloadcss事件，每秒钟发送一次

    live_assets/1_live/app/controllers/live_assets_controller.rb
    def sse
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Content-Type"] = "text/event-stream"
    while true
    response.stream.write "event: reloadCSS\ndata: {}\n\n"
    sleep 1
    end
    rescue IOError
    response.stream.close
    end

> 类似我们第一个action,除了现在我们需要设置适当的响应内容类型，并且关闭缓存，服务端已经准备好。我们来写客户端，使用js:

    live_assets/1_live/app/assets/javascripts/live_assets/application.js
    window.onload = function() {
    // 1. Connect to our event-stream
    var source = new EventSource('/live_assets/sse');
    // 2. This callback will be triggered on every reloadCSS event
    source.addEventListener('reloadCSS', function(e) {
    // 3. Load all CSS entries
    var sheets = document.querySelectorAll("[rel=stylesheet]");
    var forEach = Array.prototype.forEach;
    // 4. For each entry, clone it, add it to the
    //
    document and remove the original after
    forEach.call(sheets, function(sheet){
    var clone = sheet.cloneNode();
    clone.addEventListener('load', function() {
    sheet.parentNode.removeChild(sheet);
    });
    document.head.appendChild(clone);
    });
    });
    };


> 我们的javascript文件链接我们的后端，每个监听reloadcss事件,在页面重新加载所有的样式，我们的资源文件定义在,app/assets/live_assets/application.js，这个结构是需要的，因为rails仅仅预编译资源文件匹配application.*。因为他们是仅有的被预编译的文件，这样的文件通常被引入所有存在的文件里， 那就是为什么叫做manifests.

> 最后我们创建一个帮助方法，让application读取我们资源更方便

    live_assets/1_live/app/helpers/live_assets_helper.rb
    module LiveAssetsHelper
    def live_assets
    javascript_include_tag "live_assets/application"
    end
    end

> 使用我们的server sent events机制，我们到test/dummy创建一个控制器

    live_assets/1_live/test/dummy/app/controllers/home_controller.rb
    class HomeController < ApplicationController
    def index
    render text: "Hello", layout: true
    end
    end

    live_assets/1_live/test/dummy/config/routes.rb
    Dummy::Application.routes.draw do
    root to: "home#index"
    end

> 修改我们的布局引入engine资源 但是仅在开发模式

    live_assets/test/dummy/app/views/layouts/application.html.erb
    <!DOCTYPE html>
    <html>
    <head>
    <title>Dummy</title>
    <%= stylesheet_link_tag "application", media: "all" %>
    <%= javascript_include_tag "application" %>
    <%= live_assets if Rails.env.development? %>
    <%= csrf_meta_tags %>
    </head>
    <body>
    <%= yield %>
    </body>
    </html>

> 重启虚拟app(dummp目录下的app)，使用浏览器浏览localhost:3000,如果你的浏览器有网络面板,
> 可以看http请求，通过浏览器发送的，你或许期望每个样式表每秒钟都被重新加载,但是没有发生,在下图

![](12.png)

> 即使puma是一个多线程服务器,rails允许仅有一个线程在一个时间点运行，我们需要改变虚拟程序允许并行计算

    live_assets/test/dummy/config/application.rb
    config.allow_concurrency = true

> 因为浏览器与web服务器链接，然后等待服务器相应请求，我们需要关闭浏览器之前重启web服务器,关闭浏览器，重新启动服务器，然后重新打开地址loalhost:3000;我们可以看到样式表没秒都在重新加载
>为了验证我们的样式表被重新加载,我们编辑test/dummy/app/assets/stylesheets/application.css文件，观察发生的改变，不需要刷新页面，尝试设置文本颜色如下

    body { color: red; }

> 如你所见，我们的server-sent events推送流工作了，然而，我们还是可以做一些改善，首先，我们想仅仅修改样式仅当文件系统上的文件内容发生改变时，而不是每秒都重新加载，观察这些变化应该是会提高效率的，如果我们有5个页面，我们不想为我们打开的所有页面都去查询文件系统，我们将有一个主文件系统侦听器实体，每个请求都可以订阅。

> 第二个问题是我们的代码目前没有任何测试，这种特性其实很难编写测试，因为流发送无限的数据，为了可以直接从控制器测试，我们需要将存在的组件变得更小，更可测试

> 最后，因为我们使用了config.allow_concurrency，我们需要理解这样的设置如何影响基于stremaing部署的applications，所以我们有很多工作要做

#### 5.3 Filesystem Notifications with Threads

> 一个rails程序默认产生三个资源目录,app/assets,lib/assets,和vendor/assets.我们的资源应该被分割到这些目录使用和我们分割代码一样的方式,app目录应该包含直接和我们程序相关的资源，lib目录包含独立js或者css组件，组件使用远超我们的application. vendor目录包含第三方文件

> 我们想监视这些目录上的文件的改变，一种选择是每秒或更少地手动检查每个目录中每个文件的修改时间。这就是文件系统轮询，轮询或许是个好的开始点，但是资源文件不断增长，会变得非常耗费CPU

> 幸运的是，大多数系统提供一个通知机制，为文件系统改变,我们简单传递操作系统所有我们想监视的目录，并且如果一个文件被添加，移除，修改，我们的代码将会被通知,这个listen gem提供了所有主流系统通知机制的api调用，考虑我们的需求有一个实体监视文件系统，我们的请求可以订阅，让我们在一个线程里包装所有监听功能,在请求旁并发运行，打开lib/live_assets.rb实现它

    live_assets//lib/live_assets.rb
      require "live_assets/engine"
      require "thread"
      require "listen"
        
      module LiveAssets
        mattr_reader :subscribers
        @@subscribers = []
        
      # Subscribe to all published events.
      def self.subscribe(subscriber)
      subscribers << subscriber
      end
      # Unsubscribe an existing subscriber.
      def self.unsubscribe(subscriber)
      subscribers.delete(subscriber)
      end
      # Start a listener for the following directories.
      # Every time a change happens, publish the given
      # event to all subscribers available.
      def self.start_listener(event, directories)
      Thread.new do
      Listen.to(*directories, latency: 0.5) do |_modified, _added, _removed|
      subscribers.each { |s| s << event }
      end
      end
      end
      end