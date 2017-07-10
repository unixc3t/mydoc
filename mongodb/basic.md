> 文件说明

* mongorestore 导入bson数据
* bsondump  导出bson结构
* mongo  客户端程序交互终端
* mongod 服务端程序类似mysqld,数据库核心进程
* mongodump  整体数据库导出类似mysqldump
* mongoexport 导出json,csv,tsv格式数据、
* mongoimport 导入json,csv,tsv数据
* mongos 查询路由器，集群时用
* mongotop 诊断工具
* mongostats 状态查看

##### 使用

> 启动mongod服务,制定数据库目录和log文件位置

    /bin/mongod --dbpath fold --logpath file --fork(后台模式运行) --port 27017

> 编写一个bash脚本方便使用

    #!/bin/sh 

    mongod --dbpath  /home/rudy/pro/mongodb3.4.5/database --logpath /home/rudy/pro/mongodb3.4.5/log/db.log --fork

> 然后启动客户端

  /bin/mongo

> 常用命令

   use database 选择数据库
   show dbs 查看当前数据库
   show tables/collections 查看数据库的表 mongodb中的表叫做collection

> mongodb中可以隐世创建数据库，当你use一个不存在的库，然后在这个库下创建collection就可以创建这个库
> 同样直接隐世创建collection,db.不存在collection名字.insert({})，collection会默认被创建

   use test
   db.createCollection('user')

> 插入一条数据,可以自己指定_id，或者让系统自动生成

    db.user.insert({name:'jack'})

> 查看数据

    db.user.find()

> 删除一个collection

  db.user.drop()

> 删除一个数据库 database

  db.dropDatabase //db指代use database时的database

> mongodb存储的基本单元是文档，也就是document，文档是json对象

    db.collection.insert(
       <document or array of documents>,
      {
        writeConcern: <document>,
        ordered: <boolean>
      }
    )
> 删除文档 需要给定查询表达式,以json对象形式，如果不传递将清空整个collection

    db.collection.remove() 

> 只删除一行传递参数true

  db.stu.remove({name:'ja'},true)

> 整体替换更新 改谁？ 改成什么样？ 选项 ,新文档整体修改了旧文档

  db.st.update({name:'dalang'},{name:'wdalang'})

> 更新某个属性而不是整体,只修改一行

  db.st.update({name:'dalang'},{$set:{name:'wdalang'}})

* $set 改某个列
* $unset 删除某个列
* $rename 重命名个了列
* $inc 自动增长某个列

  db.stu.update({name:'dalang'},{$set:{name:'wudalan'},$unset:{age:1},$rename:{old,new},$inc:{age:12}})

> 添加multi:true 修改多行

  db.stu.update({name:'jack'},{$set:{gender:'f'}},{multi:true})

> upsert 没有就插入，有就修改
  db.stu.update({name:'jack'},{$set:{gender:'f'}},{upsert:true})

> $setOnInsert 表示当查找条件没找到就会插入，但是只插入了你修改的字段，这时候你还想同时添加其他字段，使用这个属性

      db.products.update(
      { _id: 1 },
      {
        $set: { item: "apple" },
        $setOnInsert: { defaultQty: 100 }
      },
      { upsert: true }
    )

> 显示所有文档的name属性值，不显示id

    db.stu.find({},{name:1,_id:0})

> 根据查询表达式显示匹配的文档的name 类似 select name from table where age=12

    db.stu.find({age:12},{name:1})

##### 查询表达式

> 属性为某个值的文档

    db.goods.find({goods_id:3})

> 查询某个属性不等于某个值的文档,只查出name

    db.goods.find({cat_id:{$nq:3}},{name:1})

> 查出价格大于3000上产品,小于用$lt，小于等于$lte,$nin是not in ,$in是 in ，$all指数组所有项都匹配
> $not 就是 not ，$or 就是or， $and 就是and

    db.goods.find({shop_price:{$gt:3000}},{name:1})

> 查出属性是4或11的数据

    db.goods.find({cat_id:{$in:[4,11]}})
> 不是4或11
    db.goods.find({cat_id:{$nin:[4,11]}})

> 价格大于100小于500产品

    db.goods.find({$and:[{shop_price:{$gte:100}},{shop_price:{$lte:500}}]});

