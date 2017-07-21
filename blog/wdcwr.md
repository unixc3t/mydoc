### Writing DRY Controllers with Responders

> rails脚手架生成器是一个非常好的工具，帮助我们生成一个application原型。
> 它十分灵活，让我们可以替换默认的模板引擎，测试框架,和orm框架，使用我们喜欢的。
> 确保我们的生产力，无论我们选择的工具，唯一问题是脚手架生成的控制器代码有一点冗余。
> 我们的最后响应代码在不同控制器里都有重复，例如， 当使用一个属性调用的时候，由脚手架生成的create()方法和destroy方法都很类似，

    class UsersController < ApplicationController
    def create
    @user = User.new(user_params)
    respond_to do |format|
    if @user.save
    format.html { redirect_to @user, notice: 'User was successfully created.' }
    format.json { render action: 'show', status: :created, location: @user }
    else
    format.html { render action: 'new' }
    format.json { render json: @user.errors, status: :unprocessable_entity }
    end
    end
    end
    def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
    format.html { redirect_to users_url }
    format.json { head :no_content }
    end
    end
    private
    def user_params
    params.require(:user).permit(:name)
    end
    end


> 从一个控制器到另一个，这些respond_to()响应块都很类似，为了解决这个问题,rails提供了一个方法叫做 respond_with(),使用ActionController::Responder重构我们控制器如何响应，
>使用这个新的api，这些actions可以复用

    class UsersController < ApplicationController
      respond_to :html, :json
      def create
      @user = User.new(user_params)
      flash[:notice] = 'User was successfully created.' if @user.save
      respond_with(@user)
      end
      def destroy
      @user = User.find(params[:id])
      @user.destroy
      respond_with(@user)
      end
      private
      def user_params
      params.require(:user).permit(:name)
      end
    end
  
> 上面代码最上面。我们声明了控制器影响的格式, 将所有工作都委派给respond_with()，使用这个赶紧的api，我们重写了我们的actions。


> 在这章，我们将学习responder的工作方式，定制他们自动处理http缓存和flash信息,最后定制脚手架生成器使用respond_with()作为默认,


##### 6.1 Understanding Responders

> 想要理解responder背后的概念。我们必须先理解影响我们控制器响应的三个因素,请求类型，http请求方式,和资源状态。

###### Navigational and API Requests

> 一个控制器脚手架生成器创建响应两种默认格式,html和json，脚手架生成器使用这两种格式，因为他们表现出两种请求类型navigational和api，前者通过浏览器处理，支持格式html和mobile，然而后者通常被机器和代表像XML和JSON格式。

    def index
      @users = User.all
      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
      end
    end

> 让我们分析一下这个index action，许多Rails应用中常见的，html没接收代码块,所以它渲染一个模板,使用render json: @users表示资源使用json格式渲染

> 这表示控制器的行为依赖于请求类型,因此，抽象出控制器的行为，responder应该考虑请求类型


##### HTTP Verb

>show()和new()两个actions在rails控制器中响应类似index().通过渲染一个模板或者所请求对象表现,所有这些actions有什么共同之处吗？

> 其余的actions，例如create和destroy() 都是通过Post和delete动作触发，他们使用不同的响应风格, 重定向到不同的地方,返回各自的状态吗和http头信息， 换句话说, http的请求动作是另一个响应控制器影响的因素

> 给定一定数量请求可能的结果,让我们创建一个表格根据http动作和请求类，仔细看看rails控制器脚手架如何生成.


> 默认的所有get请求。通常由index()，show()这样actions处理，为导航请求new()渲染一个模板
> 如果我们有一个api请求，我们要么渲染一个模板像.jbuilder模板，或者渲染资源表现形式（例如to_json）

> 目前，我们知道一个脚手架控制器如何响应一个get请求，在两种这两种请求类型发生时如下图
> 现在，让我们通过http动作，填满整个表格

![](14.png)


######Resource Status

