### Sending Multipart Emails Using Template Handlers

> 完成了我们的rails render stack之旅,让我们看一下rails如何编译渲染模板，目前,我们已经看到,一个控制器负责格式化渲染参数，并且发送他们给view render，根据这些选项,view render告诉lookup context到解析器中去寻找指定的模板,并且考虑lookup context存储的Locale和foramt.

> 我们由上一节write the code知晓,解析器返回ActionView::Template的实例，同时这些实例被初始化好,我们需要传递一个叫做handler的参数，每个扩展例如.erb或者.html都有自己的模板处理器(handler)

    ActionView::Template.registered_template_handler("erb")
    #=> #<ActionView::Template::Handlers::ERB:0x007fc722516490>

> 模板处理器负责编译一个模板到ruby源码,这些源码在view context中执行，必须将渲染的模板作为字符串返回。如下图

![](08.png)

> 为了知道一个模板处理器如何工作,我们构建一个模板处理器解决这个实际问题,即使今天的email基于是1970年创建的，html 4.0版本在1997年制定,我们仍然不能依赖html发送邮件给每个人，因为邮件客户端不能适当渲染这些属性。

> 这就意味着无论什么时候配置一个程序发送html邮件，我们都应该发送一个同样内容的，文本格式的，创建一个多版本的邮件， 如果邮件接收者不能读取html邮件，它将回头接收文本形式邮件

> Action Mailer创建多版本邮件很容易，但是这样的方案导致我们不得不管理两个版本邮件，而且内容一样,如果我们同样内容被渲染成html和普通文本格式不是更好？

> markdown是一个轻量级的标记语言,由John Gruber和Aaron Swartz创造,目的是有利于简单的读写, markdown的语法完全由标点符号组成,允许你嵌入到html里，下面是一个简单的markdown文本

    Welcome
    =======
    Hi, José Valim!
    Thanks for choosing our product. Before you use it, you just need
    to confirm your account by accessing the following link:

    http://example.com/confirmation?token=ASDFGHJK

    Remember, you have *7 days* to confirm it. For more information,
    you can visit our [FAQ][1] or our [Customer Support page][2].
    Regards,
    The Team.
    [1]: http://example.com/faq
    [2]: http://example.com/customer

> 可读性非常高，最大好处是可以被转换成html，被渲染成下图这样

![](09.png)

> 我们的处理器将使用markdown的铁性生成text和htmls试图，仅仅使用一个模板， 这唯一的问题是
> markdown不能解释ruby代码，为了绕过这个，我们必须使用erb编译我们的模板， 然后使用markdown编译器传唤他们。

> 本章最后我们将配置rails生成器使用新的模板处理器作为默认。

#### 4.1 Playing with the Template-Handler API

> 一个对象兼容 handler api，它需要响应call()方法，这个方法接收一个ActionView::Template实例作为参数,ActionView::Template是我们在writing the code那节引入的，call方法返回一个字符串包含了有效的ruby code，处理器返回的ruby代码被编译成一个方法，渲染一个模板和调用一个方法一样

> 在开始我们的Markdown+ERB处理器之前，我们创建一个模板处理器认识一下这个api

##### Ruby Template Handler

> 我们第一个模板处理器允许任意的ruby代码作为一个模板，这意思是下面的模板是有效的
 
    body = ""
    body << "This is my first "
    body << content_tag(:b, "template handler")
    body << "!"
    body


> 为了实现这个，我们创建一个叫做handlers的rails插件

    $ rails plug-in new handlers

> 下一步我们编写一个集成测试，测试我们的模板处理器，我们的目标是渲染test/dummy/app/views/handlers/rb_handler.html.rb

    handlers/test/dummy/app/views/handlers/rb_handler.html.rb
    body = ""
    body << "This is my first "
    body << content_tag(:b, "template handler")
    body << "!"
    body

> 我们的集成测试需要路由器和控制器服务于模板，让我们添加

    handlers/test/dummy/config/routes.rb
    Dummy::Application.routes.draw do
     get "/handlers/:action", to: "handlers"
    end

    handlers/test/dummy/app/controllers/handlers_controller.rb
      class HandlersController < ApplicationController
    end

> 我们的集成测试,应该发送一个请求根据路由/handlers/rb_handler 并且断言模板被渲染
    require "test_helper"
    class RenderingTest < ActionDispatch::IntegrationTest
      test ".rb template handler" do
        get "/handlers/rb_handler"
        expected = "This is my first <b>template handler</b>!"
        assert_match expected, response.body
      end
    end


> 当我们运行测试的时候，失败了，因为rails仍然无法识别.rb扩展模板，注册一个新的模板处理器，我们调用ActionView::Template.register_template_handler()，传递两个参数，模板扩展和处理器对象。
>处理器对象可以是任何只要可以响应call()方法和返回字符串， 我们可以使用lambda简单实现一个处理器

      handlers/1_first_handlers/lib/handlers.rb
      require "action_view/template"
        ActionView::Template.register_template_handler :rb,
          lambda { |template| template.source }

      module Handlers
      end
  
> 当我们运行这个测试时，我们刚刚写的测试现在通过了。我们的lambda表达式接收一个ActionView::Template实例作为桉树，因为我们的模板处理器返回一个String包含ruby代码，我们的模板使用ruby代码写的，我们仅仅需要返回template.source().

> ruby的symbols实现了一个to_proc方法并且:source.to_pro和lambda { |arg| arg.source }一样，所以我们可以将模板处理器写的更短

    ActionView::Template.register_template_handler :rb, :source.to_proc


###### String Template Handler

> 我们的.rb模板处理器十分简单，但是功能有限,rails views通常有和很多静态内容,使用ruby代码处理这些变得十分麻烦，我们来实现另一个模板处理器,更合适处理这些静态内容,但是仍然允许我们内嵌ruby代码,因为string在ruby中支持插值写法，我们的下一个模板将会基于ruby字符串，让我们添加一个模板到dummy app里，

    handlers/test/dummy/app/views/handlers/string_handler.html.string
    Congratulations! You just created another #{@what}!

> 我们的新模板使用字符串插值, 并且被插入的ruby代码引用一个实例变量叫做@what, 让我们定义一个新的action，并且包含这个实例变量在我们的HandlersController控制器里，作为一个fixture

    handlers/test/dummy/app/controllers/handlers_controller.rb
    class HandlersController < ApplicationController
      def string_handler
        @what = "template handler"
      end
    end

> 让我们编写一个简单的测试

    handlers/test/integration/rendering_test.rb
    test ".string template handler" do
      get "/handlers/string_handler"
        expected = "Congratulations! You just created another template handler!"
        assert_match expected, response.body
      end

> 为了使我们测试通过,我们实现这个模板处理器，在lib/handlers.rb中

    handlers/lib/handlers.rb
    ActionView::Template.register_template_handler :string,
    lambda { |template| "%Q{#{template.source}}" }

> 运行这个测试，通过了，我们的模板处理器返回了一个使用ruby短写%Q{}创建的字符串，rails将它编译成一个方法，当方法被调用时,ruby解释器执行这个字符串，返回插入的值的结果

> 模板的处理器对于简单例子工作很好,但是有两个缺点，加入“}”字符到模板会引起语法错误,除非字符被转义
>同时，代码块支持有限,因为需要被包装到整个插值语法里， 这意味这下面两个引起错误

    This } causes a syntax error
    #{2.times do}
    This does not work as in ERB and is invalid
    #{end}

> 是时候看一个更健壮的模板处理器了


#### 4.2 Building a Template Handler with Markdown + ERB