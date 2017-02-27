> [原文链接](http://www.virtuouscode.com/2014/04/21/rake-part-1-basics/)

> 我们有一个目录里面是markdown文件,我们想将这些文件使用pandoc工具转换成html，我们编写了一段脚本，一个一个的转换

	%W[ch1.md ch2.md ch3.md].each do |md_file|
		html_file = File.basename(md_file, ".md") + ".html"
		system("pandoc -o #{html_file} #{md_file}")
	end

> 但是这个脚本美的都重新生成html文件，即使源文件没有任何改变，如果markdown文件非常大，就很浪费时间
> 作为替代，我们编写一个Rakefile文件，并编写一个rake任务来生成html， 开头代码很类似前面的，便利输入的文件，然后确定对应的html文件
> 接下来就不同了，我们使用rake的file方法声明一个任务，这个任务依赖一个markdown文件， 代码块中，调用sh命令将markdown转换成html文件 

> 我们在这编写的是一条规则，或者实际上是三条规则，每一个都告诉rake如何从markdown生成html文件

	%W[ch1.md ch2.md ch3.md].each do |md_file|
		html_file = File.basename(md_file, ".md") + ".html"
		file html_file => md_file do
			sh "pandoc -o #{html_file} #{md_file}"
		end
	end

> rakefile文件本身可以使用，在命令行上，我们可以让rake去构建html文件。我们已经看到了比我们代码的优势，rake展示了代码执行
	
	$ rake ch1.html
	pandoc -o ch1.html ch1.md

> 如果我们让rake构建重复的任务，什么都不会发生，这是因为rake会检查文件修改时间，如果markdown文件修改了就会创建html
> 如果没修改就不会再次创建html文件

	$ rake ch1.html
	$

> 当文件需要重构时，rake跟踪变化，但是每次指定需要重构的文件很麻烦，我们希望简单的调用rake构建任何陈旧的文件

> 为了达到目的，我们加入一个html任务到我们的Rakefile文件，然后让这个任务依赖于三个html文件

	task :html => %W[ch1.html ch2.html ch3.html]

	%W[ch1.md ch2.md ch3.md].each do |md_file|
		html_file = File.basename(md_file, ".md") + ".html"
		file html_file => md_file do
			sh "pandoc -o #{html_file} #{md_file}"
		end
	end


> html任务没有任何代码，但是让我们让rake 构建html任务，然后接着运行依赖的html任务， rake知道如何运行
> 因为已经写好规则。

	$ rake html
	pandoc -o ch1.html ch1.md
	pandoc -o ch2.html ch2.md
	pandoc -o ch3.html ch3.md

> 如果我们修改了其中一个markdown文件，你会看到只会重新构建修改那个

	$ rake html
	pandoc -o ch2.html ch2.md
	
> 如果我们经常使用这个命令，我们可以通过使用:default任务依赖于我们的html任务，使命令更简单
	
	task :default => :html
	task :html => %W[ch1.html ch2.html ch3.html]

	%W[ch1.md ch2.md ch3.md].each do |md_file|
		html_file = File.basename(md_file, ".md") + ".html"
		file html_file => md_file do
			sh "pandoc -o #{html_file} #{md_file}"
		end
	end


> 这样我们就可以直接使用rake而不用携带参数
	
	$ rm *.html
	$ rake
	pandoc -o ch1.html ch1.md
	pandoc -o ch2.html ch2.md
	pandoc -o ch3.html ch3.md

>现在我们已经知道如何编写文件rules和任务了，让我们开始学习如何编写常规rules

> 我们的三个文件规则都有一个共同的模式，都是从一个.md文件转换到.html文件，事实上，这个模式如此重复，我们使用each循环自动生成这个规则
> 我们使用rake的特性代替显示编写循环，让他自己为自己工作

> 我们已文件扩展名.html声明一个规则， 这个规则依赖于.md扩展名文件 然后编写代码块，这个代码块允许接收一个参数，我们叫做t，这个t会绑定这个task对象
> 在代码块里面， 我们使用sh命令运行shell命令， 然后就是我们前面的pandoc命令，但是输出文件名我们使用任务的属性name， 输入文件我们使用任务的属性source

	task :default => :html
	task :html => %W[ch1.html ch2.html ch3.html]

	rule ".html" => ".md" do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

> 然后我们移除所有html文件，然后再次使用rake 我们看到和以前运行一样
	
	$ rm *.html
	$ rake
	pandoc -o ch1.html ch1.md
	pandoc -o ch2.html ch2.md
	pandoc -o ch3.html ch3.md

> 这发生了什么?因为我们没有指定参数，rake至此你够了:default任务，这个任务依赖于:html任务，:html任务依次依赖于三个html文件， rake开始执行第一个ch1.html
> 先看他是否存在，结果没有存在，然后尝试构建这个文件。

> 首先，查找有没有直接叫做ch1.html的规则，但是这没有， 然后找到我们新的规则， 然后使用这个规则可以从关联的md文件生成一个html文件， 将这个规则应用于ch1.html。
> 然后发现 ch1.md文件存在， 这意味着规则匹配，然后从头执行这个任务，然后重复整个过程。
