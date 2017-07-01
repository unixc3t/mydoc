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

#### Running Tests

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

> 最后，注意到我们的测试文件引入了test/test_helper.rb，这个文件负责读取我们的application配置测试环境, 使用我们创建的插件骨架,和一个绿色的测试套件。我们开始编写我们的自定义渲染器