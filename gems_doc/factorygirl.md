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

> 请注意 strategy: :build 选项必须明确传递给association，不能在隐式情况下使用

    factory :post do
    # ...
    author strategy: :build    # <<< this does *not* work; causes author_id to be nil

> 生成has_many关系数据更复杂一点,基于灵活性的需求，这有一个不会失败的案例生成关联数据

    FactoryGirl.define do

      # post factory 有一个关联user的 belongs_to关联 
      factory :post do
        title "Through the Looking Glass"
        user
      end

      # user factory 没有关联 posts
      factory :user do
        name "John Doe"

        # user被created后，user_with_posts将创建post数据
        factory :user_with_posts do 
          # posts_count是一个临时对象,在factory上可用，可以通过evaluator在回调中使用
          transient do
            posts_count 5
          end

          # after(:create)后面传递了2个值，user实例和evaluator,存储了来自factory的所有值
          # 和临时属性, create_list的第二个参数是创建记录的数量,我们确保user是post的关联属性
          after(:create) do |user, evaluator|
            create_list(:post, evaluator.posts_count, user: user)
          end
        end
      end
    end

> 下面我们可以这么写

    create(:user).posts.length # 0
    create(:user_with_posts).posts.length # 5
    create(:user_with_posts, posts_count: 15).posts.length # 15
  
> 生成has_and_belongs_many 关联关系类似上面的has_many，但是有一点不一样，你需要传递一组对象给模型的复数属性名
> 而不是单个对象属性名版本，看下面例子

    FactoryGirl.define do

      # language factory 有一个profile的belongs_to关联
      factory :language do
        title "Through the Looking Glass"
        profile
      end

      # profile factory 没有languages关联
      factory :profile do
        name "John Doe"

        # profile_with_languages 将创建language数据,在profile create后
        factory :profile_with_languages do
          transient do
            languages_count 5
          end

          after(:create) do |profile, evaluator|
            create_list(:language, evaluator.languages_count, profiles: [profile])
          end
        end
      end
    end
  
> 然后我们就可以这么做

    create(:profile).languages.length # 0
    create(:profile_with_languages).languages.length # 5
    create(:profile_with_languages, languages_count: 15).languages.length # 15

#### Sequences

> 生成唯一值可以使用sequences， Sequences通过调用sequence定义一个代码块，使用时通过调用generate

    # Defines a new sequence
    FactoryGirl.define do
      sequence :email do |n|
        "person#{n}@example.com"
      end
    end

    generate :email
    # => "person1@example.com"

    generate :email
    # => "person2@example.com"

> sequences可以在动态属性上使用

    factory :invite do
      invitee { generate(:email) }
    end

> 隐式使用

    factory :user do
      email # Same as `email { generate(:email) }`
    end

> 也可以定义一个内嵌的 sequence 仅仅用于特定的factory中

    factory :user do
      sequence(:email) { |n| "person#{n}@example.com" }
    end

> 可以复写初始值

    factory :user do
      sequence(:email, 1000) { |n| "person#{n}@example.com" }
    end

> 没有给定一个代码块，将以初始值自动增加

    factory :post do
      sequence(:position)
    end

> sequences可以有别名，别名间共享计数器

    factory :user do
      sequence(:email, 1000, aliases: [:sender, :receiver]) { |n| "person#{n}@example.com" }
    end

    # 使用email时计数器增加后的值也会分享给 :sender和:receiver
    generate(:sender)
  
> 使用别名，计数器默认值为1

    factory :user do
      sequence(:email, aliases: [:sender, :receiver]) { |n| "person#{n}@example.com" }
    end

> 设置默认值

    factory :user do
      sequence(:email, 'a', aliases: [:sender, :receiver]) { |n| "person#{n}@example.com" }
    end

> 设置的值需要支持#next方法， 例如"a"之后是'b','c'

#### Traits

> traits允许你定义一组属性，然后用于任何factory

    factory :user, aliases: [:author]

    factory :story do
      title "My awesome story"
      author

      trait :published do
        published true
      end

      trait :unpublished do
        published false
      end

      trait :week_long_publishing do
        start_at { 1.week.ago }
        end_at   { Time.now }
      end

      trait :month_long_publishing do
        start_at { 1.month.ago }
        end_at   { Time.now }
      end

      factory :week_long_published_story,    traits: [:published, :week_long_publishing]
      factory :month_long_published_story,   traits: [:published, :month_long_publishing]
      factory :week_long_unpublished_story,  traits: [:unpublished, :week_long_publishing]
      factory :month_long_unpublished_story, traits: [:unpublished, :month_long_publishing]
    end

