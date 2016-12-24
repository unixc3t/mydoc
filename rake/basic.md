#### 命令行参数 
>-T 显示已经定义的有描述信息的任务

	$ rake -T

> 如果你也想显示没有描述的任务加上-A

	$ rake -TA

#### 定义全局Rakefile

> 方式一: 在你的用户家目录里定义Rakefile,rake在查找Rakefile文件时,如果当前目录没有,会去家目录寻找
> 方式二: 在你的家目录的.rake目录下定义,如果没有这个目录需要手动创建一个,在使用的时候加上-g参数
	
	$ mkdir ~/.rake
	$ touch ~/.rake/hello.rake
	$ echo -e 'task "hello" do\n rake puts "Hello, Rake"\nend' > ~/.rake/hello.rake
	$ rake -g hello
		Hello, Rake
	
#### 自定义任务
>通常传递一个参数为任务名(符号形式)给task方法,然后再传递一个代码块作为第二个参数给task方法,代码块里面包含ruby代码

	desc 'Restart web server'
	task :restart do
		touch '~/restart.txt'
	end
	
	$ rake restart
>如果你有很多任务,最好放到相应的命名空间

	namespace :server do
		desc 'Restart web server'
			task :restart do
				touch './tmp/restart.txt'
			end
	end
	$rake server:restart
>task方法可以接受更多参数,以后介绍

#### 任务依赖-前提条件

> 一个任务依赖另一个任务

	task :clean do
		puts 'Cleaning data...'
	end
	task :seed => :clean do
		puts 'Seeding data...'
	end

>在执行seed任务之前执行clean任务
>如果有命名空间的话,就加在名字前面

	namespace :db do
		task :clean do
			puts 'Cleaning data...'
		end
	end
	task :seed => 'db:clean' do
		puts 'Seeding data...'
	end

>如果有一样的命名空间就不需要添加前缀

	namespace :db do
		task :clean do
			puts 'Cleaning data...'
		end
		task :seed => :clean do
              puts 'Seeding data...'
		end
	end

> 默认任务引用其他任务

	task :default => :some_task
	
> 一个任务可以依赖多个任务,如下

	task :task1 => [:task2,:task]

#### 传递参数给任务

> 第一种方案使用环境变量

	task :set_title do
		title = ENV['TITLE'] || 'Blog'
		puts "Setting the title: #{title}"
	end
	
>使用方式
	
	$ rake set_title TITLE='My Blog'
	Setting the title: My Blog
	$ rake set_title # default title should be set in this case
	Setting the title: Blog

>使用系统变量,导致其他任务也可以访问到设置的变量

>第二种方式使用Rakefile的特性,传递参数给任务

	task :set_title, [:title] do |t, args|
		args.with_defaults(:title => 'Blog')
		puts "Setting title: #{args.title}"
	end
	
>args结构类似一个hash,是Rake::TasksArguments class的一个对象,
>我们使用with_defaults方法,如果你不传递参数,:title就是用Blog作为她的值.

>使用方式

	$ rake "set_title[My Blog]"
	Setting title: My Blog
	$ rake set_title
	Setting title: Blog

>可以传递多个参数给rake任务
>下面定义多个参数任务
	
	task :name, [:first_name, :last_name] do |t, args|
		puts "First name is #{args.first_name}"
		puts "Last name is #{args.last_name}"
	end

>调用方式
	
	rake name["hello","world"]

>传递长度可变的参数 

	task :email, [:message] do |t, args|
		puts "Message: #{args.message}"
		puts "Recipients: #{args.extras}"
		puts "All variables: #{args.to_a}"
	end

>调用方式
	
	$ rake "email[Hello Rake, ka8725@gmail.com, test@example.com]"
	Message: Hello Rake
	Recipients: ["ka8725@gmail.com", "test@example.com"]
	All variables: ["Hello Rake", "ka8725@gmail.com", "test@example.com"]

>第一个参数赋给:message,其余传递给 extras方法,可以使用to_a方法将args转变成数组

#### Rake项目的结构

