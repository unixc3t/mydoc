### Building Models with Active Model

> 前面章节，我们简要的谈论了Abstract Controller和它如何从Action Mailer 和 Action Controller解耦减少重复代码，现在我们讨论Active Model,也类似

> Active Model 原本用来存放Active Record和Acitve REsource共享的行为,和Abstract Controller一样，需要的功能可以根据选择引入你需要的模块。 Active Model也负责定义程序接口 提供给controllers和views，所以其他orm使用active model确保rails行为和它使用active record一样

> 让我们通过编写一个mail form 插件来了解Active model,我们将会使用controllers和views， mail form目的是接收一组hash参数,通过post 请求传过来的，我们验证他们，然后将他们发送到指定邮件地址, 这种抽象将允许我们在几分钟内创建完整功能的联系人表单！


##### 2.1 Creating Our Model

> Mail Form 对象属于model-view-controller结构中Model那部分,接收从表单发送的信息并且发送到业务模型指定接收者,让我们以Active Record的工作方式构造MailForm::Base,我们提供了一个类名MailForm::Base的类，
> 包含了最需要的特性，指定属性的能力,与rails form无缝集成， 和我们前面章节做的一样，我们使用rails plugin 创建新插件

    rails plugin new mail_form

> 我们第一个特性就是实现一个类方法叫做attributes()，允许开发者指定Mail form对象包含那些属性，让我们在test/fixtures/sample_mail.rb创建一个模型作为fixture，在我们的测试里使用

  mail_form/test/fixtures/sample_mail.rb

  class SampleMail < MailForm::Base
    attributes :name, :email
  end

> 然后，我们加入一个测试确保我们定义的属性 name和email可以被访问，在我们的mail form对象里

  require "test_helper"
  require "fixtures/sample_mail"

  class MailFormTest < ActiveSupport::TestCase
    test "sample mail has name and email as attributes" do
      sample = SampleMail.new
      sample.name = "User"
      assert_equal "User", sample.name
      sample.email = "user@example.com"
      assert_equal "user@example.com", sample.email
    end
  end

> 当我们使用命令 rake test运行时，失败了，因为MailForm::Base，没有定义，让我们在lib/mail_form/base.rb里定义，同时实现attributes方法

    mail_form/lib/mail_form/base.rb
    module MailForm
      class Base
        def self.attributes(*names)
         attr_accessor(*names)
        end
      end
    end

> 我们委派给attr_accessor()来实现 attributes方法 在我们再次运行测试之前，我们需要确保MailForm::Base被加载, 一种办法是直接使用require 'mail_form/base'在lib/mail_form.rb中，另一种是使用ruby的autoload()替代

    mail_form/lib/mail_form.rb
    module MailForm
      autoload :Base, "mail_form/base"
    end

> 当第一次引用他的时候，autoload()允许我们延迟加载一个常量, 所以我们将定义在mail_form/base.rb中的MailForm备注为一个叫做Base的常量，当MailForm::Base被第一次引用时,ruby读取这个mail_form/base.rb文件，这是一种惯用法，被用于ruby gem或者rails自己用来快速加载，不需要预先马上将所有东西都加载

> 通过使用autoload()，我们的实测通过了，我们有了一个拥有attributes的简单模型， 目前，我们没有使用任何active model的特性，


###### Adding Attribute Methods

> ActiveModel::AttributeMethods 是一个模块,追踪定义的属性,允许我们使用供用的行为动态定义他们，为了展示是如何工作的，我们定义两个快捷方法，clear_name()和clear_email()，用来清除关联的属性值，让我们写一个测试

    mail_form/test/mail_form_test.rb
    test "sample mail can clear attributes using clear_ prefix" do
      sample = SampleMail.new
      sample.name  = "User"
      sample.email   = "user@example.com"

      assert_equal "User", sample.name
      assert_equal "user@example.com", sample.email
   
    
      sample.clear_name
      sample.clear_email
      
      assert_nil sample.name
      assert_nil sample.email
    end