> traits可以作为属性

    factory :week_long_published_story_with_title, parent: :story do
      published
      week_long_publishing
      title { "Publishing that was started at #{start_at}" }
    end

> traits可以定义一样的属性，也不会跑出AttributeDefinitionErrors; trait定义的属性越靠后，被使用的优先级越高

    factory :user do
      name "Friendly User"
      login { name }

      trait :male do
        name   "John Doe"
        gender "Male"
        login { "#{name} (M)" }
      end

      trait :female do
        name   "Jane Doe"
        gender "Female"
        login { "#{name} (F)" }
      end

      trait :admin do
        admin true
        login { "admin-#{name}" }
      end

      factory :male_admin,   traits: [:male, :admin]   # login will be "admin-John Doe"
      factory :female_admin, traits: [:admin, :female] # login will be "Jane Doe (F)"
    end

> 你也可以复写一个子类的单个属性，属性实在子类中声明

    factory :user do
      name "Friendly User"
      login { name }

      trait :male do
        name   "John Doe"
        gender "Male"
        login { "#{name} (M)" }
      end

      factory :brandon do
        male
        name "Brandon"
      end
    end

> 当你使用factory_girl构造一个实例，可以传递一个符号列表，traits作为符号传递

    factory :user do
      name "Friendly User"

      trait :male do
        name   "John Doe"
        gender "Male"
      end

      trait :admin do
        admin true
      end
    end

    # creates an admin user with gender "Male" and name "Jon Snow"
    create(:user, :admin, :male, name: "Jon Snow")

> 这中能力可以在build,build_stubbed,attributes_for,create中使用
>  create_list 和 build_list 方法也支持, 记住一点，创建实例个数通过第二个参数指定， 

    factory :user do
      name "Friendly User"

      trait :admin do
        admin true
      end
    end

    # creates 3 admin users with gender "Male" and name "Jon Snow"
    create_list(:user, 3, :admin, :male, name: "Jon Snow")


> traits也可以在associations中使用

    factory :user do
      name "Friendly User"

      trait :admin do
        admin true
      end
    end

    factory :post do
      association :user, :admin, name: 'John Doe'
    end

    # creates an admin user with name "John Doe"
    create(:post).user

> 当你使用accociation名字不同于他的factory时

    factory :user do
      name "Friendly User"

      trait :admin do
        admin true
      end
    end

    factory :post do
      association :author, :admin, factory: :user, name: 'John Doe'
      # or
      association :author, factory: [:user, :admin], name: 'John Doe'
    end

    # creates an admin user with name "John Doe"
    create(:post).author


> traits可以被其他traits使用混入他们的属性中

    factory :order do
      trait :completed do
        completed_at { 3.days.ago }
      end

      trait :refunded do
        completed
        refunded_at { 1.day.ago }
      end
    end

> 最后 traits允许临时属性

    factory :invoice do
      trait :with_amount do
        transient do
          amount 1
        end

        after(:create) do |invoice, evaluator|
          create :line_item, invoice: invoice, amount: evaluator.amount
        end
      end
    end

    create :invoice, :with_amount, amount: 2
    
#### Callbacks

> factory_girl有四种可用的回调用来注入代码

* after(:build) 在factory built后调用 ,built是指 FactoryGirl.build, FactoryGirl.create 之后
* before(:create) 在factory saved之前调用，是指FactoryGirl.create之前
* after(:create) 一个factory saved之后调用，是指 FactoryGirl.create之后
* after(:stub)  一个 factory stubbed后调用， 是指 FactoryGirl.build_stubbed之后

> example:

    # 定义一个factory 然后在生成他的密码 
    factory :user do
      after(:build) { |user| generate_hashed_password(user) }
    end

> 注意你在代码块中有一个user实例，这个很有用

> 你也可以同时使用多个回调在一同一个factory上

    factory :user do
      after(:build)  { |user| do_something_to(user) }
      after(:create) { |user| do_something_else_to(user) }
    end

