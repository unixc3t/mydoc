#### Understanding the duplication of the file tasks

> 前面章节，我们编写了blog生成器， 让我们修正一下我们前面写的代码

	require_relative 'blog_generator'
	articles = Rake::FileList.new('**/*.md','**/*.markdown') do |files|
		           files.exclude('~*')
				   files.exclude(/^temp.+\//)
				   files.exclude do |file|
	                  File.zero?(file)
				  end
	end

	task :default => 'blog.html'
	articles.ext.each do |article|
		file "#{article}.html" => "#{article}.md" do
			sh "pandoc -s #{article}.md -o #{article}.html"
		end
	file "#{article}.html" => "#{article}.markdown" do
		sh "pandoc -s #{article}.markdown -o #{article}.html"
		end
	end
	
	FileUtils.rm('blog.html', force: true)
	file 'blog.html' => articles.ext('.html') do |t|
		BlogGenerator.new(t).perform
	end

> 上面的代码暴露了2个问题
> 包含了代码重复的问题
> 我们通过遍历所有文章来定义这些任务的，导致大量任务定义，这不是一件好事
> 在面向对象编程里，我们总是试图保证类接口简洁，因为臃肿的接口导致大量复杂性，当你定义了一个新的rake任务，你就定义了一个新的函数，这样就
> 扩展了你的Rakefile的接口，当你有大量tasks,管理大量复杂的任务会让你烦躁。此外，让你定义一个rake任务的时候，一个Rake::Task实例占据
> 了内存，对于文件任务，实例就是Rake::FileTask的实例，我们可以定义一种模式去整合这些任务变成一个任务，
> 在这个章节我们学习重构改良解决这些问题,使用rake的特性rule

#### Using a rule to get rid of the duplicated file tasks

> 为了清除重复的文件任务，有一个特殊的rake任务，叫做rule， 这是一个常规的rake任务，但是他有一个特性， 它允许为一个task定义一个模板，而不是
> 一个精确的名字， 我们稍后解释，现在我们仅仅看一下rule方法是怎么做的，下面是我们使用rule方法修改后的代码

	require_relative 'blog_generator'

	articles = Rake::FileList.new('**/*.md','**/*.markdown') do |files|
		files.exclude('~*')
		files.exclude(/^temp.+\//)
		files.exclude do |file|
			File.zero?(file)
		end
	end
	task :default => 'blog.html'
	rule '.html' => '.md' do |t|
		sh "pandoc -s #{t.source} -o #{t.name}"
	end
	rule '.html' => '.markdown' do |t|
		sh "pandoc -s #{t.source} -o #{t.name}"
	end
	FileUtils.rm('blog.html', force: true)
	file 'blog.html' => articles.ext('.html') do |t|
		BlogGenerator.new(t).perform
	end
	
> 默认任务是blog.html任务， 并且blog.html任务依赖于*.html文件任务列表，这个列表一个将所有markdown文件扩展名替换成.html扩展名列表
> 前面的例子，我们达到的目的： 移除需要为每篇文章创建从markdown文件转换到html文件的任务，同样，我们也没有很多任务，你或许猜到，这个rule方法
> 的形式和一个普通任务和文件一样， 但是这有一个很大的不同，你传递一个匹配模式定义依赖和任务名，而不是字符串， 规则就是rake将会捕捉以.html结尾
> 的任务， 第一个rule定义依赖文件以.md结尾。第二个rule依赖以markdown为扩展名的文件。
> 例如，我们运行task.html任务，这个规则将会与它联系起来，依赖task.md或者task.markdown文件

> 仍然有可以改进的地方，我们需要添加代码，我们可以使用一个rule替换两个，同时不会失去任何特性， 上面两个rule基本上是一样的，rake文档介绍。我们可以传递proc
> 替换依赖任务的定义
> proc对象提供了一个选项，task_name, 我们能够做任何我们想做的事情，使用这个动态定义依赖，换句话说，将task_name转换是一个艰巨的任务，因为它必须真是存在，
> 如果一个依赖的任务如果不存在，一个异常将会被rake抛出来， 对于我们的例子，对于task_name可能的值是扩展名从md或者markdown转换到html文章列表，关键是rule，
> 如何理解这个， blog.html依赖于*.html任务来自于以markdwon扩展名组成的文章列表

#### Detecting a source for the rule dynamically

> 在我们的blog里，我们拥有的文章列表： article1.md,article2.md和article3.markdown。当我们得到了task_name的值，可能是article1.html，artcile2.html或者article3.html
> 没有信息提供显示源是什么，如果task_name的值是article1.html哪个是源,article1.md还是article1.markdown，对于理解这个，我们应该动态定义它，可能的解决方案是通过articles查看
> 是否有article1.md或者article1.markdown。 使用proc来解决这个是可能的， 

	require_relative 'blog_generator'
	articles = Rake::FileList.new('**/*.md','**/*.markdown') do |files|
	                                   files.exclude('~*')
									   files.exclude(/^temp.+\//)
									   files.exclude do |file|
									   File.zero?(file)
								   end
							   end
	task :default => 'blog.html'
	detect_file = proc do |task_name|
		articles.detect { |article| article.ext == task_name.ext }
	end
	rule '.html' => detect_file do |t|
		sh "pandoc -s #{t.source} -o #{t.name}"
	end
	FileUtils.rm('blog.html', force: true)
	file 'blog.html' => articles.ext('.html') do |t|
		BlogGenerator.new(t).perform
	end

> 先看一下 detect_file方法，他是一个proc对象，目的是查找所有markdown格式文件，在排除扩展名的状态比较文件名，如果查找到了， 真实的markdown文件会被返回，最后
> 一个article.html=>article1.md任务将会定义，实际上这个任务不会被定义，刚才说的仅仅是一个依赖任务如何实现的例子，articl1.md文件存在时，rake如何工作的

#### Using a regular expression to match more tasks

>也可以传递一个正则表达式给rule模式， 下面例子
	
	rule /\.html$/ => '.md' do |t|
		sh "pandoc -s #{t.source} -o #{t.name}"
	end


> 上面代码我们使用了前面例子的方法，source，通过方法名字可知，它直接返回文件源的名字，在我们例子里，他是Markdown文件