> 属性不等于3也不等于11

    db.goods.find({$and:[{cat_id:{$ne:11}},{cat_id:{$ne:3}}]});
    db.goods.find({cat_id:{$nin:[3,11]}});
    db.goods.find({$nor:[{cat_id::11},{cat_id:3}]});

> $exists 某列存在则为真，$mod 满足某求余条件则为真，$type数据类型为某类型则为真

> 找出good_id值 对于求余数为0的数据

    db.goods.find({good_id:{$mod:[5,0]}})

> 找出有年龄属性的数据

    db.goods.find({age:{$exists:1})

> 找出年龄属性是字符串的数据

  db.goods.find({age:{$type:2}})

> 找出属性值都包含b,c的数据

  db.goods.find({bobby:{$all:[b,c]}})

> 使用$where条件,遍历每个document对象，取出属性来比较，效率低,但可读性好，方便写

    db.goods.find({$where:'this.shop_price>5000'}})

> 取出价格大于100并且小于300，或大于4000小于5000

  db.goods.find({$or:[{$and:[{price:{$gt:100}},{price:{$lt:300}}]},{$and:[{price:{$gt:4000}},{price:{$lt:5000}}]}]})

  db.goods.find({$where:'this.price>200 && this.price<300 or this.price > 3000 && this.price< 5000'})

> 正则匹配

    db.goods.find({goods_name:{$regex:/^nokia/}})

#### 3.3 Configuring Our Resolver for Production

> 在生产环境中，为了确保模板可以快速的被找到，rails提供了一些方便的缓存，让我们了解一些缓存方式，以便让我们了解如何缓存模板，和当我们保存模板时让缓存过期,如前面说的
> rails给我们提供了一个cache_key通过find_all()方法，我们的第一站是了解Rails为什么创建这个缓存键以及我们的解析器如何使用它。


###### The Resolvers Cache

> 在前面我们看到ActionView::Resolve的find_all方法自动缓存模板，使用cached()方法。缓存是在初始化创建被实例变量@cached引用，解析器缓存模板时仅在Rails.application.config.cache_classes返回true时，此外clear_cache()方法用来清空缓存

> 每个模板缓存在函数的5个值中(5个值代表了这个函数)， cache_key,prefix name partial,还有 locals, 给定这5个key，我们可以存储这个模板在缓存中以3种方式。


    # Nested hash
    @cached[key][prefix][name][partial][locals]
    # Simple hash with array as key
    @cached[[key, prefix, name, partial, locals]]
    # Simple hash with hash as key
    @cached[key: key, prefix: prefix, name: name, partial: partial, locals: locals]

> 所有三个缓存实现都给了我们想要的行为。然而，他们中不同的就是性能，我们需要了解ruby如何在hash中查找。来理解一点。


##### Ruby Hash Lookup

> 无论什么时候，我们存储一个值作为Hash对象的key，ruby要存储三样东西，给定的key,给定的值，key对应的hash值

>这个hash值是作为给定的key，在key上调用Object#ahsh()方法的结果，这有一个简单的方法证明是基于Object#hash()方法，我们打开一个irb sessin,然后输入下面

  class NoHash
    undef_method :hash
  end

  hash = Hash.new
  hash[NoHash.new] = 1
  # => NoMethodError: undefined method `hash' for #<NoHash:0x101643820>

> 如果我们取消我们对象中定义的hash方法，就不能在hash中存储它，添加一个元素到hash中类似创建一个新项在表格中，如下图

![](06.png)

> 当我们尝试在hash对象中，获取key对应的值的时候，例如hash[:b],ruby使用给定的key和Object#hash()方法计算他的值，然后查找时候有一项或多项在hash中只有一样的hash值
> 例如，:b.hash返回231228,然后看到一项或多项都包含231228,ruby检查任意一个key时候等价于给定的key值，使用equality操作符 eql?() 因为:b.eql?(:b)返回true,所以我们例子中返回2


> 为了证明ruby使用Object#hash()本地化所有项，我们打开另一个irb 输入下面代码

    hash= {}
    object = Object.new
    hash[object] = 1
    hash[object] # => 1
    def object.hash; 123; end
    hash[object] # => nil
    hash
    # => {#<Object:0x1016e3de8>=>1}

