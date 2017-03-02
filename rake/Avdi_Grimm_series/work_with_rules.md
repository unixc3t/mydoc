> 前面两节我们构造了一个Rakefile文件用来将Markdown文件编译成html。这个文件按照现在样子工作，但是它包含了一些重复代码
> 这个文件包含基于一样的两个规则，一个用来寻找.md文件,另一个寻找.markdown文件，如果我们将两个规则合并成一个将更好，更通用

	source_files = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
		fl.exclude("~*")
		fl.exclude(/^scratch\//)
		fl.exclude do |f|
		`git ls-files #{f}`.empty?
		end
	end

	task :default => :html
	task :html => source_files.ext(".html")

	rule ".html" => ".md" do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

	rule ".html" => ".markdown" do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end
	

> 我们移除第二个规则，然后运行rake,但是失败了
	
	
	source_files = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
		fl.exclude("~*")
		fl.exclude(/^scratch\//)
		fl.exclude do |f|
			`git ls-files #{f}`.empty?
		end
	end

	task :default => :html
	task :html => source_files.ext(".html")

	rule ".html" => ".md" do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

	$ rake
	rake aborted!
	Don't know how to build task 'ch4.html'

	Tasks: TOP =&gt; default =&gt; html
	(See full trace by running task with --trace)

> 在我们继续向前之前，我们讨论一下这个错误， 提示说，不知道如何构建任务ch4.html， 但是没有告诉我们更多，这有点困扰，
> 因为提到的任务叫做ch4.html，但是ch4.html是一个我们想构建的文件，不是一个任务，不是么？

> 实际上rake任务所有的东西都被要求作为任务构建， 仅有不同就是普通任务和文件任务，rake认为如果一个文件匹配任务名，
> 文件比它任何依赖的任务都新，它不必费心去执行任务

> 在这例子里，我们知道为什么没有构建这个文件，因为我们移除这个告诉他如何操作的规则，如果我们不知道呢， 这个错误信息没有给我们很多细节
> 为了更好的理解rake做的工作，我们可以传递-trace标记， 这次，rake留下踪迹可循,告诉我们它的处理过程，
> 首先，他调用了默认的task， 我们让默认task依赖于这个html任务， 所以这个html任务是下一个调用的任务
> 这步后面，rake报错，因为他不知道如何构建ch4.html,下面是堆栈信息
	
	  $ rake --trace
	** Invoke default (first_time)
	** Invoke html (first_time)
	rake aborted!
	Don't know how to build task 'ch4.html'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task_manager.rb:49:in `[]'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task.rb:53:in `lookup_prerequisite'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task.rb:49:in `block in prerequisite_tasks'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task.rb:49:in `map'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task.rb:49:in `prerequisite_tasks'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task.rb:195:in `invoke_prerequisites'
	/home/avdi/.rvm/gems/ruby-1.9.3-p327/gems/rake-10.1.0/lib/rake/task.rb:174:in `block in invoke_with_call_chain'
	/usr/lib/ruby/1.9.1/monitor.rb:211:in `mon_synchronize'
	
	
> 让我们查询rake为什么先运行ch4.html任务，我们可以使用-p标记，查看依赖列表
	
	$ rake -P
	rake default
		html
	rake html
		ch1.html
		ch2.html
		ch3.html
		subdir/appendix.html
		ch4.html

> 输出结果很清晰，html任务依赖文件列表，包括了ch4.html
> 记住，我们仍然假装不知道哪里出了问题，我们目前已经收集了很多rake如何工作的信息，目前。我们不清楚HTML文件和Markdown文件之间的关系，
> 为了解决问题。我们需要知道这一点 

> 我们为了更深入了解rake如何思考处理，我们下一步在rakefile文件中设置一个选项，Rake.application.options.trace_rules=true
> 这个选项正如名字所示，给我们定义在rakefile文件中rule的跟踪信息

> 注意，–rules 这个选项也可以在命令行中使用
	
	Rake.application.options.trace_rules = true

	source_files = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
		fl.exclude("~*")
		fl.exclude(/^scratch\//)
		fl.exclude do |f|
			`git ls-files #{f}`.empty?
		end
   	end

	task :default => :html
	task :html => source_files.ext(".html")

	rule ".html" => ".md" do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

> 这次，我们再次运行 rake -trace ,除了任务调用信息以外还附加了一些新的信息， 例如，对于每个文件构建，rake告诉我们.html关联的.md文件使用的
> 规则，当运行ch4.html任务时， 失败了，没有直接说ch4.md文件没找到，但是目前的信息。我们差不多可以推论出问题所在
	
	$ rake --trace
	** Invoke default (first_time)
	** Invoke html (first_time)
	Attempting Rule ch1.html => ch1.md
	(ch1.html => ch1.md ... EXIST)
	Attempting Rule ch2.html => ch2.md
	(ch2.html => ch2.md ... EXIST)
	Attempting Rule ch3.html => ch3.md
	(ch3.html => ch3.md ... EXIST)
	Attempting Rule subdir/appendix.html => subdir/appendix.md
	(subdir/appendix.html => subdir/appendix.md ... EXIST)
	Attempting Rule ch4.html => ch4.md
	(ch4.html => ch4.md ... FAIL)
	rake aborted!
	Don't know how to build task 'ch4.html'

> 现在，让这个规则工作再次正常，我们定义一个方法叫做，source_for_html, 它接收一个html文件名字，返回一个关联的markdown文件。
> 为了做到这点，我们需要访问源文件列表， 现在这个列表是本地变量，不允许在方法里被访问，我们将他变成常量

> 我们从源文件列表中查找第一源文件的基本名字匹配给定的html文件的基本名字。 为了达到只比较基本名字，我们使用ext方法，你或许记得
> 我们使用这个方法得到需要生成的html文件名列表，这次我们传递一个空的字符串给ext方法，移除扩展名

	def source_for_html(html_file)
		SOURCE_FILES.detect{|f| f.ext('') == html_file.ext('')}
	end

> “等等” 你说到，之前我们在FileList上调用ext， 现在我们在字符串上调用这个方法，它如何工作的？
> rake修改了Ruby的字符串类，支持一些FileList支持的方法， 所有我们可以在FileList上和单独文件名上互用

> 现在我们有了一个方法，给定html文件名，找到生成它的源markdown文件，现在我们需要在.html规则上使用这个方法


> 我们做的是替换.md依赖为一个lambda表达式， 我们使用单个参数，传递给我们的source_for_html方法， 当rake尝试构建一个.html文件
> 他传递目标文件到lambda里， 如果匹配到文件，将会使用返回的文件， 然后考虑规则匹配，然后执行相关代码

	rule ".html" => ->(f){source_for_html(f)} do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

> 我们仍然将规则跟踪激活，我们使用新窗口显示rake 使用我们更新后的规则，当遇到ch4.html时，它正确的找到了依赖的ch4.markdown文件
> 而不是ch4.md 找到文件后，然后开始构建ch4.html文件


	$ rake
	Attempting Rule ch1.html => ch1.md
	(ch1.html => ch1.md ... EXIST)
	Attempting Rule ch2.html => ch2.md
	(ch2.html => ch2.md ... EXIST)
	Attempting Rule ch3.html => ch3.md
	(ch3.html => ch3.md ... EXIST)
	Attempting Rule subdir/appendix.html => subdir/appendix.md
	(subdir/appendix.html => subdir/appendix.md ... EXIST)
	Attempting Rule ch4.html => ch4.markdown
	(ch4.html => ch4.markdown ... EXIST)
	pandoc -o ch4.html ch4.markdown

> 我们现在有了一个通用规则，构建html，使用markdown的长或者短扩展名文件。但是更重要的是，我们知道rake使用rule如何决定和构建。
> 下面是最终的Rakefile：
	
	Rake.application.options.trace_rules = true

	SOURCE_FILES = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
		fl.exclude("~*")
		fl.exclude(/^scratch\//)
		fl.exclude do |f|
			`git ls-files #{f}`.empty?
		end
	end

	task :default => :html
	task :html => SOURCE_FILES.ext(".html")

	rule ".html" => ->(f){source_for_html(f)} do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

	def source_for_html(html_file)
		SOURCE_FILES.detect{|f| f.ext('') == html_file.ext('')}
	end
