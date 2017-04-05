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


#### 13.5 Have Whatever You Like

> 一个冰球队，应该与5个溜冰的人在冰面上，在常规条件下，character这个词有9个字母组成，然而一个Hash应该由在一个指定的key  我们能够说 Hash.has_key?(:foo).should be_true，但是我们实际上想说 Hash.should have_key(:foo)

>  Rspec结合了表达式匹配器和一点method_missing 解决了这个问题，让我们看一下 rspec使用的method_missing 假设我们有一个简单的 RequestParameters类，转换请求参数到一个Hash里，我们或许有一个像下面这样的例子

    request_parameters.has_key?(:id).should == true

> 这个表达式有道理，但是可读性不好，为了解决这个 rspec使用了 method_missing转换任何使用has_开头的对象，用have_和一个谓词， 在下面例子

    request_parameters.should have_key(:id)

> 除此之外，代码更可读，如果失败了反馈信息更可读，反馈信息看起来想这样

    expected true, got false

>have_key例子报告是这样

    expected #has_key?(:id) to return true, got false

##### Owned Collections

> 让我们写一个棒球程序，当我们的程序发送一个信息给主队的用来开始，我们想指定，发送9个选手到场地，我们怎么指定？

    field.players.select {|p| p.team == home_team }.length.should == 9
  
> 如果你是一个有经验的rubycoder 像下面这样表达

    home_team.should have(9).players_on(field)

> 这个对象通过have()返回一个matcher,不会去响应players_on(),当他收到一个信息，他不理解 players_on()
> 他委派给了目标对象也就是 home_team

> 这个表达式读起来像是一个需求，像任意断言，鼓励使用类似players_on()这样的方法

> 在任何步骤，如果目标对象或者集合不支持，期望的信息，一个有意义的错误被抛出，如果没有players_on方法在home_team上，你会得到一个noMethodError错误，如果方法的结果不支持length或者size，你会得到一样的错误，如果集合的方法结果不匹配期望的大小 你会得到一个失败的期望，而不是一个错误。

##### Unowned Collections

> 除了自己拥有集合设置期望，有时集合就是对象本身 像下面这样

    collection.should have(37).items

> 在这个例子里，items是纯粹的语法糖

##### Strings

> 字符串也是集合，他不是十分像数组，但是他会响应和集合一样的一些方法，因为字符串响应 length和size方法，你也可以期望字符串的长度

    "this string".should have(11).characters

> 在没有拥有者的集合里，charaters也是语法糖

##### Precision in Collection Expectations

> 除了表达一个集合应该有一些数量的成员的期望，你也能够指定数字，或至少或者至多

    day.should have_exactly(24).hours
    dozen_bagels.should have_at_least(12).bagels
    internet.should have_at_most(2037).killer_social_networking_apps

##### How It Works

> 这个have方法能处理一些不同的场景，通过have返回一个rspec::Matcher::Have的实例对象，使用一个使用期望元素数量初始化，
>　下面的表达式

    result.should have(3).things 

>被计算为

    result.should(Have.new(3).things)

![](2.png)

> 如上图

> 1 Have.new(3) 创建一个Have的实例对象，使用3初始化。 Have对象存储的数字作为期望的值
> 2 然后ruby解释器，发送things给Have对象，method_misssing方法被调用因为Have不能响应things方法，Have重写了method_missing方法，存储了消息的名字，这里的消息名字是things,稍后使用，返回self. 所以，have(3).things是Have的实例，并且知道集合的名字(things) ，目的是你正在寻找多少各元素在那个集合里 

>  ruby解释器传递have(3).things的结果给should()方法，接着,发送 matches?(self)给这个matcher。 这个matches？就是所有魔法发生的地方

> 1 首先，他会问目标对象(result) 是否可以响应method_missing存储的方法(things) 如果可以，发送信息，并且假设result是一个集合，询问这个result的长度或者大小 ，如果对象不能响应length或者size方法，然后你会得到一个错误信息，否则，长度或者大小，会与期望的数字作比较，数字比较一样就通过，不一样就报错

> 2 如果目标对象不能响应 这个method_missing存储的方法，Have尝试其他选择，他会问这个目标对象(result)他自己是否会响应length或者size方法，如果他能，意味着你实际对目标对象大小感兴趣，并不是对他拥有的集合感兴趣， 在这种情况，things被存储在method_missing就被忽略了，目标对象的大小被用来和期望的数字比较，

> 注意这个目标对象可以被当做任何东西只要可以响应length或者size，不仅仅是一个集合，就像我们前面说过的String 你也可以这么做 

    “this string”.should have(11).characters


> 在目标对象没有响应method_missing中存储的方法时，也没有响应length,或size时，Have对象会发送这个信息给目标对象，让结果为NoMethodError。

>和你看到的一样，这有许多魔法实现，rspec尝试掩盖所有你能出错的东西，并给你有用的信息，但是这也有一些陷阱，如果你使用一个自定义集合　length和size有着不同的意思，你或许得不到期望的结果，但是这种情况比较少见，只要你知道所有的工作方式，你就可以使用这种表达方式

