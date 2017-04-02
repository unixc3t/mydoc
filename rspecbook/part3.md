### Chapter 12

#### Code Examples

> 在这本书的这部分，我们详细解释rspec的内建期望，模拟对象框架，命令行工具，IDE集成，扩展点
> 我们的目标使测试驱动开发更有趣，使用生产工具的经验，提高设计和文档 这有一些常用术语

* subject code  我们使用rspec指定的行为代码
* expectation   subject code被期望的行为的表达式形式
* code example  subject code如何使用执行的例子,也是subject code被期望的行为
* example group 一组code example
* spec 文件包含很多测试代码

#####  类似结构

> 如果你已经有一些Test::Unit经验或者类似其他语言的tdd语言经验，我们使用的词对应你熟悉的词

* assertion 类似 expection
* test method方法类似 code example
* Test case 类似 example group

> 在这章节里。你将会学习怎样组织执行 code examples 以不同的方式在 example groups里，


#### 12.1 Describe It!

> rspec提供了DSL用来描述指定对象的行为。它包含了描述行为的比喻，如果我们和某个客户或某个开发者交谈，我们可以表达它的方式。

* You: 描述一个新的账户

* SomeBody else : 它应该有0美元

> 将这些使用rspec描述

    describe "A new Account" do
      it "should have a balance of 0" do
        account = Account.new
        account.balance.should == Money.new(0, :USD)
      end
    end

> 我们使用describe()定义一个example group,我们传递给它的字符串表示系统层面，我们描述它（一个新账户），代码块里存放代码例子组成group

> it定义一个 code example 字符串传递it表示我们感兴趣的指定的行为，（It should have a balance of zero.）代码块存放了example 代码，执行主题代码，和设置期望

> 使用字符串替代传统ruby类名和方法名更灵活，这又一个我们自己的例子

  it "matches when actual < (expected + delta)" do
    be_close(5.0, 0.5).matches?(5.49).should be_true
  end

> 这是一个代码的例子，某个目标观众能够读懂这个代码。 使用Test::Unit我们或许命名
> test_matches_when_value_is_less_than_target_plus_delta ,哪个更可读？ 绝对是使用字符串描述
> 让我们更详细的看describe ()和it方法

##### The describe Method
> 这个describe()方法使用任意参数的数量和一个可选的代码块，返回一个rspec::Core::ExampleGroup子类
> 我们通常使用1个或者2个参数，表述我们想描述的行为,描述一个对象或者一个状态，或者一组行为，让我们看一下例子

    describe "A User" { ... }
    => A User

    describe User { ... }
    => User

    describe User, "with no roles assigned" { ... }
    => User with no roles assigned

    describe User, "should require password length between 5 and 40" { ... }
    => User should require password length between 5 and 40

> 第一个参数可以引用一个类，或者一个模块，或者一个字符串
> 第二个参数是可以选的，并且应该是一个字符串
> 使用类或者模块作为第一个参数提供一个有利的地方
> 当我们包装一个exampleGroup在一个模块里的时候，我们会看到模块的名字在输出信息里
> 像这样包裹User,在Authentication模块里

    module Authentication
      describe User, "with no roles assigned" do

> 报告结果里
 Authentication::User  with no roles assigned
	       模块名 :: 类名  第二个参数

> 通过包裹一个ExampleGroup在一个模块里，我们可以看到完整的限定名: Authenticatin::User 紧跟着是后面> 的第二个参数。他们被格式化输出，我们轻松的到了完整名称，这是个很好的方式，让我们理解看到的输出

> 你也可以内嵌example groups，这是一个非常好的输出格式，然后输出结果
    describe User do
      describe "with no roles assigned" do
        it "is not allowed to view protected content" do

> 产生输出
		User
			with no roles assigned
					is not allowed to view protected content

##### The context Method

> 这个context方法是describe()方法的别名，他们可以交换使用，我们使用describe描述事物，context描述上下文。

>这个User例子，可以这样写
	
    describe User do
      context "with no roles assigned" do
        it "is not allowed to view protected content" do

> 这个输出结果和describe()一样。但是context()使得扫描一个spec file文件更容易 理解起来也更容易

##### whatis it all about?