> 如果我们分析create()action,代表了一个post请求，我们知道他有两个分支,一个是资源保存成功,另一个是失败，这些分支都使用了不同响应的方式.

    def create
    @user = User.new(user_params)
    respond_to do |format|
    if @user.save
    format.html { redirect_to @user, notice: 'User was successfully created.' }
    format.json { render action: 'show', status: :created, location: @user }
    else
    format.html { render action: "new" }
    format.json { render json: @user.errors, status: :unprocessable_entity }
    end
    end
    end

> 资源状态决定了脚手架生成的控制器如何响应,在上面例子中，如果资源保存成功我们重定向,但是如果保存失败就渲染一个错误页面,返回相应错误,我们在update()action中也看到这个模式，update是通过patch和put请求调用


> 虽然脚手架生成的destroy()action没有依赖资源状态,由于resource.destroy返回false，我们或许最后需要手动处理这种情况,例如,假设一个组设置有几个管理者，因为一个组需要至少一个管理者，我们实现一个before_destroy()回调，检查每次尝试删除管理者的操作，如果条件不存在，回调和destroy()方法都返回false. 这种新场景，我们需要手动在控制器里处理,通常是修改destroy()action来展示一个flash message,并且重定向到group页面， 换句话说,即使脚手架生成的destroy()action不需要依赖资源状态, delete请求或许需要。

> 也就是说控制器为了响应post,put和delete请求，需要知道资源状态.我们的表格描述了这些新场景
>填充了每个请求的类型,http请求类型，和资源状态

![](15.png)

> 无论何时，你在控制器调用respond_with()方法，他都会调用ActionController::Responde类
>无非是用ruby代码编写整个表。 让我们看一下ActionController::Responder的实现和如何修改他的行为



######6.2　Exploring ActionController::Responder

> 通过call应对任何响应,允许接收三个参数,作为一个响应者,传递给call方法的三个参数是当前控制器,资源(一个嵌套资源或一个数组资源),和一个包含选项的hasｈ,　传递给respond_with()所有选项转发给responder作为第三个参数。


> 在 rails源码中，看到ActionController::Responder实现call()方法只有一行代码。

    rails/actionpack/lib/action_controller/metal/responder.rb
    def self.call(*args)
     new(*args).respond
    end

> call方法传递这三个参数给ActionController::Responder初始化，然后调用respond()

    rails/actionpack/lib/action_controller/metal/responder.rb
    # Main entry point for responder responsible
    # for dispatching to the proper format.
    def respond
    method = "to_#{format}"
    respond_to?(method) ? send(method) : to_format
    end
    # HTML format does not render the resource,
    # it always attempts to render a template.
    def to_html
    default_render
    rescue ActionView::MissingTemplate => e
    navigation_behavior(e)
    end
    # to_js simply tries to render a template.
    # If no template is found, raises the error.
    def to_js
    default_render
    end
    # All other formats follow the procedure below. First we
    # try to render a template. If the template is not available,
    # we verify if the resource responds to :to_format and display it.
    def to_format
    if get? || !has_errors? || response_overridden?
    default_render
    else
    display_errors
    end
    rescue ActionView::MissingTemplate => e
    api_behavior(e)
    end


> respond()方法检查当前responder是否可以处理当前请求格式，对于请求格式调用对应方法，否则调用to_format().因为ActionController::Responder仅仅定义了to_html()和to_js()方法，仅有html和js请求有自定义行为，其他都是调用to_foramt()


> 通过分析to_html和to_format()实现，我们看到前者使用navigational_behavior()响应后者使用api_behavior()响应，如果我们加入一个新的navigational格式到application里，例如MOBILE
> responder将把他才能工作一个api格式， 而不是navigational(导航)格式，幸运的是,因为知道responder如何工作,我们让MOBILE请求使用导航行为，在初始化里，通过简单的将:to_mobile设置为:to_html别名

>此外，注意，一个responder总是在回到api或者navigational之前在调用default_render()

    rails/actionpack/lib/action_controller/metal/responder.rb
      def to_html
      default_render
      rescue ActionView::MissingTemplate => e
      navigation_behavior(e)
      end