> 调用clear_name()和clear_email()方法时，设置他们各自的属性值为nil, 使用ActiveModel::AttributeMethods，我们能够动态的定义clear_name()和clear_email()，使用4个简单步骤，下面是代码实现

    mail_form/lib/mail_form/base.rb

    module MailForm
      class Base
        include ActiveModel::AttributeMethods  # 1) attribute methods behavior
        attribute_method_prefix 'clear_'       # 2) clear_ is attribute prefix
        
        def self.attributes(*names)
          attr_accessor(*names)

          3) Ask to define the prefix methods for the given attribute names
          define_attribute_methods(names)
        end

        protected
        # 4) Since we declared a "clear_" prefix, it expects to have a
        # "clear_attribute" method defined, which receives an attribute
        # name and implements the clearing logic.

        def clear_attribute(attribute)
          send("#{attribute}=", nil)
        end
      end
    end

> 运行测试,所有测试都应该全部通过,当他们第一次被访问的时候,ActiveModel::AttributeMethods使用Method_missing()编译clear_name和clear_email()方法，他们的实现是调用clear_attribute()并传递属性名作为参数

> 如果你想定义后缀方法替代前缀clear_，我们需要使用attribute_method_suffix()方法，用所选择的后缀逻辑实现该方法，下面例子我们实现了name?()和email?()方法，如果相关的属性值存在就返回true，测试如下

    mail_form/test/mail_form_test.rb
      test "sample mail can ask if an attribute is present or not" do
      sample = SampleMail.new
      assert !sample.name?
      sample.name = "User"
      assert sample.name?
      sample.email = ""
      assert !sample.email?
    end

> 当我们运行测试套件， 我们的新测试失败了, 为了实现?作为前缀，修改我们的MailForm::Base实现如下

    mail_form/3_attributes_suffix/lib/mail_form/base.rb
    module MailForm
      class Base
        include ActiveModel::AttributeMethods
        attribute_method_prefix 'clear_' 
        
        attribute_method_suffix '?' # 1) Add the attribute suffix

          def self.attributes(*names)
            attr_accessor(*names)
            define_attribute_methods(names)
          end
          protected

          def clear_attribute(attribute)
           send("#{attribute}=", nil)
          end
          # 2) Implement the logic required by the '?' suffix
          def attribute?(attribute)
            send(attribute).present?
          end
      end
    end

> 现在我们有了前缀和后缀方法并且测试通过,但是，如果我们想同时定义前缀和后缀方法呢？我们可以使用 attribute_method_affix()方法，允许接收一个包含了prefix和suffix的hash

     attr_accessor :name
      attribute_method_affix prefix: 'reset_', suffix: '_to_default!'
      define_attribute_methods :name
    
      private

      def reset_attribute_to_default!(attr)
        send("#{attr}=", 'Default Name')
      end
    end

> active record广泛的使用了属性方法，一个例子就是attribute_before_type_cast()方法，使用了_before_type_cast作为后缀，将接收到表单的数据，返回流数据，这个肮脏的功能，也是active modeld的一部分，
> 基于ActiveModel::AttributeMethods构建和定义几个方法，例如 attribute_changed?() , reset_attribute!() ,等等，你可以看一下源码的实现代码


###### Aiming for an Active Model–Compliant API

> 即使我们加入了属性到我们的models里用来存储form数据，我们需要确保我们的模型兼容active model api, 否则，就不能在controller和views里使用

> 像往常一样，我们通过测试驱动开发将实现兼容，除了这次我们不需要编写测试,rails已经提供了一个叫ActiveModel::Lint::Tests模块，当我们included时，这个模块定义了几个测试断言，active model中都需要这些方法存在
>都需要兼容这些api，这些测试都期望一个叫做@model实例变量，我们在这个对象上进行断言，在我们的例子里，@model应该引用一个SampleMail实例,如果MailForm::Base是兼容的这个SampleMail也会被兼容，
> 让我们创建一个新的测试文件叫做test/compliance_test.rb


    require 'test_helper'
    require 'fixtures/sample_mail'
       class ComplianceTest < ActiveSupport::TestCase
          include ActiveModel::Lint::Tests
          def setup
             @model = SampleMail.new
          end
    end

