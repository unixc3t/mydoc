#### Defining factories

> 每个factory 有一个名字和一组属性，这个名字用来推测对象所属的默认类，但是也可以明确指定是哪个类:

    # 下面方式推测是User类
    FactoryGirl.define do
      factory :user do
        first_name "John"
        last_name  "Doe"
        admin false
      end

      # 通过设置class: User，告诉是User类
      factory :admin, class: User do
        first_name "Admin"
        last_name  "User"
        admin      true
      end
    end

> 强烈推荐一个factory对应一个类，并且同事提供简单必要的属性，当创建类实例的时候。如果你创建
> 一个ActiveRecord对象，意味着你仅仅需要提供通过验证的属性，其他的factories通过继承来实现常见的情况

> 尝试多个factories使用一个名字将会报错

> factories可以被定义在任何地方，如果按照下面位置定义，将会在自动加载后，调用FactorGirl.find_definitions

    test/factories.rb
    spec/factories.rb
    test/factories/*.rb
    spec/factories/*.rb

#### Using factories

> factory_girl支持多种不同的构建策略: build ,create,attributes_for和build_stubbed:

    # 返回一个没有保存的实例
    user = build(:user)

    # 返回一个保存的实例
    user = create(:user)

    # 返回一组hash结构的用来构建user实例的属性
    attrs = attributes_for(:user)

    # 返回一个拥有所有属性的对象
    stub = build_stubbed(:user)

    # 创建一个代码块然后传递给上面任何一个方法，应用到创建实例上
    create(:user) do |user|
      user.posts.create(attributes_for(:post))
    end

> 无论那种构建策略，都可以传递属性值覆盖默认的

    # 构建user实例，覆盖frist_name名字
    user = build(:user, first_name: "Joe")
    user.first_name
    # => "Joe"

#### Dynamic Attributes

> 大多数factory属性是使用静态值，当factory定义的时候设置，但是有一些属性，例如关联关系和其他属性必须动态设定，在一个对象实例
> 生成的时候。 动态意思是，属性可以通过代码块传递代替参数

    factory :user do
      # ...
      activation_code { User.generate_activation_code }
      date_of_birth   { 21.years.ago }
    end

> 定义属性作为hash需要两个大括号

    factory :program do
      configuration { { auto_resolve: false, auto_define: true } }
    end

#### Aliases

> factory_girl允许你对已存在的factories定义别名，这样方便他们更容易复用，这可能派上用场,例如,你的post对象，它有一个author属性
> 实际上引用了一个User类实例,正常情况 factory_girl推测出 factory的名字通过 association的属性值，这时factory寻找author类就无效
> 所以，别名你的user factory可以解决这个问题 

    factory :user, aliases: [:author, :commenter] do
      first_name    "John"
      last_name     "Doe"
      date_of_birth { 18.years.ago }
    end

    factory :post do
      author
      # 替代
      # association :author, factory: :user
      title "How to read a book effectively"
      body  "There are five steps involved."
    end

    factory :comment do
      commenter
      # 替代
      # association :commenter, factory: :user
      body "Great article!"
    end


#### Dependent Attributes

> 属性的值可以基于其他属性，使用yield动态属性快

    factory :user do
      first_name "Joe"
      last_name  "Blow"
      email { "#{first_name}.#{last_name}@example.com".downcase }
    end

    create(:user, last_name: "Doe").email
    # => "joe.doe@example.com"


#### Transient Attributes

> 有时为了做到dryed通过传递临时属性给factories

    factory :user do
      transient do
        rockstar true
        upcased  false
      end

      name  { "John Doe#{" - Rockstar" if rockstar}" }
      email { "#{name.downcase}@example.com" }

      after(:create) do |user, evaluator|
        user.name.upcase! if evaluator.upcased
      end
    end

    create(:user, upcased: true).name
    #=> "JOHN DOE - ROCKSTAR"

> 静态和动态属性都可以作为临时属性， 临时属性在使用attributes_for被忽略，也不会被设置到模型上，
> 即便是属性存在，或者你去覆盖他们

> 使用factory_girl的动态属性，你能够传递你期望的临时属性，你需要在factory_girl回调函数里调用evaluator，
> 你需要声明第二个块参数(为了evaluator)，访问临时属性

#### Method Name / Reserved Word Attributes

> 如果你的属性与存在的方法或者保留字发生冲突，你可以使用add_attribute定义他们

#### Inheritance

> 对于同一个类，你可以创建不同的factories，不需要重复通用的属性，通过嵌套factories

    factory :post do
      title "A title"

      factory :approved_post do
        approved true
      end
    end

    approved_post = create(:approved_post)
    approved_post.title    # => "A title"
    approved_post.approved # => true

> 你也可以直接分配

    factory :post do
      title "A title"
    end

    factory :approved_post, parent: :post do
      approved true
    end

> 如上面所说，最佳实践是，为每个类定义一个基本的factory，仅仅创建必须的属性，然后创建更多的factories通过集成父factory，
> factory定义代码

#### Associations

> 可以使用factories设置关联，如果factory名字和关联名字一样 ，factory名字可以被忽略

    factory :post do
      # ...
      author
    end

> 你能够是在那个一个不同的factory或者覆盖属性值

  factory :post do
    # ...
    association :author, factory: :user, last_name: "Writely"
  end

> 关联方法的行为变化依赖于对父对象使用的构建策略

    # 构建并保存 post和user
    post = create(:post)
    post.new_record?        # => false
    post.author.new_record? # => false

    # 构建保存user,构建post但是不保存
    post = build(:post)
    post.new_record?        # => true
    post.author.new_record? # => false

> 在factory中制定构建策略

    factory :post do
      # ...
      association :author, factory: :user, strategy: :build
    end

    # Builds a User, and then builds a Post, but does not save either
    post = build(:post)
    post.new_record?        # => true
    post.author.new_record? # => true
