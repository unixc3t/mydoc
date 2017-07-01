#### Create Our Own Render

> 像大多数web框架一样,rails使用model-view-controller(mvc)结构模式来组织我们的代码,controller通常用来采集来自我们rails使用model的信息，然后将数据发送给view来渲染,在其他场合,model负责展示自己,view并不会参与到请求中,这通常发生在json请求时, 下面的index action描述了这两个场景

    class PostsController < ApplicationController
      def index
        if client_authenticated?
          render json: Post.all
        else
          render template: "shared/not_authenticated", status: 401
        end
      end
    end

> 渲染一个给定的model或者template的通用接口就是这个render()方法，除了知道如何渲染一个:template或者一个:file，
> rails也能够渲染：text流，和其他格式,例如 :xml,:json和:js.虽然默认的rails选项足够我们启动我们的程序,我们有时
>也需要加入新的选项例如 :pdf or :csv 到render()方法里

> 为了实现这一点, rails提供了一个程序接口，让我们可以创建自己的渲染器，我们将探究这个api为此，我们修改render方法接收:pdf选项 并且使用prawn创建返回一个Pdf  ,prawn是一个轻巧，方便的[pdf库](https://github.com/prawnpdf/prawn)

> 我们将使用 rails plugin生成器创建一个插件，扩产rails能力，让我们开始


##### 1.1 Creating Your First Rails Plug-in

> 如果你已经安装了rails，我们开始制作第一个插件, 叫做pdf_render

    $ rails plugin new pdf_renderer

      create  
      create  README.md
      create  Rakefile
      create  pdf_renderer.gemspec
      create  MIT-LICENSE
      create  .gitignore
      create  Gemfile
      create  lib/pdf_renderer.rb
      create  lib/tasks/pdf_renderer_tasks.rake
      create  lib/pdf_renderer/version.rb
      create  bin/test
      create  test/test_helper.rb
      create  test/pdf_renderer_test.rb
      append  Rakefile
      vendor_app  test/dummy
      run  bundle install

> 这个命令创建了基本的插件结构, 包含了一个pdf_render.gemspec文件，一个rakefile,一个Gemfile和lib和test目录。
> 倒数第二行很有趣，它生产了一个完整的rails程序在test/dummy目录里，允许我们在一个rails程序上下文中运行测试

> 生成器运行bundle install后结束, 使用bundler安装所有的依赖，并设置好，让我们看一下生成的文件

###### pdf_renderer.gemspec

> pdf_renderer.gemspec提供了一个基本的gem说明, 说明描述了gem的作者，版本，依赖，源文件,和其他.这使得我们很容易将我们插件打包成一个ruby gem.也更容易在不同的rails程序中分享我们的代码

> 注意在lib目录里有一个与gem同名的文件pdf_render.根据约定,不论何时,你声明这个gem在rails程序中，这个lib/pdf_render.rb文件都会自动required， 目前，这个文件仅仅定义了一个PdfRenderer模块

> 最后，注意我们的gemspec没有直接定义项目版本，这个版本号定义在lib/pdf_renderer/version.rb ，在gemspec中使用
> PdfRenderer::VERSION引用, 这是ruby gem的通用方法

###### Gemfile

> 在rails程序中, Gemfile用来罗列所有依赖，不管是 开发，测试，还是生产依赖，然而，我们的插件已经有一个gemspec用来
>存放依赖， Gemfile 重用这个gemspec依赖， Gemfile或许最后包含开发中使用的扩展依赖，例如debugger或者pry

> 管理我们的plugin插件，我们使用Bundler， Bundler锁定我们的环境仅仅使用在pdf_renderer.gemspec列出的gem。 我们可以在插件根目录里，使用bundle install 或者bundle update加入新的依赖和更新已存在的依赖.

##### Rakefile

> Rakefile 提供了基本的运行测试套件的任务,生成文档,生成插件的release版本，我们可以通过执行
> rake -T 来得到完整任务列表

    rake build            # Build pdf_renderer-0.1.0.gem into the pkg directory
    rake clean            # Remove any temporary products
    rake clobber          # Remove any generated files
    rake clobber_rdoc     # Remove RDoc HTML files
    rake install          # Build and install pdf_renderer-0.1.0.gem into system gems
    rake install:local    # Build and install pdf_renderer-0.1.0.gem into system gems without network access
    rake rdoc             # Build RDoc HTML files
    rake release[remote]  # Create tag v0.1.0 and build and push pdf_renderer-0.1.0.gem to Rubygems
    rake rerdoc           # Rebuild RDoc HTML files
    rake test             # Run tests


##### Booting the Dummy Application

> rails plugin创建了一个虚拟的applictaion在test目录里，这个程序启动过程和使用普通的rails命令创建的一样。

> config/boot文件唯一的责任:配置我们的application的加载路径，config/application.rb文件加载所有需要的依赖和配置application，在config/enviroment.rb初始化配置


> rails plugin生成了一个boot文件,test/dummy/config/boot.rb,和appliction的类似，第一个不同是，他需要指向pdf_renderer插件根目录的gemfile，他还明确加入插件的lib目录到ruby的家在路径load path，确保我们的插件在虚拟application中有效：

    # Set up gems listed in the Gemfile.
    ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __dir__)

    require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
    $LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)

