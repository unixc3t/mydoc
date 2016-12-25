#### Using file tasks to work with files

>通常，你不得不将一种文件类型转换到另一种类型，例如，编译c或java源码到字节码文件,或者
>转换png文件到jpg文件，对于这种问题，rake有许多武器来解决
>假设我们有一个ruby项目，项目里有一个YAML格式的配置文件，以.yaml结尾，由于某种原因
>我们决定重命名这个文件，让它以.yml结尾，这个需求可能很常见也很重复，因此我们需要自动化这个过程
>我们可以手动更改
	
	$mv settings.yaml settings.yml

> Rake提供了一个特殊的task类型对着这种情况，file task
>使用file方法来定义一个file task，这个file task使用方式类似普通的task，它继承了所有普通的task行为， 
>在一个文件task里，我们可以设置依赖任务，编写action和描述，看下面使用file task如何重命名:
	
	file 'settings.yml' => 'settings.yaml' do
		mv 'settings.yaml', 'settings.yml'
	end

> 上面代码示例,我们定义settings.yml 文件task依赖于settings.yaml文件，如果settings.yaml文件不存在，这个file
>这个任务就会执行失败,下面是执行代码

	$ echo '' > settings.yml
	$ rake settings.yml
	mv settings.yaml settings.yml
	$ rake settings.yml
	rake aborted!
	Don't know how to build task 'settings.yml'
	Tasks: TOP => settings.yml
	(See full trace by running task with --trace)

>如你所看到的，settngs.yaml文件被修改成settings.yml并且，执行第二次的时候并没有成功，
>因为依赖的settings.yaml文件已经不存在了， 这个文件taskh和普通的rake任务一样

>除了拥有常规的task行为，文件task有一个非常有用的特性，如果source文件(依赖文件)没有改变，那么第二次
>尝试执行文件 task的action没有任何改变，文件task处理时间戳改变的source文件，如果没改变，file task不会
>执行

>下面是一个拷贝文件例子

	file 'settings.yml' => 'settings.yaml' do
		cp 'settings.yaml', 'settings.yml'
	end

> 创建一个空的settings.yaml文件，确保没有settings.yml文件存在于目录中，尝试运行几次这个文件task，
>看到rake并没有改变新生成的settings.yml文件的时间戳

	$ rake -f rakefile01 settings.yml
	cp settings.yaml settings.yml
	$ stat -f "%m%t%Sm %N" settings.yml
	1395252779
	Mar 19 21:12:59 2014 settings.yml
	$ rake -f rakefile01 settings.yml
	$ stat -f "%m%t%Sm %N" settings.yml
	1395252779
	Mar 19 21:12:59 2014 settings.yml

#### The characteristics of the file task dependencies

>我们使用pandoc转换markdown到html文件，如果没有安装pandoc
	
	sudo apt-get install pandoc
	
>下面是一个简单的 Rakefile文件实例
	
	    task :default => 'blog.html'
		file 'article1.html' => 'article1.md' do
			sh 'pandoc -s article1.md -o article1.html'
		end
		file 'article2.html' => 'article2.md' do
			sh 'pandoc -s article2.md -o article2.html'
		end
		file 'blog.html' => ['article1.html', 'article2.html'] do
			File.open('blog.html', 'w') do |f|
				html = <<-EOS
					                 <!DOCTYPE html>
									 <html>
										 <head>
											 <title>Rake essential</title>
										 </head>
										 <body>
											 <a href='article1.html'>Article 1</a> <br />
											 <a href='article2.html'>Article 2</a>
										 </body>
									 </html>
								 EOS
				f.write(html)
			end
		end

> 第一行我们定义了默认task，它链接到的任务会生成这个blog，下面两个任务用来生成html文章，最后一个任务
> book.html看起来很复杂，它基于两个文件任务，article.html和article2.html，意味着让运行这个blog.html task
>它会运行先运行这两个依赖的task,如果他们都完成了，然后这个blog.html task的代码才会运行，

