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