#### 13.6 Operator Expressions

> 通常，我们对待表达式非常严禁，当我们说2+2等于４时，不会说2+2 大于３，但也有例外，我们写一个１－１０的随机数生成器 ，我们想确保，１　出现1000次在10000里，所以我们设置一些容错级别，百分之2，结果在类似“数为1应该大于或等于980且小于或等于1.F020。”

    it "should generate a 1 10% of the time (plus/minus 2%)" do
      result.occurrences_of(1).should be_greater_than_or_equal_to(980)
      result.occurrences_of(1).should be_less_than_or_equal_to(1020)
    end

> 当然他读取来像英语，但是有一点冗余，我们通常使用 >= 代替 be_greater_than_or_equal_to ? 

> rspec支持像下面这样

  result.should == 3
  result.should =~ /some regexp/
  result.should be < 7
  result.should be <= 7
  result.should be >= 7
  result.should be > 7

> ruby解释器会将上面解释如下
  
  result.should.==(3)
  result.should.=~(/some regexp/)
  result.should(be.<(7))
  result.should(be.<=(7))
  result.should(be.>=(7))
  result.should(be.>(7))

> 13.7 Generated Descriptions

> 我们以一个例子文档作为结尾，


  describe "A new chess board" do
    before(:each) do
      @board = Chess::Board.new
    end
    it "should have 32 pieces" do
     @board.should have(32).pieces
    end
  end

> 当我们用rspec执行命令时

    A new chess board
    should have 32 pieces

> 在这个例子里，我们可以依靠rspec的自动生成你看到的 

    describe "A new chess board" do
      before(:each) { @board = Chess::Board.new }
      specify { @board.should have(32).pieces }
    end

> 产生前面看到一样的结果

    A new chess board
      should have 32 pieces

> 这个例子中，我们使用specify()方法替代it()因为specify更可读，当没有文档的时候 it()和specify都是example()方法的别名，创建一个example

> 每个rspec的匹配器，生成一个他自己的描述，在例子通过的时候，如果example（or it or specify()）没有收到一个docstring,它使用it方法接收的最后一个doc string，在这个例子中仅有的是 "should have 32 pieces"

> 原来，这是罕见的，自动生成的名字表达你想要表达的描述性字符串的例子。我们的建议是，要开始写你到底想说的，只有诉诸使用产生的描述，当你真正看到，字符串和期望切合。

  it "should be eligible to vote at the age of 18" do
    @voter.birthdate = 18.years.ago
    @voter.should be_eligible_to_vote
  end

> 即使自动生成的描述里包含 should be eligible to vote, 事实上he is eighteen today也非常重要对于想表达的意思，另一方面考虑下面例子

    describe RSpecUser do
      before(:each) do
        @rspec_user = RSpecUser.new
      end
      it "should be happy" do
        @rspec_user.should be_happy
      end
    end

#### 13.8 Subjectivity

> 一个example中的subject就是被描述的对象,在RspecUser example中，这个subject就是 RspecUser实例 在before块中
> 初始化。
> rspec允许一个备选方案：设置一个实例变量，在before block中，像上面这样， 在 subject（）方法的形式  你也可以使用这个方法在不同的方式，

##### Explicit Subject

> 在一个 example group中， 你可以使用 subject方法定义一个 explicit subject 通过传递给他一个块

> 然后你可以使用 这个subject 

  describe Person do
    subject { Person.new(:birthdate => 19.years.ago) }
    specify { subject.should be_eligible_to_vote }
  end

##### Delegation to Subject

> 一旦subject被公开，这个例子将 should() 和should_not()委派给它

    describe Person do
      subject { Person.new(:birthdate => 19.years.ago) }
      it { should be_eligible_to_vote }
    end

> 上面代码里的should方法没有明确接受者，所以接受者就是example本身，这个example调用subject() 并且将should委派给他
> 注意上面代码中我们使用it,而不是specify(),大声的读出来，和前面的例子比较，你会发现不同

> 前面的例子读作 “Specify subject should be eligible to vote,” 这个例子读作“It should be eligible to vote.”
> 哪个更简洁？ 事实证明，在某些情况下，我们甚至可以使事情
 
##### Implicit Subject

> 在 happ RspecUser 例子中，我们创建了这个subject,在RspecUser通过调用new方法，没有使用任何参数，在这个例子中，我们忽略显示的subject声明，rspec会自动隐士的为我们声明

    describe RSpecUser do
     it { should be_happy }
    end

> 现在如此简洁，不能比这个再简洁了，subject()方法被example调用,返回了一个新的RSpecUser实例。

> 当然这只会发生在恰当的时机， 这个describe()方法 接收到一个类，并且他可以被安全的初始化，对于new方法的调用，同时并不需要参数，结果实例有一个正确的状态

> 小心：看到如此简洁的事物，孕育了一种渴望让一切都变得简洁。小心不要让保持事物简洁的目标妨碍表达你真正想要表达的内容