> 当我们运行rake test时，我们得到几个失败结果，原因是

    the object should respond to to_model

> 当rails cotroller和view帮助方法接收到一个Model,首先调用,to_model并且直接操作这个方法返回值，用来替代操作model，这就允许orm实现了不想加入active model api到他们自己的api里，所以返回一个代理对象，定义这些方法返回代理对象，在我们的例子里，我们想直接加入 active model 方法到MailFOrm::Base,所以，我们to_model()方法返回self,

    def to_model
        self
    end

> 虽然我们可以添加方法到MailForm::Base里面，我们自己不会去实现它，相反，正如我们刚才讨论的，我们引入 ActiveModel::Conversion
> 来实现 to_model，active Model还需要3个方法to_key() , to_param() , and to_partial_path() 

> to_key()方法返回一个数组，里面包含识别对象的唯一key，如果存在，就在views中被dom_id()方法使用，dom_id()方法被添加到rails和dom_class()一起，还有一组其他帮助方法，可以更好的组织我们的view,例如div_for(@post),@post是一个 Active Record,Post类实例，id是42，基于这些方法，创建一个div，然后div的id attribute等于 post_42,
> class attribute 是post， 对于Active Record，to_key()返回一个数组包含记录ID

> 另一方面，to_param用于路由，能够被任何Model覆盖，用于生成的唯一url，当我们调用post_path(@post)时，rails调用
>@post对象中的to_param方法，使用它生成的结果作为最终url， 对于Active Record，默认返回ID作为字符串

    例如点击show动作 url导航后面的users/id 我们可以使用这个方法修改id形式 例如 users/id-name

 >最后，我们有to_partial_path()方法，这个方法在每次我们传递一个记录或者一个记录集合给我们视图中render()在时调用， rails将会检查每条记录，得到他们的局部路径，例如 post类实例路径就是posts/post

 > 重要的不仅仅是理解这些方法做什么，也要知道他们允许我们完成什么，例如，通过定制to_param()，我们可以简单的改变我们对象的URL, 假设一个Post类，有id和title属性， 改变这些posts的url,添加title

      def to_param
          "#{id}-#{title.parameterize}"
      end

> 类似，假设每个Post对象有一个不同的格式， 可能是video,link,一组文本，每种格式渲染不同, 如果我们使用format属性存储文章格式，我们能够渲染每片文章如下

    @posts.each do |post|
      render partial: "posts/post_#{post.format}",
      locals: { post: @post }
    end

> 然而，覆盖to_partial_path()方法像下面

    def to_partial_path
      "posts/post_#{format}"
    end

> 在view可以按照下面方式使用

    render @posts

> 这样做不仅让我们代码简洁，同时提高我们程序性能,在第一个例子中，我们每次都要以遍历rails渲染栈结束， 查找模板，复制同样操作，然而，通过定制,to_partial_path()，我们仅仅调用render()一次，让rails找到所有需要的部分

> 默认的to_partial_path()实现在ActiveModel::Conversion中，允许我们提供MailForm::Base对象的一部分作为
> Active Record对象，然而，我们的对象永远不会被持久化，他们是不是唯一，伊诶这to_key()和to_param()应该返回nil,直接由ActiveModel::Conversion提供，，在MailFOrm::Base类引入

    mail_form/lib/mail_form/base.rb
      module MailForm
        class Base
        include ActiveModel::Conversion

>当我们引入这个module,然后运行rake test,我们得到下面错误信息

      The model should respond to model_name
      The model should respond to errors
      The model should respond to persisted?

> 为了解决这个错误，我们需要MailForm::Base继承ActiveModel::Naming

    mail_form/lib/mail_form/base.rb
    module MailForm
      class Base
        include ActiveModel::Conversion
        extend ActiveModel::Naming