> 类似describe()方法， it()方法需要一个字符串参数，一个可选的Hash参数，和一个可选的代码块，这个字符串应该是一个句子，使用前缀it，这个句子表达的意思就是代码块里的代码，下面有一个例子

    describe Stack do
      before(:each) do
        @stack = Stack.new
        @stack.push :item
      end
        describe "#peek" do
          it "should return the top element" do
            @stack.peek.should == :item
          end
          it "should not remove the top element" do
            @stack.peek
            @stack.size.should == 1
          end
        end
      describe "#pop" do
        it "should return the top element" do
         @stack.pop.should == :item
        end
        it "should remove the top element" do
          @stack.pop
          @stack.size.should == 0
        end
      end
    end

> 这也展示了rspec嵌套例子特性pop()和peek()方法例子

> 运行使用参数 --format documenttation ，格式化代码输出

    Stack
      #peek
        should return the top element
        should not remove the top element
      #pop
        should return the top element
        should remove the top element

Finished in 0.00154 seconds
4 examples, 0 failures

> 看起来像说明书不是么？ 事实上。如果我们移除例子中的关键字should，不使用should，，像下面这样，、
    Stack
      #peek
        return the top element
        not remove the top element
      #pop
        return the top element
        remove the top element

Finished in 0.00154 seconds
4 examples, 0 failures

> 什么，没有should？ 记住，我们的目的是读懂句子。Should关键字是一个工具

> 传递文本给it方法，允许我们更好的命名和组织example,以更有意义的方式，如describ()情况那样，
> 字符串甚至可以包含标点符号，这对于我们理解代码意图更有帮助

####  12.2 Pending Examples

> 在Test Driven Development开发中，Kent Beck建议先编写一组没有实现的测试，然后你继续工作，当你通过测试时，将清单中的通过测试划掉，然后在列表中添加新的测试

> 使用rspec,你能编写正确的代码，通过调用It方法不使用代码块。 我们看下面的代码行为

    describe Newspaper do
      it "should be black" do
        Newspaper.new.colors.should include('black')
      end
      it "should be white" do
        Newspaper.new.colors.should include('white')
      end
      it "should be read all over"
    end

> rspec认为没有代码块的example是pending

    Newspaper
      should be black
      should be white
      should be read all over (PENDING: Not Yet Implemented)
    Pending:
      Newspaper should be read all over
      # Not Yet Implemented
      # ./newspaper_spec.rb:17

    Finished in 0.00191 seconds
    3 examples, 0 failures, 1 pendin

> 作为你加入的pending例子，和加入新的，每次运行你所有的例子，rspec就会提醒多少pending例子，
> 另一个例子，就是当你标记一个pending的例子，是你正在开发的对象，你有一些例子要通过，加入一个失败例子，你> 看这个代码

> 有许多不同的办法，一种就是注释掉失败的例子，然后重构他们把变绿色，未注释的例子继续，替代注释，可以像下面> 这样

      describe "onion rings" do
        it "should not be mixed with french fries" do
          pending "cleaning out the fryer"
          fryer_with(:onion_rings).should_not include(:french_fry)
        end
      end

> 在这个例子中，即使例子的代码块被执行了，如果执行到pending就会停止执行，后面的代码不会执行。
> 就不会报错，这个例子会被加入到Pending列表，待在你能看到的地方，让你重构完代码，移除pending声明，这个> 例子就正常了， 比注释清晰 不会丢失细节


> 第三种pending方法十分有用，在处理bug上，让我们得到一个Bug报告，然后报考提供足够失败信息。或者你创建一个失败例子，你想处理这个Bug但是没有时间，可以这样做，使用Pending方法 ，

    describe "an empty array" do
      it "should be empty" do
        pending("bug report 18976") do
          [].should be_empty
        end
      end
    end

> 将代码作为代码块传递给pending方法，当运行rspec时，遇到代码快，他会执行代码快，如果代码块失败，或者抛出一个错误，rspec处理方式与其他Pending例子一样,如果rspec执行没有错误，则会抛出一个错误， 让你知道有一个例子pending了，但是没有原因

    F

    Failures:
      1) an empty array should be empty FIXED
        Expected pending 'bug report 18976' to fail. No Error was raised.
        # ./pending_fixed.rb:4

    Finished in 0.00088 seconds
    1 example, 1 failu

> 所以三种情况使用pending

* 在你正在编写的example，还没写完的example例子中加入

* 失败的例子

* 包装失败的当你注意到改变系统引起的失败

#### 12.3 Hooks: Before, After, and Around

