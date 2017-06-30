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

> Rakefile 提供了基本的运行测试套件的任务,生成文档,生成插件的公开版本，