> factory可以在同一个factory上定义同一种回调。执行顺序按照定义顺序

    factory :user do
      after(:create) { this_runs_first }
      after(:create) { then_this }
    end

> create都可以触发 after_build和after_create回调

> 像标准的属性，子factory会集成父factory的回调

> 多个回调可以分配同一个代码块， 当构建策略不同，但是代码一样时，很有用

    factory :user do
      callback(:after_stub, :before_create) { do_something }
      after(:stub, :create) { do_something_else }
      before(:create, :custom) { do_a_third_thing }
    end

> 对所有factories有效的回调。在FactoryGirl.define中定义

    FactoryGirl.define do
      after(:build) { |object| puts "Built #{object}" }
      after(:create) { |object| AuditLog.create(attrs: object.attributes) }

      factory :user do
        name "John Doe"
      end
    end

> 你也可以使用Symbol#to_proc调用回调

      # app/models/user.rb
      class User < ActiveRecord::Base
        def confirm!
          # confirm the user account
        end
      end

      # spec/factories.rb
      FactoryGirl.define do
        factory :user do
          after :create, &:confirm!
        end
      end

      create(:user) # creates the user and confirms it

#### Modifying factories

> 如果你得到一组factories，可能来自某个gem的开发者，你想修改这个factories以更好的适应你的应用程序
> 你可以采用创建一个子factory形式加入你自己的属性

> 如果一个gem给你这样一个User factory

    FactoryGirl.define do
      factory :user do
        full_name "John Doe"
        sequence(:username) { |n| "user#{n}" }
        password "password"
      end
    end

> 创建一个子factory并且加入自定义属性

    FactoryGirl.define do
      factory :application_user, parent: :user do
        full_name     "Jane Doe"
        date_of_birth { 21.years.ago }
        gender        "Female"
        health        90
      end
    end

> 你也可以修改factory 

    FactoryGirl.modify do
      factory :user do
        full_name     "Jane Doe"
        date_of_birth { 21.years.ago }
        gender        "Female"
        health        90
      end
    end

> 当你修改一个factory，你可以改变任何你想要的属性

> FactoryGirl.modify必须在FactoryGirl.define定义块，外面调用

> 一个警告，你仅仅能修改factories(不包括sequences或者traits)和回调，复合于他们本来的期望
> 如果一个factory你修改了他的after(:create)回调，你定义的after(:create)不会覆盖原来的，
> 你的after(:create)在第一个回调运行后再执行

#### Building or Creating Multiple Records

> 有时你想create和build多个实例在一个时间点

    built_users   = build_list(:user, 25)
    created_users = create_list(:user, 25)

> 这些方法将会build或者create指定数量的factories，返回一个数组，设置属性可以传递一个你希望的hash

    twenty_year_olds = build_list(:user, 25, date_of_birth: 20.years.ago)

> build_stubbed_list 给你完成的测试桩

  stubbed_users = build_stubbed_list(:user, 25) # array of stubbed users

> 一组带*_pair的方法一次创建两个实例

    built_users   = build_pair(:user) # array of two built users
    created_users = create_pair(:user) # array of two created users

> 如果你需要多个hash结构的属性，可以使用 attributes_for_list

    users_attrs = attributes_for_list(:user, 25) # 返回一个数组，数组里是hash结构的属性列表

#### Linting(自检) Factories

> factory_girl允许检测已知的factories

> FactoryGirl.lint 创建每个factory并且捕获创建期间的所有异常
> 如果factory没有被创建将抛出FactoryGirl::InvalidFactoryError

> 注意，执行 FactoryGirl.lint在在一个task里，在你执行测试套件之前执行，运行它在before(:suite)里，
> 当运行单个测试时，会对测试的性能产生负面影响。

> Example

    # lib/tasks/factory_girl.rake
    namespace :factory_girl do
      desc "Verify that all FactoryGirl factories are valid"
      task lint: :environment do
        if Rails.env.test?
          begin
            DatabaseCleaner.start
            FactoryGirl.lint
          ensure
            DatabaseCleaner.clean
          end
        else
          system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
        end
      end
    end

