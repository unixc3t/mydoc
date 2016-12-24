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





