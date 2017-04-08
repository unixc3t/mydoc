#### 16.1 Metadata

> 每个example group和每个example都有丰富元数据与之关联,看下面的的metadata 

    describe "something" do
      it "does something" do
        p example.metadata
      end
    end

> 然后运行这个例子

    rspec metadata.rb

> 输出内容包括一个hash的内容并且包含了它的key，例如 :example_group,:description,:location:,caller,等等
> rspec使用这些内部元数据，进行报告或者过滤，另外，我们能够加入任意元数据，通过 传递一个hash给 describe()和It()类似下面这样

    describe "something", :a => "A" do
      it "does something", :b => "B" do
        puts example.metadata[:a]
        puts example.metadata[:b]
      end
    end

> 运行整个rspec,你会看到 A和B被打印出来，你好奇我们可以用这个能力做什么，我们先看:configuration

#### 16.2 Configuration

> rspec暴漏了一个configuration对象，用来支持全局的 before, after,around回调，类似在例子中
> include模块或者exten example group类

    # rspec-2
    RSpec.configure {|config| ... }
    # rspec-1
    Spec::Runner.configure {|config| ... }

> 这个config参数是配置对象,　暴露了一些方法可以用来在example运行时虑行为，或者扩展行为


####16.3 Filtering

> 有时我们在工作中,我们可能仅仅想运行一个或者几个测试，或者一组测试，我们可以使用提供给我们的　Configurationle类，来实现这个，结合metadata我们使用它加入我们感兴趣的组和例子

##### Inclusion

> 看下面例子

    RSpec.configure do |c|
      c.filter = { :focus => true }
    end

    describe "group" do
      it "example 1", :focus => true do
      end
      it "example 2" do
      end
    end

> 现在运行　这个rspec focused_exampled.rb　你会看到下面输出

    Run filtered using {:focus=>true}
    group
    example 1
    Finished in 0.00066 seconds
    1 example, 0 failures

> 如你所示, 通过metadata传递的:forcus => true给it()方法， exampl1运行了。另一个没有
> 我们在group上尝试使用

    RSpec.configure do |c|
     c.filter = { :focus => true }
    end

    describe "group 1", :focus => true do
      it "example 1" do
      end

      it "example 2" do
      end

      end
      describe "group 2" do
        it "example 3" do
        end
        it "example 4" do
        end
       end
    end

> 运行结果：

    Run filtered using {:focus=>true}
    group 1
    example 1
    example 2
    group 2
    Finished in 0.00092 seconds
    2 examples, 0 failures

> 两个组的名字被打印出来，但是仅有一个组的携带了:focus=>true运行了，我们看到第二组名字，但是没有任何例子运行，　

##### Exclusion

> 排除运行慢的例子，使用元数据过滤

    RSpec.configure do |c|
     c.exclusion_filter = { :slow => true }
    end
    describe "group" do
        it "example 1", :slow => true do
        end

        it "example 2" do
        end
    end

> 运行结果:

    group
      example 2
    Finished in 0.00067 seconds
    1 example, 0 failures

##### Lambdas

> Inclusion and exclusion 允许接收任意的lambdas和复杂的代码。

> 假设一个app,链接了一个外部的服务，大多数example会stub这个服务，但是有一个例子，想用真正的服务来检查，问题就是仅当可以链接网络的时候才能测试，我们不想担心这个测试是否需要关闭，当没有网络的时候，我们使用lambda和 exclusion filter来解决这个

    require 'ping'
    RSpec.configure do |c|
       c.exclusion_filter = {
          :if => lambda {|what|
                    case what
                      when :network_available
                          !Ping.pingecho "example.com", 10, 80
                      end
          }
        }
    end

    describe "network group" do
      it "example 1", :if => :network_available do
      end
      it "example 2" do
      end
    end

> 联网和断网。运行这个测试，观察结果

#### 16.4 Extension Modules

> 除了filter methods方法，Configuration对象还是暴漏了两个方法，我们可以使用这两个方法扩展某个example group ，两个方法都接收options, 来匹配每组的元数据，按顺序过滤

* include(*modules, options={}) include提交的module或者modules,在example groups中使用， 使模块的方法在每个example group中都有效

* extend(*modules, options={}) extends 选中的example groups 使用给定的Modules或module, 推荐使用 macros方式

> eg:

    module Helpers
      def help
        :available
      end
    end

> Include a module in all example groups

    require './helpers'
    RSpec.configure do |c|
      c.include Helpers
    end

    RSpec.describe "an example group" do
      it "has access to the helper methods defined in the module" do
        expect(help).to be(:available)
      end
    end

> Extend a module in all example groups

    require './helpers'

    RSpec.configure do |c|
      c.extend Helpers
    end

    RSpec.describe "an example group" do
      puts "Help is #{help}"

      it "does not have access to the helper methods defined in the module" do
        expect { help }.to raise_error(NameError)
      end
    end

