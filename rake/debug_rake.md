#### Using command-line arguments for debugging

> 开发过程中主要信息就是backtrace，在确定时间段内一个程序运行报告，当rake任务失败了，你不需要整个backtrace,例子如下
	
	task :task1 do
		raise 'this is an error'
	end
	task :task2 => :task1 do
		puts 'task 2'
	end

> 下面是运行task2结果
	
	$ rake task2
	rake aborted!
	this is an error
	~/rakefile:2:in `block in <top (required)>'
	Tasks: TOP => task2 => task1
	(See full trace by running task with --trace)

> 注意整个backtrace的信息只有一行 ~/rakefile:2:in 'block in <top (required)>' )
> 如果想得到完整的trace信息使用 --backtrace选项

	$ rake --backtrace task2
	rake aborted!
	this is an error
	~/rakefile1:2:in `block in <top (required)>'
	.../ruby/gems/2.1.0/gems/rake-10.1.1/lib/rake/task.rb:236:in `call'
	.../ruby/gems/2.1.0/gems/rake-10.1.1/lib/rake/task.rb:236:in `block inexecute'
	... # the following lines will contain a lot of lines, so they are omitted here
	Tasks: TOP => task2 => task1

> 如果运行没有失败，不会包含backtrace,库信息不同由于你怎样安装gem在你的project中
> 如果你想看到task执行顺序，使用--trace参数，也有一个简写形式 -t

	$ rake --trace task2
	** Invoke task2 (first_time)
	** Invoke task1 (first_time)
	** Execute task1
	task 1
	** Execute task2
	task 2

> 如你所见，输出包含十分有用的信息，task按照依赖关系的执行顺序，如果task抛出异常， 使用--backtrace时，整个backtrace也会显示出来，

> 堆栈信息包含e很多对于库的描述，有时影响我们找到bug，使用一个 --suppress-backtrace选项帮助我们过滤不想要的信息， 如下例子
	
	$ rake --suppress-backtrace /ruby/2.1.0/ task2


#### Getting a dependency's resolution with --prereqs

> 另一种有用的选项展示任务依赖解析，-P or --prereqs 不像--trace选项， 依赖解析选项不执行任务， 如下展示
	
	$ rake -P
	rake task1
	rake task2
		task1


> 打印出了定义的依赖，和使用缩进展示他们依赖的task, task1 这行文版向前移动了一点， 并且在task2下面，表示task2依赖他

#### Using the --rules option to trace the rule resolution

> task关系之间最难的就是rules， 在这个例子里，一个 rule task 被用来适应许多task name,例如当一个rule被设置成正则表达式来代替名字，
> 当你运行一个task，这个task使用一个rule， 知道哪个task执行和按哪种顺序执行是非常有用的， rake提供了 --rules选项，用来告诉我们rule's解析结果
> 看下面实例代码
	
！[](p5.png)
！[](p6.png)

> 通过 article[number] task 生成的规则解析信息很复杂 
	
	$ rake --rules generate:article[1]
	
！[](p7.png)


#### Using the Ruby approach to debug a Rake project

> 你已经知道了。一个rake项目也是一个ruby项目，对于ruby项目操作也适用于rake项目， 你也可以使用来自ruby的debug方法

> 有两个工具可以调试ruby代码，debugger和pry，这些工具对于调试都很有用， 他们之间有一些细微差别， debugger工具是一个特殊调试工具在很多语言中， pry是一个改良的控制台
> 被设计在多种上下文中工作， 包括程序在后台运行，

> 使用这些工具步骤大致如下
	
	1 安装工具
	2 设置断点
	3 运行 程序
	4 观察结果


>使用debugger之前，你需要安装它，你有两个选择，bundler或者安装gem到系统上或者gemset ，这取决于你怎么组织项目代码，
> 下面例子使用debugger

	require 'debugger'
	task :test do
	puts 'starting the test task'
	debugger
	puts 'ending the test task'
	end

> 当你运行这个test task时，代码将会停在debugger这行， 

	$ rake test
	starting the test task
	~/rakefile:6
	puts 'ending the test task'
	[1, 10] in ~/rakefile
	1 require 'debugger'
	
	2
	3 task :test do
	4 puts 'starting the test task'
	5 debugger
	=> 6 puts 'ending the test task'
	7 end
	
	(rdb:1)
