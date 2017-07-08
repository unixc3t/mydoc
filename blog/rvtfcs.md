#### Retrieving View Templates from Custom Stores

> 当rails 渲染一个template时，他需要从某个地方得到这个模板，默认情况，rails从文件系统得到模板，但是不受此限制， rails提供了回调，允许我们从任何我们想要的地方得到模板， 只要我们实现了需要的api,让我们探究一下构建机制，从数据库得到模板，模板可以被创建更新，删除，这些都通过web接口， 但是首先，我们要深入学习一下rails的渲染栈

###### 3.1 Revisiting the Rendering Stack

> 前面涨价。我们看到rails控制器渲染栈主要职责是格式化选项，将他们发送给ActionView::Render,当被调用时候，render接收到一个ActionView::Base实例，通过view context，和一个hash参数，找到编译渲染制定模板

    view_renderer.render(view_context, options)


> 当我们渲染一个模板时，源码必须编译成可执行代码， 每次一些ruby代码被执行，都需要在给定的上下文中执行， 在一个rails程序中， 试图在视图上下文中执行， 所有帮助方法在我们模板中都可用，例如 form_for()和link_to(),只要定义这些方法的模块被包含在view context(试图上下文中)


> 除了view context，view render需要访问一个ActionView::LookupContext实例，通常这个实例被叫做lookup_context， 这个lookup context在controllers和views间分享，存储需要找到模板的所有信息，例如，没放一个json请求过来，这个请求格式存储在lookup_context对象里，告诉rails仅仅需要找用来渲染json数据的模板

> 这个lookup context也负责存储所有视图路径，一个视图路径(view path)是一个对象集合，根据条件找到模板，所有在rails 程序中的控制器都有个默认试图路径，对应文件系统的app/views路径， 给予一定条件，例如模板名字，位置，格式，这个视图可以找到app/views下的指定模板，例如当你有一个HTML请求UserController控制器的index action，默认的试图路径将会尝试读取在app/views/users/index.html.*这个模板，如果这个模板被找到后，然后编译渲染 如下图所示

![](04.png)

> 在前面我们修改我们mailForm::Notifier对象的视图路径 ，引入了另一个模板查找路径

    module MailForm
      class Notifier < ActionMailer::Base
       append_view_path File.expand_path("../../views", __FILE__)
      end
    end


> 上面代码表示，如果在app/views目录下没有找到模板，就去lib/views目录下查找

>虽然我们设置路径是字符串形式，来表示文件系统路径，rails提供了一个定义良好的api 可以用任何对象作为路径， 这意味着我们不必要强制在文件系统上存储模板，我们可以存储模板在任何位置，根据我们提供的对象，找到模板，虽然外部的对象被称为视图的路径，在Rails内部称之为模板解析器，他们必须遵守解析器API。


> rails提供了一个抽象的 解析器实现，叫做 ActionView::Resolver 
> 在这章，我们将使用它创建一个解析器，使用数据库作为存储模板，所以我们可以通过数据库存储页面，通过web api和我们喜欢的模板处理器(liquid erb haml)编辑模板.下面我们来实现


#### 3.2 Setting Up a SqlResolver

> 这次，开发一个模板管理系统，开发一个rail application代替使用rails plugin插件方式开发， 这个程序交错template,我们使用下面这行命令

    $ rails new templater

> 接下来，我们定义一个model,用来在数据库里存放模板，我们使用rails scaffold 生成器

    $ rails generate scaffold SqlTemplate body:text path:string \
    format:string locale:string handler:string partial:boolean

> body属性是一个text字段，用来存储整个模板，path存储类似文件系统路径。(例如 UserController控制下下的index()方法，users/index作为path)，format和local存储木办个事和本地变量， handler存储模板处理器(erb,haml),最后整个partial告诉我们整个模板是否是一个局部模板

> 在执行migration之前，我们做一个改变，设置partial默认值是false

    t.boolean :partial, default: false

> 然后运行整个migrations

    $ bundle exec rake db:migrate

>目前，没有什么奇怪的，下一步我们创建一个模板解析器，使用sqlTemplate模型，将模板从数据读取和展示，通过resolver api


###### The Resolver API

> resolver api只由一个单独方法组成，叫做find_all(), 返回一组模板，下面是方法签名

    def find_all(name, prefix, partial, details, cache_key, locals)

> 对于一个html请求 UsersController的index方法， 参数应该如下方式展示

    find_all("index", "users", false, { formats: [:html],
      locale: [:en, :en], handlers: [:erb, :builder, :rjs] }, nil, [])