> boot文件委托Bundler负责设置依赖和他们的加载路径。test/dummy/config/application.rb只是
> rails appliction程序中config/application.rb的精简版

    require_relative 'boot'

    require 'rails/all'

    Bundler.require(*Rails.groups)
    require "pdf_renderer"

    module Dummy
      class Application < Rails::Application
        # Initialize configuration defaults for originally generated Rails version.
        config.load_defaults 5.1

        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.
      end
    end

> config/enviroment.rb和你在普通的rails程序中遇到的一样

    # Load the Rails application.
    require_relative 'application'

    # Initialize the Rails application.
    Rails.application.initialize!

###### Running Tests

> 默认情况,rails plugin生成一个完成的测试，为我们的插件，让我们运行一下看看

    raket test

    Run options: --seed 7555

    # Running:

    .

    Finished in 0.002406s, 415.6896 runs/s, 415.6896 assertions/s.
    1 runs, 1 assertions, 0 failures, 0 errors, 0 skips


> 这个测试,定义在test/pdf_renderer_test.rb中，断言我们的插件定义在一个叫做PdfRenderer模块下

    require 'test_helper'

    class PdfRenderer::Test < ActiveSupport::TestCase
      test "truth" do
        assert_kind_of Module, PdfRenderer
      end
    end

> 最后，注意到我们的测试文件引入了test/test_helper.rb，这个文件负责读取我们的application和配置测试环境, 使用我们创建的插件骨架,和一个绿色的测试套件。我们开始编写我们的自定义渲染器


##### 1.2 Writing the Renderer

> 在本章开头，我们简单的讨论了render()方法和一个它接受的选项，但是我们没有正式描述什么是一个renderer渲染器

> 一个render只不过是一个回调，通过暴露的render()方法来自定义它的行为。加入我们自己的render到rails里很简单，让我们看一下:json render的源码

    add :json do |json, options|
      json = json.to_json(options) unless json.kind_of?(String)
        if options[:callback].present?
           self.content_type ||= Mime::JS
           "#{options[:callback]}(#{json})"
        else
          self.content_type ||= Mime::JSON
          json
      end
    end

> 所以，当我们调用 下面的方法在我们的appliction里

    render json: @post

> 它会调用定义的block作为：json的render， block中的本地变量json指向@post， 并且其他传递给render方法的选项存储在opstions变量里,在这个例子里，因为访美被调用没有传递任何附加options，所以他是一个空的hash

> 下面章节,我们想加入一个:pdf renderer，使用给定的模板创建pdf文档，发送给客户端添加适当的header信息, 传递给:pdf的option的值应该是文件的名字

> 下面是我们想提供api的例子

    render pdf: 'contents', template: 'path/to/template'

> 即使rails知道如何渲染模板并且发送文件给客户端,但是它不知道怎样处理pdf文件，对于这点
> 我们使用Prwan

###### Playing with Prawn

> Prawn是一个pdf生成lib，因为它将会成为我们插件的一个依赖，所以我们需要假如它到我们的pdf_renderer.gemspec里面

    s.add_dependency "prawn","0.12.0"

> 下一步，我们告诉bundler去安装我们的新的依赖，并且通过ruby交互来测试

    $ bundle install
    $ irb

> 使用irb，我们创建一个简单的Pdf

    require "prawn"
    pdf = Prawn::Document.new
    pdf.text("A PDF in four lines of code")
    pdf.render_file("sample.pdf")

> 退出irb，你能在启动irb的目录下看到一个pdf文件, prawn提供了创建pdf的语言，虽然这给了我们一个
> 灵活的api，但是缺点就是不能创建来自html的pdf

#####　Code in Action

> 在我们深入代码之前，我们先写一个测试，因为我们有一个虚拟的application.我们可以在一个真实的rails程序中创建控制器,使用它测试完整的request栈,让我们命名这个控制器叫做HomeController并且加入下面这些内容
    pdf_renderer/test/dummy/app/controllers/home_controller.rb
    class HomeController < ApplicationController
      def index
        respond_to do |format|
          format.html
          format.pdf { render pdf: "contents" }
        end
      end
    end