>如果你的项目有很多rake任务,你可以将任务分散到单独文件里,将这些文件放到rakelib目录里,这些单独文件
>以.rake作为扩展名,你不需要做任何其他动作,*.rake文件将会自动被引入到Rakefile文件里
>rake文件里也可以编写ruby代码定义任务
>下面例子创建rakelib目录,在目录里创建clean.rake,定义cleanx任务,并在rakefile文件中调用这个任务
	
	$ mkdir rakelib
	$ cat > rakelib/clean.rake
		task :cleanx do
			puts 'Cleaning...'
		end
		^D
	$ cat > Rakefile
	task :default => :clean
	^D
	$ rake
	Cleaning...

>如果有2个default任务后面定义的先执行

#### 使用import方法读取其他rakefile文件

>可以引入其他ruby文件或者rakefiles文件到当前Rakefile文件里通过require来实现
>但是require受限于引入的位置,这时使用import方法

	import(filenames)

>可以传递这个方法多个文件名,还有一个特性,传递给import的文件会立刻执行 看下面例子

	task 'dep.rb' do
		sh %Q{echo "puts 'Hello, from the dep.rb'" > dep.rb}
	end
	task :hello => 'dep.rb'
	import 'dep.rb'

>执行

	rake hello
	echo "puts 'Hello, from the dep.rb'" > dep.rb
	Hello, from the dep.rb
		
#### 运行来自其他任务的

>有时你需要手动执行定义的任务,例如你有两个方法,execute和invoke,两个方法不同之处是execute方法
>不会调用依赖任务,但是inovke会调用依赖任务,这两个方法都允许传递参数给任务 使用方式如下

	Rake::Task['hello'].invoke
	Rake::Task['hello'].execute
	
>使用 Rake::Task['hello']我们得到hello任务,返回了一个Rake::Task类的实例,所以我们可以运行任何
>方法,上面的例子我们调用invoke和execute方法

>如果使用了命名空间.我们在任务前面加上

	Rake::Task['my:hello']

>还有一个不同就是inovek不可以执行2次,如果你想执行2次,需要调用一次reenable方法

	Rake::Task['hello'].invoke
	Rake::Task['hello'].reenable
	Rake::Task['hello'].invoke
	
>示例
	
	task :clean do
		puts 'cleaning data...'
	end
	task :process do
		puts 'processing some data...'
		Rake::Task['clean'].invoke
	end
	task :process_with_double_clean do
		puts 'processing some data...'
		Rake::Task['clean'].invoke
		Rake::Task['clean'].invoke
	end
	task :process_with_double_clean_and_reenable do
		puts 'processing some data...'
		Rake::Task['clean'].invoke
		Rake::Task['clean'].reenable
		Rake::Task['clean'].invoke
	end

>调用

	$rake -f rakefile22 process
	processing some data...
	cleaning data...
	$rake -f rakefile22 process_with_double_clean
	processing some data...
	cleaning data...
	$rake -f rakefile22 process_with_double_clean_and_reenable
	processing some data...
	cleaning data...
	cleaning data...

#### rake代码约定

>定义任务时你可以使用大括号,如下

	namespace(:server) do
		desc('Restart web server')
		task(:restart) do
		touch('./tmp/restart.txt')
		end
	end

>然而这样的代码看起来很丑
>代码块再ruby中可以使用do/end或者{}大括号,这里建议用do/end

>大括号问题,看下面代码

	def dependent_tasks
		[:task2, :task3]
	end
	task :task2 do
		puts 'In task2...'
	end
	task :task3 do
		puts 'In task3...'
	end
	task :task1 => dependent_tasks {
		puts 'In task1...' # We are expecting this code to be run but it's not
	}	

>执行后结果

	$ rake task1
	In task2...
	In task3...

>In task1这行语句我们没有看到输出,因为大括号的优先级高于do/end,所以大括号与dependent_tasks
>组合了.而不是task方法
>再依赖的任务后面传递代码块是无效的

	require 'rake'
	task :task1 => :task2 {}

>这个代码是错误的,报出错误 # => SyntaxError: syntax error, unexpected '{', expecting end-of-input

>还有一点就是不要使用新的hash语法设置依赖任务,意思就是不要使用这样的语法

	task1: :task2

>建议使用火箭符号 =>代替冒号:

	