> 对于这个简单的请求，我们可以看到 name对应控制器里的action，prefix对应了控制器名字，partial是一个布尔值，告诉我们是否这个模板作为一个局部模板， details是一个hash，包含用于查找的额外信息， 例如，请求格式，国际化本地设置，然后就是模板解析器，最后两个参数就是cache_key和locals,这是个空数组，用于渲染时的本地变量

> rails提供了一个抽象的解析实现，叫做ActionView::Resolver，我们使用这个作为我们的解析基础，部分源码如下，重点关注find_all和find_templates()方法

    rails/actionpack/lib/action_view/template/resolver.rb
      module ActionView
        class Resolver
          cattr_accessor :caching
          self.caching = true
           def initialize
             @cache = Cache.new
            end
            def clear_cache
             @cache.clear
            end
            def find_all(name, prefix=nil, partial=false, details={}, key=nil,locals=[])
            cached(key, [name, prefix, partial], details, locals) do
              find_templates(name, prefix, partial, details)
            end
          end

        private
          def find_templates(name, prefix, partial, details)
             raise NotImplementedError
            end
          end
      end

> find_all实现了一个基本的缓存策略，如果缓存中没有缓存，代码块传递给cached并执行产生结果。当一个代码块被调用，它调用find_templates()方法， 跑出一个异常，表示这个方法需要被它的子类实现， 注意，cache_key和locals仅仅被缓存使用，他们不会被向下传递用于查找模板


> 我们继承ActionView::Resolver并且实现find_templates()方法，使用sqlTemplate model从数据库得到模板，组成模板查找，如下图所示

!()[05.png]


###### Writing the Code


> 我们声明解析器为SqlTemplate::Resolver 并且采用三步实现它
> 首先接收name, prefix partial 和details作为参数并且格式化他们，然后我们根据格式化的参数，创建一个sql语句，查询数据库，最后一部，将数据库得到的记录转换成 ActionView::Template实例返回

> 我们首先编写一个测试

    templater/test/models/sql_template_test.rb
    require 'test_helper'
      class SqlTemplateTest < ActiveSupport::TestCase
        test "resolver returns a template with the saved body" do
          resolver = SqlTemplate::Resolver.new
          details = { formats: [:html], locale: [:en], handlers: [:erb] }

          # 1) Assert our resolver cannot find any template as the database is empty
          # find_all(name, prefix, partial, details)

          assert resolver.find_all("index", "posts", false, details).empty?
        
          # 2) Create a template in the database
        
        SqlTemplate.create!(
          body: "<%= 'Hi from SqlTemplate!' %>",
          path: "posts/index",
          format: "html",locale: "en",handler: "erb", partial: false)

          # 3) Assert that a template can now be found
          template = resolver.find_all("index", "posts", false, details).first
          assert_kind_of ActionView::Template, template

          # 4) Assert specific information about the found template
          assert_equal "<%= 'Hi from SqlTemplate!' %>", template.source
          assert_kind_of ActionView::Template::Handlers::ERB, template.handler
          assert_equal [:html], template.formats
          assert_equal "posts/index", template.virtual_path
          assert_match %r[SqlTemplate - \d+ - "posts/index"], template.identifier
        end
      end

> 解析器中的find_all()方法应该返回一个ActionView::Template实例，这个模板实例按照下面方式初始化

    ActionView::Template.new(source, identifier, handler, details)

> source是模板主体被存储在数据库中，identifier是一个唯一的字符串代表模板，我们通过加入数据库template id确保唯一性

> handler这个对象负责编译模板，handler不是字符串，而是一个对象，使用ActionView::Template的registered_template_handler()方法得到

    ActionView::Template.registered_template_handler("erb") =>#<ActionView::Template::Handlers::ERB:0x007fc722516490>

> 最后一个给初始化模板的参数是一个hash有三个key，:format用来找到模板，：updated_at模板最后更新时间，和一个代表模板的:virtual_path

> 因为，模板不在需要一个文件系统，不再需要一个path路径，这打破了一些依赖依赖文件系统的rails特性，例如模板中的i18n缩写t(".messge")，它使用模板路径进行翻译，所以，无论何时，你在模板app/views/users/index里面，那么这几个简写形式将去找到"users.index.message"对应翻译


> 为了解决这个需求，rails需要模板提供一个：virtual_path，你可以存储模板在任何位置，但是你需要提供一个:virtual_path，如果模板存储在文件系统可以作为路径存储位置，这就允许t("message")通过虚拟路径来实现预期