> 这次我们使用任意一个ruby对象作为hash的key，我们可以成功设置和检索到值，然而
> 在我们修改了hash方法的返回值之后，我们就不能得到一样的值了。


> ruby存储使用Object#hash方法存储key可以得到快速的查找， 比较hash值比比较对象快

> 这种实现方式意味着找到一个值，性能损失在eql?方法上，也涉及object#hash方法上，记住
> 我们可以实现我们的解析器缓存使用一个nested hash 或者一个简单的使用数组作为key的hash，或者使用hash作为key，我们应该选择第一个，因为在nested-hash例子中，这个hash的key是字符串或者布尔值，ruby知道如何计算Object#hash()值，另一方面，Object#hash的计算对于array和hash更废资源

> 我们在新的irb session中展示

    require "benchmark"

    foo = "foo"
    bar = "bar"
    array = [foo, bar]
    hash  = {a: foo, b: bar}

    nested_hash = Hash.new { |h,k| h[k] = {} }
    nested_hash[foo][bar] = true
    array_hash = { array => true }
    hash_hash = { hash => true }
    
    Benchmark.realtime { 1000.times { nested_hash[foo][bar] } } 
    # => 0.000342
    Benchmark.realtime { 1000.times { array_hash[array] } }
    # => 0.000779
    Benchmark.realtime { 1000.times { hash_hash[hash] } }
    # => 0.001645


> nested-hash实现结果更好，虽然选择nested-hash表面上没有看出有多大价值，我们了解了ruby hash查找的功能有助于理解下一节


###### The Cache Key

> 我们已经知道，我们的解析器需要内建一个缓存，我们也知道我们的解析器使用nested hash存储模板，缓存依赖于五个值，@cached[key][prefix][name][partial][locals]> 然而，find_all签名需要6个参数

    def find_all(name, prefix=nil, partial=false, details={}, key=nil, locals=[])

> details是一个hash，包含了format,locale和其他信息用来查找模板，lookup context存储了这个信息，从文件系统中检索正确的模板是非常必要的。那么为什么缓存不使用这些细节呢？

> 还记得我们确定，当比较较简单结构时，使用Object#hash()计算hash是十分耗费资源
>，比如字符串？如果我们使用details作为key，在缓存hash中，会非常慢，因为details是一个数组组成的hash

    details # => {
      formats: [:html],
      locale: [:en, :en],
      handlers: [:erb, :builder, :rjs]
      }
      # Slow because details is a hash of arrays
      @cached[details][prefix][name][partial][locals]

  
> 相反，lookup context 为每个details hash生成一个简单的ruby对象，将他作为cache_key给解析器，整个过程类似下面代码

    # Generate an object for the details hash
    @details_key ||= {}
    key = @details_key[details] ||= Object.new
    # And send it to each resolver
    resolver.find_all(name, prefix, partial, details, key)
    # Inside the resolver, the details value is not used in the cache
    # Instead we use the key, which is a simple object and fast
    @cached[key][prefix][name][partial][locals]

> 换句话说，details没有在cache中被直接使用，而是通过cache_key， 这一点很重要，
> 因为在一个请求期间，details很少改变， format和locale通常在渲染模板前就被设置
> 因为，不管多少模板被渲染，解析器都在一个请求中被调用，cache_key仅仅被计算一次，如果details改变，例如请求format， 一个新的cache_key就会生成

>让我们通过irb再试一次， 我们使用benchmark展示使用一个简单对象访问一个hash，例如cache_key,与使用数组hash作为key来比较 想details hash

    require "benchmark"
    cache_key = Object.new
    details = {
        formats: [:html, :xml, :json],
        locale:[:en],
        handlers: [:erb, :builder, :rjs]
    }

    hash_1 = { cache_key => 10 }
    hash_2 = { details => 10 }
    Benchmark.realtime { 1000.times { hash_1[cache_key] } } # => 0.000202
    Benchmark.realtime { 1000.times { hash_2[details] } } # => 0.003937


> 慢20倍，相当大差距，对于需要高性能的程序

######　Expiring the Cache

