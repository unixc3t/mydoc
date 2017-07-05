### Building Models with Active Model

> 前面章节，我们简要的谈论了Abstract Controller和如何从Action Mailer 和 Action Controller解耦开始减少重复代码，现在我们讨论Active Model

> Active Model 原本用来存放Active Record和Acitve REsource共享的行为,和Abstract Controller一样，需要的功能可以根据选择引入你需要的模块。 Active Model也负责定义程序接口 提供给controllers和views，所以其他orm可以使用active model确保rails行为和使用active record一样

> 让我们通过编写一个mail form 插件来了解Active model,我们将会使用controllers和views， mail form目的是接收一组hash参数,通过post 请求传过来的，我们验证他们，然后将他们发送到指定邮件地址, 这种抽象将允许我们在几分钟内创建完整功能的联系人表单！


##### 2.1 Creating Our Model

> Mail Form 对象属于model-view-controller结构中Model那部分,作为接收从表单发送信息的接受者和通过业务模型提交到指定存储容器, 我们以active record工作的方式构造MailForm::Base,我们提供了一个类名MailForm::Base的类，
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

> 我们同时委派给attr_accessor()来实现 attributes方法 在我们再次运行测试之前，我们需要确保MailForm::Base被加载, 一种办法是直接使用require 'mail_form/base'在lib/mail_form.rb中，另一种是使用ruby的autoload()替代

    mail_form/lib/mail_form.rb
    module MailForm
      autoload :Base, "mail_form/base"
    end

> autoload()允许我们延迟加载一个常量,当第一次引用他的时候, 所以我们备注MailForm为一个叫做Base的常量,定义在
> mail_form/base.rb中，当MailForm::Base被第一次引用时,ruby读取这个mail_form/base.rb文件，这是一种惯用法，被用于ruby gem或者rails自己用来快速加载，不需要预先马上将所有东西都加载

> 使用autoload()，我们的实测通过了，我们有了一个拥有attributes的简单模型， 目前，我们没有使用任何active model的特性，


###### Adding Attribute Methods

> ActiveModel::AttributeMethods 是一个模块,追踪定义的属性,允许我们使用通用的行为动态定义他们，为了展示是如何工作的，我们定义两个快捷方法，clear_name()和clear_email()，用来清除关联的属性值，让我们写一个测试

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
      include ActiveModel::AttributeMethods
      attribute_method_prefix 'clear_'
        # 1) attribute methods behavior
        # 2) clear_ is attribute prefix
         def self.attributes(*names)
         attr_accessor(*names)

        3) Ask to define the prefix methods for the given attribute names
        define_attribute_methods(names)
      end
      protected
        # 4) Since       we declared a "clear_" prefix, it expects to have a
        # "clear_attribute" method defined, which receives an attribute
        # name and implements the clearing logic.
        def clear_attribute(attribute)
          send("#{attribute}=", nil)
        end
      end
      end

> 运行测试,所有测试都应该全部通过,ActiveModel::AttributeMethods使用Method_missing()编译clear_name和clear_email()方法，当他们第一次被访问的时候，他们的实现是调用clear_attribute()传递属性名作为参数

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
        # 1) Add the attribute suffix
        attribute_method_suffix '?'

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

> active record广泛的使用了属性方法，一个例子就是attribute_before_type_cast()方法，使用了_before_type_cast作为后缀，返回流数据，将接收到表单的数据， 脏功能检查，也是active modeld的一部分，
> 基于顶部ActiveModel::AttributeMethods和定义几个方法，例如 attribute_changed?() , reset_attribute!() ,等等，你可以看一下源码的脏实现代码


###### Aiming for an Active Model–Compliant API

> 即使我们加入了属性到我们的models里用来存储form数据，我们需要确保我们的模型兼容active model api, 否则，就不能在controller和views里使用