> Rakefile里的代码有一些缺陷。如过我们想添加一篇新文章到blog里，我们不得不改变代码，最好是不改变
>Rakefile文件并且让rake自己找到所有文章， 下面是重构代码

	task :default => 'blog.html'

	articles = ['article1', 'article2']

	articles.each do |article|
		file "#{article}.html" => "#{article}.md" do
            sh "pandoc -s #{article}.md -o #{article}.html"
        end
	end

	 file 'blog.html' => articles.map { |a| "#{a}.html" } do
        File.open('blog.html', 'w') do |f|
            article_links = articles.map do |article|
                          <<-EOS
                            <a href='#{article}.html'>
                                Article #{article.match(/\d+$/)}
                           </a>
                          EOS
              end

            html = <<-EOS
                                <!DOCTYPE html> 
                                  <html>
                                    <head>
                                      <title>Rake essential</title>
                                  </head>
                                  <body>
                                      #{article_links.join('<br />')}
                                  </body>
                                </html>
                    EOS
          f.write(html)
      end
    end

>上面代码现在更通用，如果你写了新文章，你不需要修改太多的代码，但是你不得不添加一个没有扩展名文件
>到articles数组里，然而，这有一个问题，对于生成blog.html 文件， 即使你添加一个新的文件名到数组里，也不会生，
>因为关联的文件时间戳没有改变， 仅有的解决方案就是删除blog.html文件，在你每次运行rake时
>FileUtils.rm方法帮助我们解决这个问题,file 方法有一个很有用的特性可以用来重构blog.html任务，提供了一个可选参数
> task对象，这个对象包含了任务名称，关联task等等，让我们看下面示例代码。
	
	require_relative 'blog_generator'
	articles = ['article1', 'article2']
	task :default => 'blog.html'
	
	articles.each do |article|
		file "#{article}.html" => "#{article}.md" do
			sh "pandoc -s #{article}.md -o #{article}.html"
		end
	end

	FileUtils.rm('blog.html', force: true)
	file 'blog.html' => articles.map { |a| "#{a}.html" } do |t|
		BlogGenerator.new(t).perform
	end

> 现在看新代码，第一个变化就是 FileUtils.rm(blog.html, force: true),每次rake执行的时候，移除blog.html文件， 这个:force选项，告诉rm方法如果文件不存在
>不要抛出异常，我们可能会遇到这种情况，第一次运行或者我们自己删除了blog.html文件，第二个改变就是在定义blog.html任务时得到的t参数，t参数用来得到
>用来生成文件的任务名，和使用prerequisites方法得到依赖任务，它返回一组依赖任务名字的字符串

>深入 blog.html文件task的代码，它不需要任何额外的信息，这样允许我们简单的移动代码到一个单独的文件里，我们下一步重构，创建一个BlogGenerator类，
>他的初始化方法

>下面是 blog_generator.rb的代码

	class BlogGenerator
		def initialize(task)
			@task = task
		end
		
		article_links = @task.prerequisites.map do |article|
			                     <<-EOS
									 <a href='#{article}'>
										 Article #{article.match(/\d+/)}
									 </a>
								 EOS
							 end
							 
	    html = <<-EOS
	                    <!DOCTYPE html>
						<html>
						<head>
							<title>Rake essential</title>
						</head>
						<body>
							#{article_links.join('<br />')}
						</body>
						</html>
						EOS
	 File.write(@task.name, html)
    end

>下面是 Rakefile文件代码
	
	require_relative 'blog_generator'
	articles = ['article1', 'article2']
	task :default => 'blog.html'
		articles.each do |article|
			file "#{article}.html" => "#{article}.md" do
				sh "pandoc -s #{article}.md -o #{article}.html"
			end
		end
	FileUtils.rm('blog.html', force: true)
	file 'blog.html' => articles.map { |a| "#{a}.html" } do |t|
		BlogGenerator.new(t).perform
	end


>后面我们会学习rules，将我们的代码修改的更灵活

#### Creating a folder with the directory method

>有时你需要创建嵌套目录，你可以使用file task创建文件和目录，
>如果你需要创建目录树，你可以使用file task和依赖任务完成， 
> 下面就是一个例子

	file 'my_gem' do |t| mkdir t.name end
	file 'my_gem/tests" => ['my_gem'] do |t| mkdir t.name end
	file 'my_gem/tests/fixtures" => ['my_gem/tests/fixtures'] do |t|
		mkdir t.name
	end