> 在使用ActiveModel::Naming扩展我们的类之后，它响应了一个叫做model_name()方法，返回一个ActiveModel::Name 实例， 类似字符串，提供的一些方法，例如，human(),singular(),和其他都是与名字相关改变词形方法，让我们添加一个测试到我们的测试套件里， 

    test "model_name exposes singular and human name" do
      assert_equal "sample_mail", @model.class.model_name.singular
      assert_equal "Sample mail", @model.class.model_name.human
    end

> 这与Active Record的预览行为类似，仅有的不同是active Record支持 国际化，MailForm不支持，但是可以使用ActiveModel::Translation扩展MailFormatter::Base，让我们写一个测试

    mail_form/test/compliance_test.rb
    test "model_name.human uses I18n" do
      begin
        I18n.backend.store_translations :en,
          activemodel: { models: { sample_mail: "My Sample Mail" } }
        assert_equal "My Sample Mail", @model.class.model_name.human
      ensure
        I18n.reload!
      end
    end

> 这个测试添加了一个翻译到i18n末端，包含了SampleMeail类的可读形式，我们需要包装代码
> 使用begin .. ensure,保证i18n最后重新加载， 移除我们添加的翻译，让我们更新MailForm::Base确保新测试通过

    mail_form/lib/mail_form/base.rb
      module MailForm
        class Base
        include ActiveModel::Conversion
        extend ActiveModel::Naming
        extend ActiveModel::Translation

> 我们添加naming和translation之后，rake test返回更少的错误，我们继续学习，下面是我们失败的原因

    The model should respond to errors
    The model should respond to persisted?

> 第一个失败信息和validations有关，Active Model没有告诉任何有关验证的宏命令(例如 validates_presence_of()), 但是他需要们定义一个方法叫做errors(), 这个方法返回一个hash,
> hash中的每个值都是一个数组，我们可以修正这个报错信息，通过引入ActiveModel::Validations在我们的模型里

    mail_form/lib/mail_form/base.rb
    module MailForm
      class Base
        include ActiveModel::Conversion
        extend ActiveModel::Naming
        extend ActiveModel::Translation
        include ActiveModel::Validations

> 现在我们的model实例可以响应errors和valid?(),现在行为和active Record一样，此外，
> ActiveModel::Validations添加了几个验证宏命令,例如，validates()，validates_format_of(),和validates_inclusion_of()

> 现在我们运行rake test 并且看到最后一个错误信息

    The model should respond to persisted?

> 这次,rails没有帮助我们，幸运的是，可以很简单的实现persisted?()方法，不同的情况下，我们的controller和views都是用这个persisted?()方法在,例如，无论什么时候，我们调用
> form_for(@model),它都会检查model是否存在， 如果存在，就创建一个Put请求，如果不存在
> 就创建一个Post请求， 对于url_for也是一样的操作，生成的url取决于你的model

> Active Record里，如果保存对象到数据库里，那么对象就是持久化的，换句话说，如果既不是新记录，也没被销毁， 然而，在我们的例子里，我们的对象没有保存到任何数据库， persisted?()应该总是返回false.


> 让我们添加persisted?()方法到我们的MailForm::Base里

    mail_for/lib/mail_form/base.rb
    def persisted?
     false
    end

> 这次，运行，rake test后，所有测试通过了，这意味着我们的模型兼容了active model api


#### Delivering the Form

> 下一步在我们的Mail Form实现逻辑添加，使用模型属性发送一个email, deliver()方法负责提交，
> 发送邮件到我们email属性存储的地址， 邮件包含所有模型属性值，我们添加一个测试

    mail_form/test/mail_form_test.rb
    setup do
       ActionMailer::Base.deliveries.clear
    end

    test "delivers an email with attributes" do
      sample = SampleMail.new
      # Simulate data from the form
      sample.email = "user@example.com"
      sample.deliver
      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal ["user@example.com"], mail.from
      assert_match "Email: user@example.com", mail.body.encoded
    end