> 因为rails会自动操作解析器中的缓存，我们仅仅需要担心使用Resolver#clear_cache()方法让缓存过期，缓存被存储在解析器实例中，所以要使缓存过期，我们需要跟踪所有的SqlTemplate:Resolver实例，并且在更新数据库模板的时候调用实例的clear_cache()方法


>然而，创建各自单独的SqlTemplate::Resolver实例的意义是什么？因为缓存在实例中，创建各自的实例,将会创造各自的缓存，减少了缓存的有效性，因此，我们不想穿件多个解析器实例，我们仅仅想在整个application分享同一个实例。

>我们需要一个单例类，幸运的是，ruby有一个Singleton模块在标准库中,已经做了所有困难的部分。引入整个模块在SqlTemplate::Resolver中，使得SqlTemplate::Resolver.new()方法变成私有，暴露了一个SqlTemplate::Resolver.instance()方法作为替代，整个方法总是返回同一个对象。


>让我们开始这个改变，首先需要引入单例模块

    templater/2_improving/app/models/sql_template.rb
    require "singleton"
    include Singleton

> 做完这个简单的改变之后，我们需要更新app/controllers/users_controller.rb 个test/models/sql_template_test.rb来调用SqlTemplate::Resolver.instance()方法替代
> SqlTemplate::Resolver.new()

    templater/2_improving/app/controllers/users_controller.rb
    append_view_path SqlTemplate::Resolver.instance
    templater/2_improving/test/models/sql_template_test.rb
    resolver = SqlTemplate::Resolver.instance

> 在这些地方使用单例解析器，我们编写一个测试在est/models/sql_template_test.rb文件里
> 然后判断我们的缓存在适当的时候过期，这个新的测试应该更新来自fixture的SqlTemplate，并且判断应该返回更新后的模板

      templater/2_improving/test/models/sql_template_test.rb
      test "sql_template expires the cache on update" do
      cache_key = Object.new
      resolver = SqlTemplate::Resolver.instance
      details
      = { formats: [:html], locale: [:en], handlers: [:erb] }
      t = resolver.find_all("index", "users", false, details, cache_key).first
      assert_match "Listing users", t.source
      sql_template = sql_templates(:users_index)
      sql_template.update_attributes(body: "New body for template")
      t = resolver.find_all("index", "users", false, details, cache_key).first
      assert_equal "New body for template", t.source
      end

> 注意我们生成一个伪装cache_key，将Object.new传递给find_all()方法，只有一个缓存key被提供，缓存才有效

> 最后,为了使我们的测试通过，我们添加一个after_save回调到SqlTemplate里面，


    templater/2_improving/app/models/sql_template.rb
    after_save do
    SqlTemplate::Resolver.instance.clear_cache
    end

> 现在，每次模板被创建或者更新,缓存都会过期，允许修改选择的模板并且重新编译，不幸的是，
> 这个方案有一个严重的限制， 它只适用于单个实例部署。，例如，如果你底层包含多个服务器或者你使用Passenger 或 Unicorn有一个实例池，一个请求将会得到一个指定实例，仅有它自己的缓存被清理，换句话说，在机器之间，缓存不是同步的

> 幸运的是我们可以解决这个问题:

* 一个选项是从新实现缓存，使用memcached或者redis在机器之间分享，使用适当的缓存机制

* 另一个选项是通知每个实例，每当缓存过期时，例如，一个队列，在这种模式下,after_save()将会加单的Push一个消息，给队列，然后发送一个通知告诉所有订阅实例

* 我们也可以通过设置config.action_view.cache_template_loading为false在生产环境，前面我提到过，解析器缓存只有在config.cache_classes为true时才激活


#### 3.4 Serving Templates with Metal

> 现在，我们能够创建和编辑模板从ui界面，用我们的自己的解析器提供解析， 我们准备好谈论下一话题， 让我们使用我们的模板工具作为一个简单的内容管理系统

###### Creating the CmsController

> 我们能够create update和删除模板，通过访问路径/sql_templates 现在我们需要暴露他们基于可访问的url


