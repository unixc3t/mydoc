## RSpec::Expectations

> bdd的目标之一就是，得到正确的用语，我们想通过语言，实践和程序来支持团队成员交流理解,不管成员是否理> 解技术细节，这也是我们为什么使用 Given,when和then

> 我们也谈论期望，而不是断言,字典定义了动词“断言”意思是，“以自信而有力地陈述事实或信念”这是我们在法庭上做的事情。

> 在可执行的code example里面，我们设置期望表示应该发生而不是将会发生什么，事实上，在rspec的expectation framework,我们使用词汇should 是正确的
> 例如我们期望一个计算结果是5 我们在rspec中这样写  
  
    result.should equal(5)

> 这有一个rspec的例子，一个声明,表达一个特指的点在执行代码的例子中，某些事物处于某种状态，这有一些其他的例子

    message.should match(/on Sunday/)
    team.should have(11).players
    lambda { do_something_risky }.should raise_error(
     RuntimeError, "sometimes risks pay off ... but not this time"
    )

#### 13.1 should, should_not, and matchers

> rspec实现了更高级的表达方式和更好的可读性，通过ruby的打开类技术，加入了should和should_not方法到每个对象中,每个方法接收一个matcher或者一个ruby表达式，使用ruby操作符的子集，一个matcher是一个对象，用来尝试匹配期望结果

> 看下面使用equal matcher的例子，你可以通过方法equal(expected)

    result.should equal(5)

> 当ruby解释器遇到这一行，他开始计算equla(5), 这是一个rspec的方法，返回一个计算是否与5相等的 matcher对象，这个matcher对象当成参数传递给result.should。