> 然后创建这个pdf 视图,
    pdf_renderer/1_prawn/test/dummy/app/views/home/index.pdf.erb
    This template is rendered with Prawn.

> 添加路由

    Dummy::Application.routes.draw do
      get "/home", to: "home#index", as: :home
    end

> 然后我们编写一个集成测试验证访问/home.pdf的返回结果

    pdf_renderer/test/integration/pdf_delivery_test.rb

    require "test_helper"
      class PdfDeliveryTest < ActionDispatch::IntegrationTest
        test "pdf request sends a pdf as file" do
          get home_path(format: :pdf)
          assert_match "PDF", response.body
          assert_equal "binary", headers["Content-Transfer-Encoding"]
          assert_equal "attachment; filename=\"contents.pdf\"",
          headers["Content-Disposition"]
          assert_equal "application/pdf", headers["Content-Type"]
        end
      end
  
>  这个测试使用了response headers去断言，一个二进制编码pdf文件作为一个附件发送,包括预期的文件名。
> 即使我们不能断言太多pdf体中因为台式编码,我们能够至少断言pdf包含的字符串,使用prawn加入pdf体
> 让我们运行这个测试,　观察失败信息

    1) Failure:
    test_pdf_request_sends_a_pdf_as_file(PdfDeliveryTest):
    Expected /PDF/ to match "This template is rendered with Prawn.\n".

> 这个失败和预期的一样，因为我们美誉告诉rails怎样在render()中处理:pdf选项，它简单的渲染这个
> 模板没有包装成一个pdf文件，　我们可以通过实现我们的渲染器在lib/pdf_renderer.rb中添加一些代码

    pdf_renderer/lib/pdf_renderer.rb

    require "prawn"
    ActionController::Renderers.add :pdf do |filename, options|
      pdf = Prawn::Document.new
      pdf.text render_to_string(options)
      send_data(pdf.render, filename: "#{filename}.pdf",
      disposition: "attachment")
    end

> 在这个代码块中,我们创建了一个pdf文档,加入一些文本,发送这个pdf以附件的形式，使用send_data()方法，我们运行这个测试观察结果，最后通过,我也可以到虚拟application里，启动服务器rails server
> 使用http://localhost:3000/home.pdf测试

> 即使我们,测试通过了,仍然有一些需要解释,首先，注意到我们没有做的，设置Content-Type为appplication/pdf, rails怎么知道那个content type应该设置在我们的response里？

> content type被正确设置，因为rails分享了一组已经注册的Mime types:

    rails/actionpack/lib/action_dispatch/http/mime_types.rb

    Mime::Type.register "text/html", :html, %w( application/xhtml+xml ), %w( xhtml )
    Mime::Type.register "text/plain", :text, [], %w(txt)
    Mime::Type.register "text/javascript", :js,
    %w(application/javascript application/x-javascript)
    Mime::Type.register "text/css", :css
    Mime::Type.register "text/calendar", :ics
    Mime::Type.register "text/csv", :csv
    Mime::Type.register
    Mime::Type.register
    Mime::Type.register
    Mime::Type.register
    Mime::Type.register
    Download from Wow! eBook <www.wowebook.com>
    "image/png", :png, [], %w(png)
    "image/jpeg", :jpeg, [], %w(jpg jpeg jpe pjpeg)
    "image/gif", :gif, [], %w(gif)
    "image/bmp", :bmp, [], %w(bmp)
    "image/tiff", :tiff, [], %w(tif tiff)

    Mime::Type.register "video/mpeg", :mpeg, [], %w(mpg mpeg mpe)
    Mime::Type.register
    Mime::Type.register
    Mime::Type.register
    Mime::Type.register
    "application/xml", :xml, %w(text/xml application/x-xml)
    "application/rss+xml", :rss
    "application/atom+xml", :atom
    "application/x-yaml", :yaml, %w( text/yaml )
    Mime::Type.register "multipart/form-data", :multipart_form
    Mime::Type.register "application/x-www-form-urlencoded", :url_encoded_form
    Mime::Type.register "application/json", :json,
    %w(text/x-json application/jsonrequest)
    Mime::Type.register "application/pdf", :pdf, [], %w(pdf)
    Mime::Type.register "application/zip", :zip, [], %w(zip)

> 注意pdf格式如何被定义成相应的内容类型，当我们请求这个/home.pdf url时， rails从url中得到
> pdf格式，并且查找匹配HomeController#index中format.pdf代码块，然后处理设置内容类型在调用
> block之前,然后调用render

> 回到我们的渲染实现,虽然send_data()是一个rails公开方法,已经在第一个rails版本就出现了,
> 你或许没有听说过render_to_string(),为了更好的理解这个，我们来看一下rails 渲染处理整个流程