>另一种方式是使用FileUtils#mkdir_p 方法，可以在task的action中和Rakefile上下面文里面使用
>但是这不是Rake的方式，这有一个专有方式定义folder task 使用directory方法，下面例子：

	directory 'my_gem/tests/fixtures'

>这个方法像FileUtils#mkdir_p的同义词，但是它定义的rake task可以被其他任务作为依赖

	directory 'my_gem/tests/fixtures'
	file 'README.md' => 'my_gem/tests/fixtures' do
		sh 'echo test > my_gem/tests/fixtures README.md'
	end

>当你执行README.md 任务的时候，为这个文件创建需要的目录 my_gem/tests/fixtures

>这个directory方法不允许接收任何参数，除了要创建的目录名，然而，如果你需要添加依赖任务或者
>actions给这个directory task， 你可以使用file方法 例子如下

	directory 'my_gem'
	file 'my_gem' => ['otherdata']
	file 'my_gem' do
		cp Dir['gem_template/**/*'], 'my_gem'
	end

#### Using Rake's file utilities

> Rake提供了很多有用的方法，帮助你处理rake files相关任务，如下
	
*	 The FileList module
*	 The FileUtils module
*	 The pathmap method

##### Using the FileList module functionality to collect the files

>这是在我们Rakefile文件里仅有的事情，需要摆脱掉，需要手动改变文章列表，幸运的是，rake提供了工具
>帮助我们解决这个问题， Rake::FileList ，它提供了灵活的方式来调整需要生成的文件列表， 选择性的
>过滤你需要的文件， 可以过滤临时文件，那些需要动态删除， 看下面实例

	require_relative 'blog_generator'
	
	articles = Rake::FileList.new('**/*.md', '**/*.markdown') do |files|
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

>我们看一下定义的文章列表，通过Rake::FileList创建，他初始化接收文件标记列表，我们得到素有
>.md和.markdown扩展名的文件，通过~*模式过滤一些文件(emacs临时文件),同时忽略了以temp开头文件
> 最后忽略了大小为0的文件，注意这个有用的方法.ext 用来构造文件名列表，如下

	$ irb -r rake --prompt=simple
	>> articles = Rake::FileList.new('**/*.md', '**/*.markdown')
	=> ["article1.md", "article2.md", "article3.md"]
	>> articles.ext
	=> ["article1", "article2", "article3"]
	>> articles.ext('.html')
	=> ["article1.html", "article2.html", "article3.html"]


>传递 -r rake 会自动引入需要的rake库给ruby的shell，使用 --prompt=simple 表示简化输出信息


##### Using pathmap to transform file lists

> 使用文件和目录列表工作时，我们经常不得不转换一组文件从一个类型到另一个类型，我们已经看到
> .ext方法的使用，在一些情况，这远远不够，Rake提供了更有意思的方法pathmap,
> 他可以被FileList对象上调用， 因为Rake扩展了String类， 允许接收2个参数，需要的说明和可选的
>代码块， #pathmap方法收集文件通过给定的说明，这个说明控制详细的映射细节，下面是合法的模式

* %p 完整文件名和目录
* %f 文件名包括扩展名，没有目录
* %n 只有文件名，没有扩展名
* %d 只收集目录
* %x 收集扩展名，如果是空字符表示没有扩展
* %X 除了扩展名，剩余其他都收集
* %s 收集分隔符
* %% 百分号标志

>下面演示了如何使用 #pathmap方法，示例文件列表如下
> file1.txt ,file2.pdf , sources/file3.txt , and bin/file4

	require 'rake'
	list = FileList['file1.txt', 'file2.pdf', 'sources/file3.txt', 'bin/file4']
	list.pathmap('%p')
	list.pathmap('%f')
	list.pathmap('%n')
	list.pathmap('%d')
	list.pathmap('%x')
	list.pathmap('%X')
	list.pathmap('%s')
	list.pathmap('%%')

> FileList对象不仅仅是用.new创建，也可以使用 .[]方法

	![](p1.png)
	![](p2.png)
	
