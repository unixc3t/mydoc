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