> 如果我们在开发一个栈，我们像描述一个栈什么时候是空的，什么时候是满的，我们想描述如何Push pop peek在什么条件下执行

> 如果三个方法乘以四个状态，我们将要写12个描述不同的scenarios。我们想group 状态或者method， 现在我们谈论初始状态 before hook


##### before(:each)

> 为了组织 examples的初始状态，或者cotext,rspec提供了一个before()方法, before(:all)表示在一个
> example组之前运行，before(:each)表示在每一个example之前运行。
>通常情况下它使用在before(:each)，它会重新创建一个上下文，在每个例子执行之前，保证状态变化不会涉及到其他例子

    describe Stack do
      context "when empty" do
        before(:each) do
        @stack = Stack.new
      end
    end

    context "when almost empty (with one element)" do
      before(:each) do
        @stack = Stack.new
        @stack.push 1
      end
    end
    context "when almost full (with one element less than capacity)" do
      before(:each) do
        @stack = Stack.new
        (1..9).each { |n| @stack.push n }
      end
    end
    context "when full" do
      before(:each) do
          @stack = Stack.new
          (1..10).each { |n| @stack.push n }
      end
      end
    end

> 我们加入examples到这些examples group里，被传递给before(:each)代码块的代码，在任何一个组里的example运行前运行，组里的例子有着一样的初始化状态，

     context "when almost full (with one element less than capacity)" do
      before(:each) do
        p "before"
      end

      it "one" do
        p "one"
      end
      it "two" do
        p "two"
      end
      it "three" do
        p "three"
      end
    end

> 结果

  "before"
  "one"
  "before"
  "two"
  "before"
  "three"

##### before(:all)

> 除了before(:each)之外。我们还说了Before(:all).这个只运行一次，仅仅一次，在它的对象实例上。但是它的变量被拷贝到每个例子组的地方，小心使用： 我们想让每个例子有完整的独立环境区别与其他例子， 一旦我们
> 分享状态，未知行为可以发生

> 考虑刚才的stack例子，这个pop方法移除栈顶元素，意味着第二个例子使用一样的栈实例开始比before(:all)的栈少一个元素，当例子失败了，找出问题变得更有挑战

> 看上去分析状态不会有任何问题，即使是一直改变  ，通过共享状态创建的问题是众所周知的难以找到。

> 所以before(:all)适合什么情况？ 例如。打开一个网络链接 通常，一般来说，这是我们不可能在孤立的例子，RSpec是真正针对。如果我们使用RSpec驱动更高级别的例子，然而，这可能是一个很好的例子


##### after(:each)

> 每个例子执行后，before(:each)的相对应方法是after(:each)，这个方法不一定是必要的，因为每个例子运行在他自己的作用域，

这有一个例子 ，有时候,after(:each)很有用，如果你处理一个系统，管理全局变量状态，每次用来还原

    before(:each) do
        @original_global_value = $some_global_value
        $some_global_value = temporary_value
     end
    after(:each) do
      $some_global_value = @original_global_value
    end

##### after(:all)
> 我们可以定义一些代码给after(:all)执行在一个例子组里执行，这个使用比after(:each)更少见。但是这也有一些使用场景，例如关闭浏览器，例如关闭数据库，关闭socket确保资源回收

##### around(:each)

> rspec提供了一个around(each)方法，它需要一个代码快，多数情况用在数据库事务。

    around do |example|
       DB.transaction { example.run }
    end

> rspec传递当前运行的example给block，然后调用example的run方法，你也能将example变成代码快传递给进去

    around do |example|
      DB.transaction &example
    end

    RSpec.describe "around hook" do
      around(:example) do |example|
        puts "around example before"
        example.run
        puts "around example after"
      end

      it "gets run in order" do
        puts "in the example"
      end
    end

> 这个结构的另一个陷阱用来清除错误或者清理 在前面的例子这个transaction()方法做这个，考虑下面

    around do |example|
      do_some_stuff_before
      example.run
      do_some_stuff_after
    end

> 如果上面的例子抛出错误 do_some_stuff_after 就不会执行，环境没有被正确的还原，所以我们应该这样做

    around do |example|
      begin
        do_some_stuff_before
          example.run
        ensure
          do_some_stuff_after
      end
    end

> 但是上面的可读性就减弱了，我们使用before 和after

    before { do_some_stuff_before }
    after { do_some_stuff_after }