> 当我们运行新的测试，我们失败了，因为deliver()方法根本没存在，因为我们的模型具有来自ActiveModel::Validations的正确性的概念， deliver()方法应该在valid?为真时，发送邮件

    mail_form/lib/mail_form/base.rb
    def deliver
      if valid?
        MailForm::Notifier.contact(self).deliver
      else
        false
      end
    end

> 负责创建和发送邮件是MailForm::Notifier类， 使用Action Mailer实现它

    mail_form/lib/mail_form/notifier.rb
      module MailForm
        class Notifier < ActionMailer::Base
          append_view_path File.expand_path("../../views", __FILE__)
          def contact(mail_form)
          @mail_form = mail_form
          mail(mail_form.headers)
          end
        end
      end

> contact()方法通过传递的Mail Form对象给@mail_form赋值，然后调用headers方法，这个方法应该返回一个拥有邮件数据，并且使用:to,:form,:subject为key的hash, 这个方法，不应该在MailForm::Base中定义，而是在其子类中， 这是个简单的但是强大的api设计，允许一个开发者定制邮件提交方式，不需重定义或者使用猴子补丁，对于Notifier class来说.

> 我们的MailForm::Notifer也调用append_view_path()方法，添加lib/views在我们的插件目录，
>作为一个新的搜索模板的地址，最后一步之前，我们运行测试套件加在我们的新类

    mail_form/lib/mail_form.rb
    autoload :Notifier, "mail_form/notifier"

> 我们定义headers()方法，在SampliMail 类中

    mail_form/test/fixtures/sample_mail.rb
    def headers
      { to: "recipient@example.com", from: self.email }
    end

> 当我们运行rake test，出现下面失败信息

    1) Failure:
    test_delivers_an_email_with_attributes(MailFormTest):
    ActionView::MissingTemplate: Missing template mail_form/notifier/contact

> 这是意料之中，我们没有添加模板给我们的mailer,我们的默认邮件模板展示主题消息和打印所有属性和他们的值

    mail_form/lib/views/mail_form/notifier/contact.text.erb
    <%= message.subject %>
    <% @mail_form.attribute_names.each do |key| -%>
    <%= @mail_form.class.human_attribute_name(key) %>: <%= @mail_form.send(key) %>
    <% end -%>

> 为了显示素有属性，我们需要全部属性名字列表，但是我们目前没有这样的列表， 我们可以通过class_attribute()实现这个attributes_names(),每次调用attributes被调用时更新attributes_names

    mail_formlib/mail_form/base.rb
    # 1) Define a class attribute and initialize it
      class_attribute :attribute_names
      self.attribute_names = []

      def self.attributes(*names)
        attr_accessor(*names)
        define_attribute_methods(names)

         # 2) Add new names as they are defined
        self.attribute_names += names
      end

> 当我们使用class_attributes()用来定义names,names可以自动被继承，如果一个类继承我们的sampleMail fixture,那么它自动继承全部属性名。

> 在我们运行 rake test, 所有的测试应该是绿色的，我们的Mail Form实现完成，无论何时我们需要创建一个联系表单，我们就创建一个类，继承自MailForm::Base,我们定义我们的attributes和邮件headers
>我们准备好开始了， 确保一切正确，我们使用集成测试工具来检查


#### 2.2 Integration Tests with Capybara

> 前面章节,我们使用rails测试工具确保一个pdf被发送到客户端，为了保证我们的项目可以像一个联系表单那样工作，我们应该创建一个真实的表单，提交它到适当的后端，验证邮件是否发送成功，如果使用rails测试工具实际上比较难写，大多数时候，
> 我们最后直接编写一个request到后端，

    post "/contact_form", contact_form:
    { email: "jose@example.com", message: "hello"}


> 编写一个使用Post()方法请求，指明参数，对一些场景很有用，尤其是对于api测试，但是当测试一个表单工作流就不太合适，例如我们如何确保一个提交按钮在页面上存在？当我们点击它之后会发生什么？，发送请求给URL地址？如果我们忘记邮件field填写怎么办？

