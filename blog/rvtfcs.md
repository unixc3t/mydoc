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