> after hooks确保即使有错误也会运行，所以是我们不用麻烦在around中处理错误，也使得代码更可读

> 这些方法非常有用在帮我解决重复代码上，不仅仅是移除重复，改良结构，使得代码更清晰，　有时候我们想分享一些东西扩大作用域

#### 12.4 Helper Methods

> 另一个方法清理我们的例子就是helper methods，我们定义正确的例子组，然后在例子组里被所有例子访问，
> 假设我们已经在一个例子组里有几个例子，每个例子我们都需要执行一些一样的操作，看下面例子

    describe Thing do
    it "should do something when ok" do
      thing = Thing.new
      thing.set_status('ok')
      thing.do_fancy_stuff(1, true, :move => 'left', :obstacles => nil)
    end
    it "should do something else when not so good" do
      thing = Thing.new
      thing.set_status('not so good')
      thing.do_fancy_stuff(1, true, :move => 'left', :obstacles => nil)
    end
  end

> 这两个例子里，我们都需要创建一个Thing和分配给他一个状态。这个可以提取出放到一个helper方法

     describe Thing do
        def create_thing(options)
          thing = Thing.new
          thing.set_status(options[:status])
          thing
        end

        it "should do something when ok" do
          thing = create_thing(:status => 'ok')
          thing.do_fancy_stuff(1, true, :move => 'left', :obstacles => nil)
        end

        it "should do something else when not so good" do
          thing = create_thing(:status => 'not so good')
          thing.do_fancy_stuff(1, true, :move => 'left', :obstacles => nil)
        end
      end

> 另一个清理方法的方式是 在你的类的初始化方法里执行 yield self ，可以将前面例子写成下面例子样子

    class Thing
      def initialize
          yield self
      end

      def set_status(options)
        @options=options
      end

      def p_status
        p @options
      end
    end


    def given_thing_with(options)
      yield Thing.new { |thing|
        thing.set_status(options[:status])
      }
      #yield a
    end

    given_thing_with(:status => 'ok') do |x|
      x.p_status
    end

    -----

    describe Thing do
      def given_thing_with(options)
        yield Thing.new { |thing|
          thing.set_status(options[:status]) }
        end
      end
      it "should do something when ok" do
        given_thing_with(:status => 'ok') do |thing|
          thing.do_fancy_stuff(1, true, :move => 'left', :obstacles => nil)
        end
      end
      it "should do something else when not so good" do
        given_thing_with(:status => 'not so good') do |thing|
          thing.do_fancy_stuff(1, true, :move => 'left', :obstacles => nil)
        end
      end
    end

> 这种修改属于个人喜好，但是你能看到清晰了不少。每个例子上减少了很多噪音。但是也带来了不利的地方，就是每个例子必须看其他的地方才能理解 given_thing_with方法，当这种方法使用过度也会造成理解困扰。

> 一个好的方式就是保证代码的结构都一样，你的系统里的代码看起来都一样，即使你的新同时不熟悉这样的代码，也会快速的学习和适应，如果仅有一个example这样，那就更令人混乱

##### sharing helper methods

> 如果我们有helper method想在example groups里分享，我们将他定义在一个或者多个模块里，然后include他，

    module UserExampleHelpers
      def create_valid_user
        User.new(:email => 'email@example.com', :password => 'shhhhh')
      end

      def create_invalid_user
          User.new(:password => 'shhhhh')
      end
    end
    describe User do
      include UserExampleHelpers
      it "does something when it is valid" do
         user = create_valid_user
         # do stuff
      end
      it "does something when it is not valid" do
          user = create_invalid_user
          # do stuff
      end
    end

> 如果我们有一个帮助方法要在所有例子里使用我们可以将他配置在配置文件里

  RSpec.configure do |config|
      config.include(UserExampleHelpers)
  end


#### 12.5 Shared Examples

> 当我们期望，多个类的实例以同样的方式时，我们可以使用一个shared example group 去描述他，然后include那个example group在其他exampel 
> group里，我们声明一个shared example group 使用 shared_examples-for()方法

    shared_examples_for "any pizza" do
      it "tastes really good" do
        @pizza.should taste_really_good
      end
      it "is available by the slice" do
        @pizza.should be_available_by_the_slice
      end
    end