> 为了保证这些问题可以解决，通常使用Capybara.这样更健壮的测试工具，capybara提供了简单的dsl语言应对这种琐碎测试。我们首先在开发依赖中添加

    mail_form/mail_form.gemspec
    s.add_development_dependency "capybara", "~> 2.0.0"

> 为了使用Capybara，我们定义一个新的测试用例类，叫做ActiveSupport::IntegrationCase，这个类基于ActiveSupport::TestCase构建，引入了rails的url帮助方法和capybara dsl

      mail_form/test/test_helper.rb
      require "capybara"
      require "capybara/rails"

      # Define a bare test case to use with Capybara
      class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
        include Capybara::DSL
        include Rails.application.routes.url_helpers
      end

> 现在我们准备编写第一个测试

    mail_form/5_delivery/test/integration/navigation_test.rb
    require "test_helper"

    class NavigationTest < ActiveSupport::IntegrationCase
      setup do
       ActionMailer::Base.deliveries.clear
      end

      test "sends an e-mail after filling the contact form" do
        visit "/"
        fill_in "Name",
        with: "John Doe"
        fill_in "Email",
        with: "john.doe@example.com"
        fill_in "Message", with: "MailForm rocks!"
        click_button "Deliver"

        assert_match "Your message was successfully sent.", page.body
        assert_equal 1, ActionMailer::Base.deliveries.size
        mail = ActionMailer::Base.deliveries.last
        assert_equal ["john.doe@example.com"], mail.from
        assert_equal ["recipient@example.com"], mail.to
        assert_match "Message: MailForm rocks!", mail.body.encoded
      end
    end

> 这个集成测试首先访问根目录，返回一个有name,email,message fields的表单，提交这个表单，服务器会发送一个邮件给收件人，并且返回用户一个成功信息， 为了确保测试通过，，我们添加model,controller,和view，和路由，在虚拟app里面添加这些，我们先开始路由配置

    mail_form/test/dummy/config/routes.rb

    Dummy::Application.routes.draw do
      resources :contact_forms, only: :create
      root to: "contact_forms#new"
    end

> 然后是控制器和试图

    mail_form/test/dummy/app/controllers/contact_forms_controller.rb
    class ContactFormsController < ApplicationController
      def new
         @contact_form = ContactForm.new
      end

        def create
          @contact_form = ContactForm.new(params[:contact_form])

          if @contact_form.deliver
              redirect_to root_url, notice: "Your message was successfully sent."
           else
            render action: "new"
          end
        end
    end

    mail_form/test/dummy/app/views/contact_forms/new.html.erb
    <h1>New Contact Form</h1>
    <%= form_for(@contact_form) do |f| %>
    <% if @contact_form.errors.any? %>
    <div id="errorExplanation">
    <h2>Oops, something went wrong:</h2>
    <ul>
    <% @contact_form.errors.full_messages.each do |msg| %>

    <li><%= msg %></li>
    <% end %>
    </ul>
    </div>
    <% end %>
    <div class="field">
    <%= f.label :name %><br />
    <%= f.text_field :name %>
    </div>
    <div class="field">
    <%= f.label :email %><br />
    <%= f.text_field :email %>
    </div>
    <div class="field">
    <%= f.label :message %><br />
    <%= f.text_field :message %>
    </div>
    <div class="actions">
    <%= f.submit "Deliver" %>
    </div>
    <% end %>

> 最后是model

    class ContactForm < MailForm::Base
      attributes :name, :email, :message
      def headers
        { to: "recipient@example.com", from: self.email }
      end
    end

> 因为我们测试使用了flash messages，所以我们需要添加他们到layout文件 在yield前面调用

    <p style="color: green"><%= notice %></p>