> default_render()简单的尝试渲染一个模板，没有被渲染出来performed?()返回false，或则模板没有找到，抛出ctionView::MissingTemplate，异常被捕获，允许responders介入

> 下面是rails如何实现navigational_behavior() and api_behavior()

    rails/actionpack/lib/action_controller/metal/responder.rb
    DEFAULT_ACTIONS_FOR_VERBS = {
    post: :new,
    patch: :edit,
    put: :edit
    }
    # This is the common behavior for formats associated
    # with browsing, like :html, :iphone and so forth.
    def navigation_behavior(error)
    if get?
    raise error
    elsif has_errors? && default_action
    render :action => default_action
    else
    redirect_to navigation_location
    end
    end
    # This is the common behavior for formats associated
    # with APIs, such as :xml and :json.
    def api_behavior(error)
    raise error unless resourceful?
    if get?
    display resource
    elsif post?
    display resource, :status => :created, :location => api_location
    else
    head :no_content
    end
    end
    def resourceful?
    resource.respond_to?("to_#{format}")
    end
    def has_errors?
    resource.respond_to?(:errors) && !resource.errors.empty?
    end
    def resource_location
    options[:location] || resources
    end
    alias :navigation_location :resource_location
    alias :api_location :resource_location
    # Display is just a shortcut to render a resource with the current format.
    #
    #
    display @user, status: :ok
    #
    # For XML requests it's equivalent to:
    #
    #
    render xml: @user, status: :ok
    #
    # Options sent by the user are also used:
    #
    #
    respond_with(@user, status: :created)
    #
    display(@user, status: :ok)
    #
    # Results in:
    #
    #
    render xml: @user, status: :created
    #
    def display(resource, given_options={})
    controller.render given_options.merge!(options).merge!(format => resource)
    end


> navigational_behavior()方法实现了上面的表格。对于一个get请求抛出一个missing-template错误，因为对于get请求的唯一选项是渲染一个模板，我们已经尝试渲染了，没有成功。

> 对于其他的http请求类型,navigational行为检查是否资源有错误，如果有错误，并且默认action给定，他渲染通过DEFAULT_ACTIONS_FOR_VERBS hash指定的默认action，最后如果资源没有错误，重定向到资源，就是我们希望的成功的分支


> api_behavior()实现方式不同，使用display()方法，合并传递给respond_with()方法，在调用render之前添加一个format。换句话说，我们调用respond_with()如下

    respond_with @user, status: :created

> 通过get请求，得到json格式，下面是控制器的响应

    render json: @user, status: :created


> 重要一点是rails的responders不会调用@user.to_json,他们简单的委派给render()方法，所以是:json渲染器，在writing the render那章节1.2小节讲到。这是重要的一点，因为人们可以添加渲染器，不用在工作的responder添加任何代码。


> 最后，在responders中最后的一个定制能够在我们自己的控制器里完成，假设我们有一个responder工作的很好，除了一个特殊的action和格式，我们想让它行为不同，我们定制这个responder为这种情况，使用和在respond_to里一样的块api

      def index
      @users = User.all
      respond_with(@users) do |format|
      format.json { render json: @users.to_json(some_specific_option: true) }
      end
      end

>这些可以工作，因为respond_with专递这个块给了format.json去响应，当请求格式是json时。
> 前面章节看到default_render()方法响应片段调用这个块，无论block是否有效。

>使用ActionController::Responder最大优点是,它集合了我们application应有恩恩每种行为。
> 就是说。我们想立刻改变控制器的行为，我们仅仅需要创建我们自己的responder和配置rails使用它，如下

    ApplicationController.responder = MyAppResponder

> 此外，我们可以自定义responder为我们程序里指定的控制器

    class UsersController < ApplicationController
      self.responder = MyCustomUsersResponder
    end

> 让我们创建一个responder使用一些扩展性为和配置rails使用它