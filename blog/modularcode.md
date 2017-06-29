### Modular Code Organization

> 在许多函数语言中,通常将相关的函数放在一个模块里,然而，当我们思考ruby中的模块时，我们通常认为有一些不同

    class A
      include Enumerable
      def initialize(arr)
        @arr = arr
      end
      def each
       @arr.each { |e| yield(e) }
      end
    end
    >> A.new([1,2,3]).map { |x| x + 1 }
    => [2, 3, 4]


> 上面代码,我们引入了Enumerable模块到我们的类里，作为一个mixin,这可以让我们分享函数功能实现,但是和模块代码组织山有一点概念上不同

> 我们想在一个单独的命名空间统一管理函数集合，事实上,ruby已经有了这种做法, Math模块，既可以混入到类中,就像我们使用Enumerable那样,你也可以单独使用它

    Math.sin(Math::PI / 2)
    1.0
    Math.sqrt(4)
    2.0

> 怎么做到的？ 使用module_function

    module A
      module_function
      def foo
       "This is foo"
      end
      def bar
        "This is bar"
      end
    end

> 我们可以使用模块直接调用这些函数

    A.foo
    "This is foo"

> 你想在模块上执行函数，这就足够了，但是这种方案有局限性,因为不允许你使用私有函数

    module A
      module_function
      def foo
        "This is foo calling baz: #{baz}"
      end
      def bar
        "This is bar"
      end
      private
      def baz
        "hi there"
      end
    end
  

>代码看起来一目了然,如果调用A.foo就会得到一个错误

    >> A.foo
    NameError: undefined local variable or method 'baz' for A:Module
    from (irb):33:in 'foo'
    from (irb):46
    from /Users/sandal/lib/ruby19_1/bin/irb:12:in '<main>'

> 在某些情况下,不能访问私有方法,会是一个大问题,但是其他情况，或许是个主要问题,有一个简单的解决方案

> ruby中的模块虽然不能被实例化,但本质上是普通对象,基于这点,没有什么能阻止我们混入模块到自身


      module A
        extend self
        def foo
          "This is foo calling baz: #{baz}"
        end
        def bar
          "This is bar"
        end
        private
        def baz
         "hi there"
        end
      end

> 一旦我们这么做了,我们得到module_function一样效果，而且没有限制

    >> A.foo
    => "This is foo calling baz: hi there"

> 我们没有牺牲封装性，如果直接调用私有方法，让然得到一个错误

    >> A.baz
    NoMethodError: private method 'baz' called for A:Module
    from (irb):65
    from /Users/sandal/lib/ruby19_1/bin/irb:12:in '<main>'

> 使用这种使用模块本身扩展自己的技巧，提供我们一种和你在其他函数语言遇到的结构，并没有什么不同，至少在表面上,
> 除了想math模块这样的古怪案例,你或许不知道，这种技术十分有用

> 大多数情况,class封装ruby代码十分有效,传统的继承方式和mixin功能已经覆盖大部分情况，做的不错。然而
> 有一种情况对于定义一个类有些太大,但是放在一个函数中又太小

> 我最近在一个Rails应用程序中遇到这个问题,我正实现一个用户验证，需要通过使用activeRecord来检测数据库中数据。
> 如果用户没有在程序中创建账户，返回到ldap验证

> 没涉及太多细节，类似下面这样

    class User < ActiveRecord::Base
      # other model code omitted
       def self.authenticate(login, password)
          if u = find_by_login(login)
            u.authenticated?(password) ? u : nil
          else
            ldap_authenticate(login, password)
          end
        end
    end

> LDAP认证使用一个私有的类方法实现, 期初这看起来是个好主意,然而，当我继续工作的时候，我发现正在编写一个巨大的函数,而且超过了一页的代码，我将这些代码变成多个帮助方法使得他们更清晰,不幸的是,这个方案没有如我预期那样

> 在最后的重构中，我在User上使用各种方案,例如initialize_ldap_conn , retrieve_ldap_user ,等等。
> 一个精心设计的对象应该只做一件事并且做好，我们的User模型看起来知道太多关于ldap而且超过它本身应该做的。最后我的方案
> 就是将代码放到一个模块里，对于User.authenticate方法是一个很小的改变

    def self.authenticate(login, password)
      if u = find_by_login(login) # need to get the salt
        u.authenticated?(password) ? u : nil
      else
        LDAP.authenticate(login, password)
      end
    end

> 通过使用一个在User::LDAP上的模块函数替换USer模型上的私有方法，我可以定义我的帮助方法和私有方法在一个地方
> 模块看起来如下

    module LDAP
        extend self
        def authenticate(username, password)
            connection = initialize_ldap_connection
            retrieve_ldap_user(username, password, connection)
        rescue Net::LDAP::LdapError => e
            ActiveRecord::Base.logger.debug "!!! LDAP Error: #{e.message} !!!"
            false
        end
        private

        def initialize_ldap_connection
        #...
        end
        def retrieve_ldap_user(username, password, connection)
        #...
        end
    end

> 这样清理代码十分清晰,并且易于查看,同时有额外好处，它引入了清晰的关注点分离，使得测试更加容易。它还为将来的扩展和修改留下了空间，而没有紧密耦合。

> 当然如果我们需要做的不仅仅是验证一个用户,那么这个模块就不够用，当你看到一样的参数被传递到一组函数中，你或许遇到这种情况，一些持久化状态不会损坏，你可以看到我们花费大量时间传递usernames和连接对象，代码将会变得很大

> 好消息是，如果需要扩展，将已组织到模块的代码转换是微不足道的。看如下，某块可以简单的变成一个类

    class LDAP
      def self.authenticate(username, password)
        user = new(username, password)
        user.authenticate(password)
      rescue Net::LDAP::LdapError => e
        ActiveRecord::Base.logger.debug "!!! LDAP Error: #{e.message} !!!"
        false
      end
      def initialize(username)
        @connection = initialize_ldap_connection
        @username = username
      end
      def authenticate(password)
      #...
      end
      private
      def initialize_ldap_connection
      #...
      end
    end

> 如你所见,差别是微乎其微， 在User模型里不需要任何改变，面向对象的纯粹主义者可能会喜欢这个方法，但有前面所示的模块化方法极简主义一定吸引力。

> 尽管这个最新的迭代转向了一种更面向对象的方法，但仍然存在模块化的吸引力,在Ruby中创建类方法的方便性极大地促进了这一点，因为它可以使它看起来像模块化的代码，即使每次构建LDAP模块的新实例时也是如此

> 尽管在每种可能的情况下都不太可能尝试使用这种模块化代码设计技术,这是一个值得了解的整洁的组织方法,这有一些事情需要注意，这些情况或许是引入这项技术的正确时机

* 你在解决一个单独的原子性问题，引入许多步骤，将他们拆分成帮助方法
* 你正在包装一些函数,他们不依赖相同状态，但是有关于同一个主题
* 代码是非常通用的，可以单独使用，或者代码非常具体，但并不直接与它所要使用的对象相关联。
* 你正在解决的问题是足够小,面向对象方式反而更麻烦而不是更方便，对于解决你的问题

> 因为模块化代码组织减少了正在创建的对象的数量,所以它可能会给您一个体面的性能提升。这提供了一种激励，在适当时使用这种方法。