> 为了实现这一点，我们将所有请求映射到/cms/*下，对应一个控制器，将使用我们的解析器找到来自数据库的模板， 渲染他们返回给客户端， 一个/cms/about请求应该返回一个存储在数据库里的SqlTemplate，path对应about

> 我们用几行代码来实现这个功能， 我们使用capybara编写一个集成测试， 设置capybara

    templater/2_improving/test/test_helper.rb
    require "capybara"
    require "capybara/rails"
    # Define a bare test case to use with Capybara
    class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
    include Capybara::DSL
    include Rails.application.routes.url_helpers
    end

> 添加依赖到Gemfile里

    group :test do
    gem 'capybara', '~> 2.0.0'
    end

> 最后编写测试创建他然后渲染他

    templater/2_improving/test/integration/cms_test.rb
    require 'test_helper'
    class CmsTest < ActiveSupport::IntegrationCase
    test "can access any page in SqlTemplate" do
    visit "/sql_templates"
    click_link "New Sql template"
    fill_in
    fill_in
    fill_in
    fill_in
    fill_in
    "Body",
    "Path",
    "Format",
    "Locale",
    "Handler",
    with:
    with:
    with:
    with:
    with:
    "My first CMS template"
    "about"
    "html"
    "en"
    "erb"
    click_button "Create Sql template"
    assert_match "Sql template was successfully created.", page.body
    visit "/cms/about"
    assert_match "My first CMS template", page.body
    end
    end

> 编写路由

    templater/2_improving/config/routes.rb
    get "cms/*page", to: "cms#respond"

> 将路由全部映射到/cms/*对应的respond()方法 我们需要按照下面实现

    templater/2_improving/app/controllers/cms_controller.rb
    class CmsController < ApplicationController
    prepend_view_path SqlTemplate::Resolver.instance
    def respond
    render template: params[:page]
    end
    end

> 我们将给定的路由作为模板的名字，转发给我们的SqlTemplate::Resolver，用来查找模板

> 如果你想测试我们的cms以手动形式，启动服务器，访问sql_templates，创建一个新的模板，path值是about，添加一些内容，访问/cms/about 你会看到新页面


###### Playing with Metal

> 我们的cmsController继承自ApplicationController,而它继承自ActionCon-troller::Base，因此，它附带了常规Rails控制器中可用的所有功能。
> 包含了所有帮助方法，跨域请求保护，允许我们使用hide_action隐藏actions，添加flash messges支持，添加respond_to()方法，和许多方法，超过我们仅仅需要处理一个get请求所需要的
> 如果我们能有一个更简单的控制器，只需要我们所需要的行为，那不是很好吗？

> 我们已经讨论有关抽象控制器和它怎样提供基础结构在Action Mailer 和 Action Controller
> 中被分享，然而AbstractController::Base不知道任何有关http,换句话说，ActionController::Base就是一个单独整体，中间难道没有其他么？

> 的确有，叫做ActionController::Meta，ActionController::Metal继承AbstractController::Base，实现了最基本的使我们的控制器成为一个有效程序栈的处理http的功能，继承图如下

![](07.png)


> 通过快速查看，ActionController::Base 源码，我们注意到它继承自Metal并且加入了一些行为

    /actionpack/lib/action_controller/base.rb
    module ActionController
    class Base < Metal
    abstract!
    include AbstractController::Layouts
    include  AbstractController::Translation
    include AbstractController::AssetPaths
    include Helpers
    include  HideActions
    include UrlFor
    include  Redirecting
    include Rendering
    include Renderers::All
    include ConditionalGet
    include RackDelegation
    include Caching
    include MimeResponds
    include ImplicitRender
    include StrongParameters
    ...

> 让我们重新实现 CmsController,但是这次我们继承 ActionController::Metal，并且仅仅引入我们需要的木块，减少一个请求的开销

    templater/3_final/app/controllers/cms_controller.rb
      class CmsController < ActionController::Metal
      include ActionController::Rendering
      include AbstractController::Helpers
      prepend_view_path ::SqlTemplate::Resolver.instance
      helper CmsHelper
      def respond
      render template: params[:page]
      end
      end
      module CmsHelper
      end
  
> 如果我们需要更多功能，我们就required模块，例如，我们想要添加布局，就include  AbstractController::Layouts模块，创建一个布局文件在数据库中， path为layouts/cms 
>并且在控制器中指定 layout "cms"