> 在调用FactoryGirl.lint后，你或许想清理数据库，有些记录会被created，上面例子使用了datebase_cleaner这个gem
> 确保这个gem加入到了你的Gemfile里，在对应的gem策略组里

> 你可以选择性的检测factories,传递你想检测的factories

    factories_to_lint = FactoryGirl.factories.reject do |factory|
      factory.name =~ /^old_/
    end

    FactoryGirl.lint factories_to_lint

> 如果没有old_前缀，将检测所有factories

> traits可以被检测，这有一个验证选项，用来验证每次生成的每个factory的对象是合法的，通过传递traits: true开启

    FactoryGirl.lint traits: true

> 也可以与其他参数组合

    FactoryGirl.lint factories_to_lint, traits: true

#### Custom Construction

> 如果你想使用factory_girl构造一个对象，传递一些属性给initialize方法或者你想做一些其他事而不是简单在类上调用new的操作，
> 你可以通过定义initialize_with在你的factory上复写默认行为

    # user.rb
    class User
      attr_accessor :name, :email

      def initialize(name)
        @name = name
      end
    end

    # factories.rb
    sequence(:email) { |n| "person#{n}@example.com" }

    factory :user do
      name "Jane Doe"
      email

      initialize_with { new(name) }
    end

    build(:user).name # Jane Doe


> 虽然factory_girl被写成配合acriverecord一起使用，达到开箱即用，它可以配合任何ruby class， 与acriverecord有最大的兼容性
> 默认的initializer构建多个实例通过调用new在你的构建类上不需要任何参数，然后调用属性写方法分配属性值，
> 这对于acriverecod工作很友好，它实际上不适用与任何其他ruby类
> 你可以复写initializer按照下面顺序

* 构建不是acriverecord对象需要传递参数给initialize

* 使用方法而不是new初始化实例

* 构建后装饰实例

> 当使用initialize_with方法，当使用new时,你不需要声明类本身，然后任何其他类方法可以在类上明确调用

>例子:

    factory :user do
      name "John Doe"

      initialize_with { User.build_with_name(name) }
    end

> 你可以可以访问公共属性，使用initialize_with代码块，通过attributes

    factory :user do
      transient do
        comments_count 5
      end

      name "John Doe"

      initialize_with { new(attributes) }
    end

> 这将会构建一个包括素有属性的hash传递给new方法，但是不会包括transient属性，但是其他方式定义属性将会被传递
> 例如 associations  sequences等

> 你可以定义initialize_with为所有factories，通过在factoryGirl.define块中定义

    FactoryGirl.define do
      initialize_with { new("Awesome first argument") }
    end

> 当使用initialize_with时，initialize_with代码块中被访问的属性,仅仅用来构造方法中使用，
> 大致相当于一下代码

    FactoryGirl.define do
      factory :user do
        initialize_with { new(name) }

        name { 'value' }
      end
    end

    build(:user)
    # runs
    User.new('value')

> 这将防止重复分配，4.0版本之前，将会按照下面方式执行

    FactoryGirl.define do
      factory :user do
        initialize_with { new(name) }

        name { 'value' }
      end
    end

    build(:user)
    # runs
    user = User.new('value')
    user.name = 'value'

#### Custom Strategies

> 有时你想扩展factory_girl通过添加自定义的行为

> Strategies定义有两个方法， association 和 result， association接收一个FactoryGirl::FactoryRunner实例
> 在这个实例上调用run，如果你想可以复写这个策略，第二个方法，result，接受一个FactoryGirl::Evaluation实例,
> It provides a way to trigger callbacks (with notify), object or hash (to get the result instance or a hash 
> based on the attributes defined in the factory), and create, which executes the to_create callback defined on > the factory.

> 理解factory_girl内部怎样使用策略，最简单的是查看默认策略源码

>下面有一个例子， 组成一个策略， 使用FactoryGirl::Strategy::Create构建一个sjon表示你的模型

    class JsonStrategy
      def initialize
        @strategy = FactoryGirl.strategy_by_name(:create).new
      end

      delegate :association, to: :@strategy

      def result(evaluation)
        @strategy.result(evaluation).to_json
      end
    end

> 使用Factory_girl注册这种新策略，

  FactoryGirl.register_strategy(:json, JsonStrategy)

> 允许你调用

    FactoryGirl.json(:user)