> 所有都就位了，我们开始运行测试，得到了一个失败信息

    1) Error:
    test_sends_an_e-mail_after_filling_the_contact_form(NavigationTest):
    ArgumentError: wrong number of arguments (1 for 0)
    app/controllers/contact_forms_controller.rb:7:in `initialize'

  
> 这个失败信息发生，因为initialize()方法，不像active Record 不需要一个hash作为参数，active model兼容api没有告诉我们任何关于我们模型如何被初始化，让我们实现一个Initialize()方法， 接收一个hash作为参数，设置属性值

    mail_form/lib/mail_form/base.rb
    def initialize(attributes = {})
      attributes.each do |attr, value|
      self.public_send("#{attr}=", value)
      end if attributes
    end

> 在我们定义完了前面的方法，我们的集成测试成功了， 结果如我们预期，记住，你可以进虚拟application里，rails s启动程序，加入一些验证


#####　2.3　Taking It to the Next Level

> 前面章节，我们编写了我们的邮件插件使用了基本特性和添加了集成测试确保它工作，现在我们可以使用active model做更多事，让我们看一些例子


###### Validators

> 每个rails 开发者都熟悉rails validations,他们经常被用来证明可以提高生产力，　在rails源码中，每个验证器背后都有一个validator类，让我们看看validates_presence_of这个宏方法

    rails/activemodel/lib/active_model/validations/presence.rb
    def validates_presence_of(*attr_names)
      validates_with PresenceValidator, _merge_attributes(attr_names)
    end

> validates_with 方法负责初始化，传递的ActiveModel::Validations::PresenceValidator类，　_merge_attributes()将传递的属性转换成hash, 可以让你按照下面调用

    validates_presence_of :name

> 实际上等同于你是这么做

  　validates_with PresenceValid, attributes: [:name]

> 大致与下面相同

    validate PresenceValidator.new(attributes: [:name])

> 这种处理方式类似预先使用validates方法
  
    validates :name, presence: true

> 效果与下面一样

    validate PresenceValidator.new(attributes: [:name])

> 问题是，rails怎么知道:presence应该是使用 PresenceValidator? 因为 他将:presence 转换成
> PresenceValidator 然后查找一个常量叫做PrsenceValidator的类， 代码如下

    const_get("#{key.to_s.camelize}Validator")

> 这个描述很重要，因为我们现在可以加入任何验证到任何类，基于ruby的常量查找， 为了理解他怎么工作的。我们打开一个irb，然后输如下面

      module Foo
          module Bar
          end
      end
      class Baz
          include Foo
      end

      Baz::Bar # => Foo::Bar

> 注意最后一行，即使bar没有定义在Baz里，脚本返回Foo::Bar ，发生这个是因为无论什么时候常量查找，ruby搜索所有在祖先链的对象，因为Foo被Baz include,foo是baz祖先，允许ruby查找Foo::Bar常量，沿着祖先连

> 为了给你展示如何使用这个，我们实现一个absence validator验证器在我们的MailForm::Base里，因为许多垃圾邮件来自表单，我们使用absence验证器作为蜜罐

> 这个蜜罐创建一个field，例如Nickname,通过css隐藏，正常人们不会看到这个表单项，也不会填它，然是robots会自动填它像填充其他属性一样，所以。无论什么时候，如果Nickname存在值，就不应该被发送，因为是垃圾邮件

> 根据Ruby的常量查找规则，我们能够给，在一个模块里实现了AbsenceValidator，并且在需要的类里引入了这个模块的任意类的validates()方法添加一个:absence选项
>让我们写一个简单测试

    mail_form/6_final/test/mail_form_test.rb
    test "validates absence of nickname" do
      sample = SampleMail.new(nickname: "Spam")
      assert !sample.valid?
      assert_equal ["is invalid"], sample.errors[:nickname]
    end


> 测试显示验证必须无效。如果nickname包含任何值， 让我们添加Nickname 和：absence验证给我们的SmampleMail对象

    mail_form/test/fixtures/sample_mail.rb
      attributes :nickname
      validates :nickname, absence: true

> 当我们运行测试，我们失败了，因为SampleMail不能读取AbsenceValidator，这个验证器没有定义，我们来创建他

    mail_form/lib/mail_form/validators.rb
    module MailForm
      module Validators
        class AbsenceValidator < ActiveModel::EachValidator
          def validate_each(record, attribute, value)
            record.errors.add(attribute, :invalid, options) unless value.blank?
          end
        end
      end
    end

> 我们的验证器继承了EachValidator，对于每个在初始化的属性值，EachValidator调用validate_each()方法在每条记录上，attribute和它的对应值， 对于每个属性，我们添加一个错误信息，如果他的值不是空。

> 下一步引入验证器

    mail_form/lib/mail_form/base.rb
    include MailForm::Validators

> 我们添加MailForm::Validators到MailForm::Base继承链中,当我们将：absence传给validates方法时，他会去寻找AbsenceValidator常量，在 MailForm::Validators模块中查找，为了确保可以验证器真正运行，我们需要加载我们的验证器

    mail_form/lib/mail_form.rb
    autoload :Validators, 'mail_form/validators'

> 运行测试 ，rake test,所有测试通过了，这个实现相当完美，仅仅添加:absense到validates()方法，不需要我们注册这个选项到其他地方， 这个选项在运行是被找到，

> 将昵称字段添加到我们的联系人表单视图，并使用隐藏他感觉很好，我们的蜜罐完美运行

##### Callbacks

> 如果我们在deliver()方法周围提供回调不是更酷？我们使用activeModel::CallBacks添加，before和after方法， 我们来修改SampleMail fixture


    mail_form/6_final/test/fixtures/sample_mail.rb
    # 下面是使用方式
    before_deliver do
    evaluated_callbacks << :before
    end
    after_deliver do
    evaluated_callbacks << :after
    end
    def evaluated_callbacks
    @evaluated_callbacks ||= []
    end

> 我们添加了一个 evaluated_callbacks()方法来存放所有需要执行的回调函数，包裹我们实现的before_deliver() and after_deliver(), 我们测试断言两个回调是否执行

    mail_form/test/mail_form_test.rb
    test "provides before and after deliver hooks" do
    sample = SampleMail.new(email: "user@example.com")
    sample.deliver
    assert_equal [:before, :after], sample.evaluated_callbacks
    end

> 最后我们将在MailForm::Base添加支持回调 需要三个步骤: 使用ActiveModel::Callbacks扩展我们的类，定义我们的回调，最后重新deliver()实现，

    mail_form/lib/mail_form/base.rb
      # 1) Add callbacks behavior
      extend ActiveModel::Callbacks

       # 2) Define the callbacks. The line below will create both before_deliver
       # and after_deliver callbacks with the same semantics as in Active Record
       # 下面这行就创建了before_deliver和after_deliver回调，如果需要回调就自己重写这俩方法
        define_model_callbacks :deliver

        # 3) Change deliver to run the callbacks
          def deliver
            if valid?
              run_callbacks(:deliver) do
                MailForm::Notifier.contact(self).deliver
              end
            else
              false
          end
        end

> 和active Record回调一样，你可以传递procs string,symbols和任何可以相应回调方法名的对象


##### A Base Model

> 在许多情况下,开发人员想在activemodel实现兼容的API，实现搜索功能时，甚至在将注册流程拆分成多个步骤时
> 对于这点 Active Model 提供了一个ActiveModel::Model模块，可以被任何类包含

    class Person
    include ActiveModel::Model
    attr_accessor :name, :age
    end

> 通过引入 ActiveModel::Model我们确保它通过所有ActiveModel::Lint::Test测试，我们看看源码

      rails/activemodel/lib/active_model/model.rb
      module ActiveModel
        module Model
          def self.included(base)
           base.class_eval do
             extend ActiveModel::Naming
             extend ActiveModel::Translation
             include ActiveModel::Validations
             include ActiveModel::Conversion
          end
        end

        def initialize(params={})
            params.each do |attr, value|
             self.public_send("#{attr}=", value)
            end if params
        end

          def persisted?
            false
          end
        end
      end

> 你可以看到这个模块包含了我们这章实现的所有行为， 在我们的应用程序中需要这些功能时，这是一个很好的起点！