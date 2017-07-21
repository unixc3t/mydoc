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