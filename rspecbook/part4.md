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