> 像往常一样，我们将实现兼容，通过测试驱动开发，除了这次我们不需要编写测试,rails已经提供了一个叫ActiveModel::Lint::Tests模块，当我们included时，这个模块定义了几个测试断言，active model
>都需要兼容这些api，这些测试都期望一个叫做@model实例变量，我们在这个对象上进行断言，在我们的例子里，@model应该包含一个SampleMail实例,如果MailForm::Base是兼容的这个SampleMail也会被兼容，
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

> 虽然我们可以添加方法到MailForm::Base里面，我们自己不会去实现它，相反，我们引入 ActiveModel::Conversion
> 来实现 to_model正如我们刚才讨论的，active Model还需要3个方法to_key() , to_param() , and to_partial_path() 

> to_key()方法返回一个数组，里面包含识别对象的唯一key，如果存在，就在views中被dom_id()方法使用，dom_id()方法被添加到rails和dom_class()一起，还有一组其他帮助方法，可以更好的组织我们的view,例如div_for(@post),@post是一个 Active Record,Post类实例，id是42，基于这些方法，创建一个div，然后id attribute等于 post_42,
> class attribute 是post， 对于Active Record，to_key()返回一个数组包含记录ID

> 另一方面，to_param用于路由，能够被被Model生成的url覆盖，当我们调用post_path(@post)时，rails调用
>@post对象中的to_param方法，使用它生成的结果作为最终url， 对于Active Record，默认返回ID作为字符串

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

> 在使用ActiveModel::Naming扩展我们的类之后，它响应了一个叫做model_name()方法，返回一个ActiveModel::Name 实例， 类似字符串，提供了一些方法，例如，human(),singular(),和其他都是与名字相关改变词形方法，让我们添加一个测试到我们的测试套件里， 

    test "model_name exposes singular and human name" do
      assert_equal "sample_mail", @model.class.model_name.singular
      assert_equal "Sample mail", @model.class.model_name.human
    end

> 这与Active Record的预览行为类似，仅有的不同是active Record支持 国际化，MailForm就没这么幸运，但是可以使用ActiveModel::Translation扩展MailFormatter::Base，让我们写一个测试

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

> 这个测试添加了一个翻译到i18n末端，包含了SampleMeail类的人类可读形式，我们需要包装代码
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

> 第一个失败信息和validations有关，Active Model没有告诉任何有关验证的宏命令(例如 validates_presence_of()), 但是他需要们定义一个方法叫做errors(), 返回一个hash,
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

> 这次,rails没有帮助我们，幸运的是，可以很简单的实现persisted?()方法，我们的controller和views都是用这个persisted?()方法在不同的情况,例如，无论什么时候，我们调用
> form_for(@model),它都会检查model是否存在， 如果存在，就创建一个Put请求，如果不存在
> 就创建一个Post请求， 对于url_for也是一样的操作，生成的url取决于你的model

> Active Record里，如果保存对象到数据库里，那么对象就是持久化的，换句话说，如果既不是新记录，也没被销毁， 然而，在我们的例子里，我们的对象没有保存到任何数据库， persisted?()应该总是返回false.


> 让我们添加persisted?()方法到我们的MailForm::Base里

    mail_for/lib/mail_form/base.rb
    def persisted?
     false
    end

> 这次，运行，rake test后，所有测试通过了，这意味着我们的模型符合active model api


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


> 当我们运行新的测试，我们得到一个失败，因为deliver()方法根本没存在，因为我们的模型具有来自ActiveModel::Validations的正确性的概念， deliver()方法应该在valid?为真时，发送邮件

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

> contact()方法给@mail_form赋值，通过给定的Mai Form对象，然后条用headers方法，这个方法应该返回一个拥有邮件数据，并且使用:to,:form,:subject为key的hash, 这个方法，不应该在MailForm::Base中定义，而是在其子类中， 这是个简单的但是强大的api设计，允许一个开发者定制邮件提交方式，不需重定义或者使用猴子补丁，对于Notifier class来说.

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