> 在实现背后,这个should方法调用matcher对象的matches?(matcher.matches?)，传递self(the result object）作为参数，就是将result.should的result传递给matcher.matches? 因为should被加入到每个对象，可以是任何对象，类似， 这个matcher能够作为任何对象只要可以响应matches?(object)

> should_not()工作方式相反，如果matches?(self)返回false，然后期望的记过被看到，然后继续执行其他例子，如果返回true，然后抛出ExpectationNotMetError和错误信息，通过matcher.failure_message_for_should_not返回

> 注意should()调用 matcher.failure_message_for_should,而,should_not使用matcher.failure_message-for_should_for，

> should和should_not方法，也可以使用任何操作符，==和=~

####  13.2 Built-in Matchers

> rspec 分享了一些内建的匹配器，使用方便的名字，你可以在你的例子中使用，例如 equal(expected) 其他的 如下面

    include(item)
    respond_to(message)
    raise_error(type)

> 他们似乎有点奇怪，但在上下文里，感觉也不错：

     prime_numbers.should_not include(8)
     list.should respond_to(:length)
     lambda { Object.new.explode! }.should raise_error(NameError)

>  我们将会讲解每个rspec的matchers，


##### Equality: Object Equivalence and Object Identity

> 即使我们关注的是行为,我们设置的许多期望也是关于事件发生后的系统环境的状态，最常见的处理事件发生的是

* 1 指定一个对象含有我们期望的值（object equivalence）
* 2 一个对象和我们希望的对象是同一对象(object identity)

> 大多数 xUnit框架支持assert_equal,意思是两个对象的equivalent(值相等)，使用assert_same判断两个对象是同一对象（object identity），这个来自java这种语言，在java语言中，==操作符，意味着两个引用指向同一个对象，equals方法表示 equivalence

> 注意你不得不建立一个心里映射， 对于assertEqual和assertSame，在java中 assertEqual意味着equal,assertSame意味着==。 这没什么关系，在java语言中仅有这两种判断结构，但是 在ruby中，我们有4种处理相等

    a == b
    a === b
    a.eql?(b)
    a.equal?(b)

> 在不同的上下文中，这些有不同的语义，令人混乱 相比让你强制记住这些不同，rspect 让你表达确切的方法 

  a.should == b
  a.should === b
  a.should eql(b)
  a.should equal(b)

> 最常用的是 should== 因为主要表示 值相等,不用来判断是不是同一对象， 这有一些例子

    (3 * 5).should == 15
    person = Person.new(:given_name => "Yukihiro", :family_name => "Matsumoto")
    person.full_name.should == "Yukihiro Matsumoto"
    person.nickname.should == "Matz"

> 在这些例子中我们感兴趣的是值，但是有时,我们也像指定一个对象是我们希望的对象

    person = Person.create!(:name => "David")
    Person.find_by_name("David").should equal(person)

> 通过find_by_name在返回值有一个严格的约束,通过create!()创建的对象，必须被返回(返回我们创建的那个对象)
> 虽然在预期某种缓存行为时可能适用，约束越紧，期望越脆弱 ，如果缓存里不是真正的需求，Person.find_by_name("David").should == person 已经足够好，当重构的时候,意味着例子不太可能失败


##### Do Not Use !=

> 虽然rspec支持下面用法

  actual.should == expected

> 但是不支持下面

  actual.should != expected

> 你应该使用
  
  actual.should_not == expected

> 原因是 ==在ruby中是一个方法，类似 to_s(), Push() 这种形式 actual.should == expected， 被解释为actual.should.==(expected) , 对于actual.should != expected　被解释为!(actual.should.==(expected))　，这意味着，通过should()返回的对象，都被当成接收==方法消息，不论这个例子使用 ==还是!=，并且对每个例子都进行短的文本分析会非常慢，rspec不知道例子中!=的真是意思， 所以远离!=


##### Floating-Point Calculations

> 浮点数计算结果的期望设置，可能有一点痛苦，例如失败信息"期望5.25，得到5.251",
> 为了解决这个问题，rspec提供了一个 be_close匹配，允许一个期望值和一个允许的增量，在你寻找两个小数点的地方可以按照下面

    result.should be_close(5.25, 0.005)

> 如果给定的值不超过5.255,就会通过测试

##### Multiline Text

> 假设开发一个对象，用来生成一个表达式，你有一个复杂的例子，比较整个生成的表达式和一个期望的表达式，像下面这样

    expected = File.open('expected_statement.txt','r') do |f|
          f.read
    end
    account.statement.should == expected

> 这种读取文件的方式已经被认可,这是一个很好的例子，但是当我们想更细粒度，就很困难
> 有时我们并不是关心整个字符串，而是关心其中的子串， 有时我们关心格式而不是细节，有时我们关心细节不是格式。
> 我们期望匹配一个正则表达式,可以按照下面方式

    result.should match(/this expression/)
    result.should =~ /this expression/

> 如果是一个语句。我们可以像下面这样

    statement.should =~ /Total Due: \$37\.42/m


##### Ch, ch, ch, ch, changes

> ruby on rails 扩展了 Test::Unit 使用了一些Rails-specific assertions.
> 例如这个断言 assert_difference(),通常用于添加数据到数据库表的表达式，例如

    assert_difference 'User.admins.count', 1 do
      User.create!(:role => "admin")
    end

> 代码意思是 User.admins.count 的值将会增加1，当执行代码块的时候，在努力保持rails的平等性时，rspec提供了另一种方案，

    expect {
       User.create!(:role => "admin")
    }.

> 你也可以做更清晰的表达，通过by to from()

    expect {
      User.create!(:role => "admin")
    }.to change{ User.admins.count }.by(1)

    expect {
      User.create!(:role => "admin")
    }.to change{ User.admins.count }.to(1)

    expect {
      User.create!(:role => "admin")
    }.to change{ User.admins.count }.from(0).to(1)

> 可以用在任何地方， 

    expect {
      seller.accept Offer.new(250_000)
    }.to change{agent.commission}.by(7_50
  
> 你可以通过希望开始值，结束值来表达

    agent.commission.should == 0
    seller.accept Offer.new(250_000)
    agent.commission.should == 7_500

##### Expecting Errors

> 当首次学习ruby时，你或许感觉 这个语言正在读取你的想法， 假设你需要一个方法通过keys迭代ruby的hash结构 所以你输入 hash.each_pair {|k,v| puts k}，
> 我们也应该提供有意义的反馈信息，我们想提供错误类和信息，帮主开发是快速知道哪里错了类似下面代码

    $ irb
    irb(main):001:0> 1/0
    ZeroDivisionError: divided by 0
    from (irb):1:in `/'
    from (irb):1

> 真相是这个错误被叫道ZeroDivisinError，告诉你你需要知道的每样东西，来确定哪里错了。rspec支持开发的错误类或者错误信息使用raise_error匹配


    account = Account.new 50, :dollars
    expect {
        account.withdraw 75, :dollars
    }.to raise_error(
       InsufficientFundsError,
       /attempted to withdraw 75 dollars from an account with 50 dollars/
    )

> raise_error() 匹配器，将接受0个，1个 或者2个参数，如果觉得是一般错误，可以不传递参数，
> 下面例子只要抛出Exception的子类就会通过测试

  expect { do_something_risky }.to raise_error

> 第一个参数可以是字符串信息，或者一个正则表达式，他们应该匹配一个真实信息，或者是期望的错误类

> 字符串
    expect {
       account.withdraw 75, :dollars
    }.to raise_error(
       "attempted to withdraw 75 dollars from an account with 50 dollars"
    )

> 正则表达式

    expect {
      account.withdraw 75, :dollars
    }.to raise_error(/attempted to withdraw 75 dollars/)

> 错误类

    expect {
      account.withdraw 75, :dollars
    }.to raise_error(InsufficientFundsError)

当第一个参数是一个错误类时，紧跟着的第二个参数，可以是一个字符串或者一个正则表达式匹配实际信息

    expect {
       account.withdraw 75, :dollars
    }.to raise_error(
      InsufficientFundsError,
      "attempted to withdraw 75 dollars from an account with 50 dollars"
    )
    expect {
      account.withdraw 75, :dollars
    }.to raise_error(
      InsufficientFundsError,
      /attempted to withdraw 75 dollars/
    )

> 这些格式的选择，依赖于怎样指定你想得到的类型和信息

##### Expecting a Throw

> 像raise()和rescue()，ruby的throw()和catch()允许我们停止执行给定的区域，基于某些条件，主要的不同是我们使用throw /catch表达期望的信息，而不是意外的信息

> 例如。我们写一个注册学校课程信息的程序，我们希望处理两个学生同时想注册最后一个座位问题，两个人看到屏幕位子仍然是空着的，但是他们中只有一个人能得到最后的位子，另一个人被关在外面，我们能够使用railse 一个 courseFullExceptin来处理，但是课程预定满不意味着是异常，而是一种不同的状态，我们可以询问Course是否还有位置，除非查询数据库，这时就使用throw

    course = Course.new(:seats => 20)
    20.times { course.register Student.new }
    lambda {
      course.register Student.new
    }.should throw_symbol(:course_full)

> 像raise-error()一样，throw_symbol()也接收0个 1个，2个参数， 如果你想让事情保持通用，可以传递0个参数，thrown任何东西都通过，传递给thrown_symbol的第一个参数(可选)必须是符号。第二个参数，也是可选的，可以是任何东西，

    course = Course.new(:seats => 20)
      20.times { course.register Student.new }
    lambda {
      course.register Student.new
    }.should throw_symbol(:course_full, 20)

#### 13.3 Predicate Matchers

> 一个ruby的断言方法是一个名字结尾加上问号？，返回一个boolean，像下面这样

    do_something_with(array) unless array.empty?

> 当我们想设置一个期望的时候，一个断言应该返回一个指定的结果 然而下面的代码不是十分优雅

    array.empty?.should == true

> 即使我们表达了真实意图，它的可读性也不是很好。看下面代码

    array.should be_empty

> 相信他或者不相信，工作和你的期望一样，期望是被看到的,如果数组是空的，返回真，代码通过。
> 如果数组没有响应empty?方法，会得到一个noMethodError,如果响应了empty?
> 返回false,然后得到一个 ExpectationNotMetError。

> 这个特性适合任何ruby断言，这个也允许参数，例如下面

  user.should be_in_role("admin")

> 这个和下面一样

  user.in_role?("admin") returns true .

##### How they work

> rspec 重写了 method_missing方法 提供了一点点的语法糖，如果没有类似 be_开头的方法，rspec剥离be_和？，然后发送结果信息给对象

> 进一步讨论这个特性，有一些断言。或许不能像我们喜欢那样流利阅读，当前缀使用be.
> instance_of?(type) 变成 be_instance_of .为了更可读，raspe找到了一些前缀例如 be_a_” and “be_an_”. 所以我们写成 be_a_kind_of(Player) or be_an_instance_of(Pitcher) .

#### 13.4 Be True in the Eyes of Ruby

> 在ruby中，有两个值被计算成false在表达式中，他们一个当然是false,另一个是nil其他的值被计算成true，甚至是0也是 true

    puts "0 evals to true" if 0

> rspec的be_true和be_false 两种匹配器被用作指定的方法，ruby计算后返回true或者false的方法 

    true.should be_true
    0.should be_true
    "this".should be_true
    false.should be_false
    nil.should be_false

> 罕见的案例，例如我们关心方法返回值是true还是false，我们可以使用equal匹配器

    true.should equal(true)
    false.should equal(false)

