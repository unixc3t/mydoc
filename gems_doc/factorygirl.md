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