> 当我们声明了一个shared example group例子，我们可以include 他，然后使用it_behaves_like()方法

    describe "New York style thin crust pizza" do
      before(:each) do
        @pizza = Pizza.new(:region => 'New York', :style => 'thin crust')
      end
      it_behaves_like "any pizza"
      it "has a really great sauce" do
        @pizza.should have_a_really_great_sauce
      end
    end
    describe "Chicago style stuffed pizza" do`
      before(:each) do
        @pizza = Pizza.new(:region => 'Chicago', :style => 'stuffed')
      end
      it_behaves_like "any pizza"
      it "has a ton of cheese" do
        @pizza.should have_a_ton_of_cheese
      end
    end

> 输出结果

    New York style thin crust pizza
    has a really great sauce
    behaves like any pizza
    tastes really good
    is available by the slice
    Chicago style stuffed pizza
    has a ton of cheese
    behaves like any pizza
    tastes really good
    is available by the slice

> 这个it_behaves_like ( )方法生成一个嵌套的例子组，名字是beahves like后面的第一个参数，例如 “beahves like any pizza.” 这个传递给shared_examples_for（）的 block然后在那个组的上下文执行，所以任何方法例子，before hooks等等，定义在block里都会被加入到组里

> 像其他嵌套组，通过it_behaves_like()继承的方法和 钩子方法定义在外面 在这个例子中，我们得到before hooks 定义在每个group里


#### 12.6 Nested Example Groups

> 嵌套例子是一个很好的方式用来组织例子，下面是一个例子

    describe "outer" do
      describe "inner" do
      end
    end

> 和我们早期看到的一样，outer group是 ExampleGroup的子类，在这个例子里，inner group 是outer group的子类。这意味着任何 helper method,或者before和after 声明，include mould.等等 都适用与inner group

> 如果都在inner和outter里声明 before和after blocks  他们按照下面执行

    1. Outer before
    2. Inner before
    3. Example
    4. Inner after
    5. Outer after

> 验证这个，看下面例子

    describe "outer" do
      before(:each) { puts "first" }
      describe "inner" do
        before(:each) { puts "second" }
        it { puts "third"}
        after(:each) { puts "fourth" }
      end
      after(:each) { puts "fifth" }
    end

> 运行这个rspec。结果如下面

    first
    second
    third
    fourth
    fifth


> 因为他们都运行在同样对象的上下文。我们可以分享状态 在before blocks 和 example之间,这允许我们我们做先前设置
> 比如，我们在outer group 里设置约定，然后事件发生在inner group里，在自己的例子里设置期望，我们可以像下面这样

      describe Stack do
        before(:each) do
          @stack = Stack.new(:capacity => 10)
        end

        describe "when full" do
          before(:each) do
            (1..10).each {|n| @stack.push n}
          end
          describe "when it receives push" do
            it "should raise an error" do
              lambda { @stack.push 11 }.should raise_error(StackOverflowError)
            end
          end
        end

        describe "when almost full (one less than capacity)"
          before(:each) do
            (1..9).each {|n| @stack.push n}
          end
            describe "when it receives push" do
                it "should be full" do
                  @stack.push 10
                  @stack.should be_full
                end
            end
        end
      end

> 此时，你可能认为，这是dry,或者说，这如此复杂，从某种程度说你说的对，他是DRY，并且复杂，可以按照下面方式重构

    describe Stack do
      describe "when full" do
          before(:each) do
            @stack = Stack.new(:capacity => 10)
            (1..10).each {|n| @stack.push n}
          end
          describe "when it receives push" do
              it "should raise an error" do
                lambda { @stack.push 11 }.should raise_error(StackOverflowError)
              end
          end
      end
        describe "when almost full (one less than capacity)"
          before(:each) do
            @stack = Stack.new(:capacity => 10)
            (1..9).each {|n| @stack.push n}
          end
        describe "when it receives push" do
            it "should be full" do
              @stack.push 10
              @stack.should be_full
            end
        end
      end
    end

> 或者按照下面方式

      describe Stack do
        describe "when full" do
          describe "when it receives push" do
            it "should raise an error" do
              stack = Stack.new(:capacity => 10)
              (1..10).each {|n| stack.push n}
              lambda { stack.push 11 }.should raise_error(StackOverflowError)
            end
          end
        end
        describe "when almost full (one less than capacity)"
          describe "when it receives push" do
            it "should be full" do
              stack = Stack.new(:capacity => 10)
              (1..9).each {|n| stack.push n}
              stack.push 10
              stack.should be_full
            end
        end
      end
    end