> Include a module in only some example groups

    require './helpers'

    RSpec.configure do |c|
      c.include Helpers, :foo => :bar
    end

    RSpec.describe "an example group with matching metadata", :foo => :bar do
      it "has access to the helper methods defined in the module" do
        expect(help).to be(:available)
      end
    end

    RSpec.describe "an example group without matching metadata" do
      it "does not have access to the helper methods defined in the module" do
        expect { help }.to raise_error(NameError)
      end

      it "does have access when the example has matching metadata", :foo => :bar do
        expect(help).to be(:available)
      end
    end

> 更多细节 [链接](https://www.relishapp.com/rspec/rspec-core/v/3-5/docs/helper-methods/define-helper-methods-in-a-module#include-a-module-in-all-example-groups)


#### 16.5 Global Hooks

* before(scope = :each, options={}, &block)  提交的列表末端的block代码块，在匹配提交的scope和options的example之前运行，scope可以是:each,:all,:suit,如果是:each，这个block在每个匹配的example运行前运行，运行多次，如果是:all，这个block运行一次在group里，在任何example运行之前，如果是:suite，这个block在任何example group运行前，只运行一次

* before(:example) # run before each example
* before(:context) # run one time only, before all of the examples in a group

* after(scope = :each, options={}, &block),使用方式类似before,after在example或者example group执行后再执行 

* after(:example) # run after each example
* after(:context) # run one time only, after all of the examples in a group

* around(options={}, &block),允许你包装行为环绕example通过传递example给这个block.最常见的是数据库事物

> 例子如下

    RSpec.configure do |config|
      config.around { |example| DB.transaction &example }
    end

> 每个example都被传递给block,执行这个example在一个事务里。

#### 16.6 Mock Framework

> 默认rspec使用自己的Mock框架，你可以配置rspec使用任何框架

    RSpec.configure do |c|
      c.mock_with(:rr)
    end

> mock_with方法接收一个符号或者模块引用

#### 16.7 Custom Matchers

> rspec本身提供的matcher已经可以支持我们大多数期望，我们想写我们自己的匹配器，我们应该准确的表达我们的意思，而不是差不多或者大概，对于这些情况。我们写我们自己的匹配器。

> 如果你使用过rspec-rails gem那么你已经使用了一些自定义的匹配器， render_template()，例如这个， 以一个rails-domain-specific匹配器，用来期望一个指定的模板，通过controller动作返回，如果没有这个匹配器，我们就得像下面那样写

    response.rendered_template.should == "accounts/index"

> 用这个自定义的匹配器，我们能够像下面这样使用

    response.should render_template("accounts/index")

> 所有的rspec内建的匹配器都遵循一个简单的协议，我们将会看下这个协议。

##### Matcher DSL

> 假设我们在开发一个人员管理app，我们想指定　joe.should report_to(beatrice)

> 为了达到目的，我们或许使用　joe.reports_to?(beatrice).should be_true .　这是一个好的开始，但是它有一点问题，

> １　如果期望失败，失败信息是　expected true,　got false，十分准确，但是没有帮助
> ２　另一个问题是他不可读，

> 我们实际想说　joe.should report_to(beatrice)　，如果失败，我们想要的信息是告诉我们　我们期望一个员工报告给Beatrice

> 我们可以使用rspec的matcher dls来解决可读性问题和反馈信息。

    RSpec::Matchers.define :report_to do |boss|
      match do |employee|
        employee.reports_to?(boss)
      end
    end

> 这个define方法来自rspec::Mactcher，它定义了一个 report_to方法，接收一个参数 boss，我们可以调用 report_to(beatrice) 创建一个Rspec::Matchers::Matcher实例，beatrice就是这个boss参数， 然后这个match被存储然后稍后使用，

> 在当我们说joe.should report_to(beatrice)时，创建一个RSpec::Matchers::Matcher实例，调用这个代码块使用 joｅ作为参数

> 这个 match block应该返回一个boolean 值，true表示匹配，我们使用should就会通过，使用should_not就会失败，　返回false表示不匹配，同样，我们使用should就会失败，使用should_not就会成功。

> 如果失败，就会产生一个信息，信息来自它的期望和实际值，

    expected <Employee: Joe> to report to <Employee: Beatrice>

> employee对象被打印出的信息依赖于Employee类的to_s方法的实现，但是"report to"后面的内容依赖于　matcher收集的传递给define定义的report_to方法的参数boss

> 默认生成的信息也很好，但是我们像控制自己定义错误信息，我们可以重写描述信息，　使用block和我们想要的message

    RSpec::Matchers.define :report_to do |boss|
      match do |employee|
        employee.reports_to?(boss)
      end
      failure_message_for_should do |employee|
        "expected the team run by #{boss} to include #{employee}"
      end
      failure_message_for_should_not do |employee|
        "expected the team run by #{boss} to exclude #{employee}"
      end
      description do
        "expected a member of the team run by #{boss}"
      end
    end

> 如果使用should时失败了，failure_message_for_should会被调用
> should_not失败的时后，failure_message_for_should_not会被调用当 ,
> 当matcher生成自己的信息时,description被显示 

> 使用这些已经存在的比较器可以覆盖百分之80情况，但是仍然有写情况没有照顾到，例如 不支持传递代码快给matcher自己， 如果内建的change(）匹配器需要像下面这样表达，

    account = Account.new
    lambda do
        account.deposit(Money.new(50, :USD))
    end.should change{ account.balance }.by(Money.new(50, :USD))

> 我们不能简单的定义一个matcher ，来接收一个代码块，因为ruby不允许我们传递一个代码块，同时没有将这个代码快转换为一个proc对象


##### Mather protocol

> 一个匹配器可以任何对象，他相应一些指定的信息， 简单的匹配只需要2个方法

######  matches? 
> should 和should_not 方法使用的，决定期望的信息失败还是成功，返回真表示成功，返回false表示失败，

##### failure_message_for_should
>  当shouuld和matches?都失败的时候调用这个方法

> 看下面示例

    class ReportTo
      def initialize(manager)
        @manager = manager
      end
      def matches?(employee)
        @employee = employee
        employee.reports_to?(@manager)
      end
      def failure_message_for_should
        "expected #{@employee} to report to #{@manager}"
      end
     end
    def report_to(manager)
      ReportTo.new(manager)
    end

#### 16.8 Macros

> 自定义匹配器帮主我们构建dsl。但是让然有一些重复，看下面例子

    describe Widget do
      it "requires a name" do
        widget = Widget.new
        widget.valid?
        widget.should have(1).error_on(:name)
      end
    end

> 自定义匹配器

  describe Widget do
    it "requires a name" do
      widget = Widget.new
      widget.should require_attribute(:name)
    end
  end

> 通过implicit subject 可以更简洁

    describe Widget do
      it { should require_attribute(:name) }
    end

> 现在这个简洁，表达清晰，完整，对于这种案例，我们可以做的更好，在2006年，这个shoulda库 还是一个可选的库对于rspec 来说，创新的地方在于 shoulda可以用macros来表达，我们想表达的东西， 这有一个shoulda macro替代 customer matcher例子

    class WidgetTest < Test::Unit::TestCase
      should_require_attributes :name
    end

> 在 2007年，rick olsen 引入他自己的rspec-rails扩展库，叫做 rspec_on_rails_crack, 给rspec-rails加入宏， 在 rspec_on_rails_crack中，上面的例子可以按照下面写法

    describe Widget do
        it_validates_presence_of Widget, :name
    end

> Macros像是一个很好的东西，普遍存在我们的应用程序中， 像Rails的model验证.他们有点像
> shared example group ，但是表现力更好，因为有有唯一的名字

> macros可以十分简单加入到rspec里，让我们看一个简单的example 下面代码在controller里
> 很常见

    describe ProjectsController do
      context "handling GET index" do
        it "should render the index template" do
          get :index
          controller.should render_template("index")
        end
        it "should assign @projects => Project.all" do
          Project.should_receive(:all).and_return(['this array'])
          get :index
          assigns[:projects].should == ['this array']
        end
     end
    end

>会产生下面输出

    ProjectsController handling GET index
    should render the index template
    should assign @projects => Project.all

> 使用macros灵感来自于 rspec_on_rails_on_crack 和shoulda,我们可以用更高级方式表达

    describe ProjectsController do
      get :index do
        should_render "index"
        should_assign :projects => [Project, :all]
      end
    end
  
 > 下面代码对于有经验的rubyist十分简单

    module ControllerMacros
       def should_render(template)
          it "should render the #{template} template" do
              do_request
              response.should render_template(template)
          end
       end

        def should_assign(hash)
          variable_name = hash.keys.first
          model, method = hash[variable_name]
          model_access_method = [model, method].join('.')
          it "should assign @#{variable_name} => #{model_access_method}" do
             expected = "the value returned by #{model_access_method}"
             model.should_receive(method).and_return(expected)
            do_request
            assigns[variable_name].should == expected
          end
        end
  
     def get(action)
      define_method :do_request do
         get action
      end
      yield
     end
    end

    RSpec.configure do |config|
      config.use_transactional_fixtures = true
      config.use_instantiated_fixtures = false
      config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
      config.extend(ControllerMacros, :type => :controller)
    end

> get方法定义了一个使用macros的方法叫做 do_request,调用包含另一个macro的block
> 让他们可以访问do_requiest方法

> should_assign方法看起来有点复杂，从给你提供漂亮的反馈看出来，当你编写example失败了
> 会得到下面信息

    expected: "the value returned by Project.all",
        got: nil (using ==)

> 我们暴露这个macro在控制器里，来扩展example groups，通过在configuration的最后一行
> 配置 如果你不想在所有的控制器里使用 你可以按照下面方式配置

    escribe ProjectsController do
      extend ControllerMacros

#### 16.9 Custom Formatters

> rspec使用message foramtters来生成输出信息， formaters接收事件通知。例如，一个
> example run或者一个example失败

> rspec提供了很多内建formatters用来设计生成文本输出，一个多用途的HTML formatter和一个
> TextMate-specific html formatter。

> 待续