> 你希望通过注册一个新的对象代替策略，你可以复写factory_girl自己的策略，


#### Custom Callbacks

>如果你是使用自定义策略，callback可以被定义

    class JsonStrategy
      def initialize
        @strategy = FactoryGirl.strategy_by_name(:create).new
      end

      delegate :association, to: :@strategy

      def result(evaluation)
        result = @strategy.result(evaluation)
        evaluation.notify(:before_json, result)

        result.to_json.tap do |json|
          evaluation.notify(:after_json, json)
          evaluation.notify(:make_json_awesome, json)
        end
      end
    end

    FactoryGirl.register_strategy(:json, JsonStrategy)

    FactoryGirl.define do
      factory :user do
        before(:json)                { |user| do_something_to(user) }
        after(:json)                 { |user_json| do_something_to(user_json) }
        callback(:make_json_awesome) { |user_json| do_something_to(user_json) }
      end
    end

#### Custom Methods to Persist Objects

> 默认情况，创建一个记录，调用save!在实例上，但是这不一定总是理想的，你可以复写to_create方法 在factory里

    factory :different_orm_model do
      to_create { |instance| instance.persist! }
    end

> 在create时关闭持久化方法，使用skip_create

    factory :user_without_database do
      skip_create
    end

> 在FactoryGirl.define块里复写 to_create方法为所有的factories

    FactoryGirl.define do
      to_create { |instance| instance.persist! }


      factory :user do
        name "John Doe"
      end
    end

#### ActiveSupport Instrumentation

> 为了跟踪factories使用构建策略创建，ActiveSupport::Notifications提供了一个方式去订阅factories运行，
> 下面例子是跟踪factories基于一个执行阈值

    ActiveSupport::Notifications.subscribe("factory_girl.run_factory") do |name, start, finish, id, payload|
      execution_time_in_seconds = finish - start

      if execution_time_in_seconds >= 0.5
        $stderr.puts "Slow factory: #{payload[:name]} using strategy #{payload[:strategy]}"
      end
    end

>另一个例子是跟踪所有的factories,在你的测试套件期间，如果你使用rspec，你可以简单的添加到 before(:suite) and after(:suite)

    factory_girl_results = {}
      config.before(:suite) do
        ActiveSupport::Notifications.subscribe("factory_girl.run_factory") do |name, start, finish, id, payload|
          factory_name = payload[:name]
          strategy_name = payload[:strategy]
          factory_girl_results[factory_name] ||= {}
          factory_girl_results[factory_name][strategy_name] ||= 0
          factory_girl_results[factory_name][strategy_name] += 1
        end
      end

      config.after(:suite) do
        puts factory_girl_results
      end


#### Rails Preloaders and RSpec

> 当运行rspec时伴随着使用 spring或者zeus预加载器，可能会遇到一个ActiveRecord::AssociationTypeMismatch错误
> 在使用associations创建factory时， 如下

    FactoryGirl.define do
      factory :united_states, class: Location do
        name 'United States'
        association :location_group, factory: :north_america
      end

      factory :north_america, class: LocationGroup do
        name 'North America'
      end
    end

> 错误发生在套件运行期间
    Failure/Error: united_states = create(:united_states)
    ActiveRecord::AssociationTypeMismatch:
      LocationGroup(#70251250797320) expected, got LocationGroup(#70251200725840)


> 两种解决方案，一个是不适用预加载器运行，或者添加FactoryGirl.reload到rspec配置块里

    RSpec.configure do |config|
      config.before(:suite) { FactoryGirl.reload }
    end

#### Using Without Bundler

> 如果你没有使用Bundler，确保gem被安装，调用如下

    require 'factory_girl'

>一旦引入，假设你有一个spec/factories or test/factories 的目录结构，你需要执行

    FactoryGirl.find_definitions

> 如果你使用特殊目录结构存放你的factories，你需要改变定义路径，在执行find definitios之前

    FactoryGirl.definition_file_paths = %w(custom_factories_directory)
    FactoryGirl.find_definitions

> 如果你没有特殊的存放你的factories，将他们定义成内联，这也是可以的

    require 'factory_girl'

    FactoryGirl.define do
      factory :user do
        name 'John Doe'
        date_of_birth { 21.years.ago }
      end
    end


































