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