> 上一节，我们编写了Rakefile文件，使用它自动化构建html文件

	task :default => :html
	task :html => %W[ch1.html ch2.html ch3.html]

	rule ".html" => ".md" do |t|
		sh "pandoc -o #{t.name} #{t.source}"
	end

> 我们不想每次添加新文件就编辑这个Rakefile，我们希望这个rakeFile文件可以自动找到新文件并构建
> 为了有东西实验，我简单设置了一个项目，里面包含了4个markdown文件，一个附录文件在子目录里，
> 所有这些都要被编译成html文件，也包含了我们不想构建的文件， 这还有一个临时文件~ch1.md ,scratch目录下内容应该被忽略

	$ tree
	.
	├── ~ch1.md
	├── ch1.md
	├── ch2.md
	├── ch3.md
	├── ch4.markdown
	├── scratch
	│   └── test.md
	├── subdir
	│   └── appendix.md
	└── temp.md

> 这个项目在git版本控制下，如果我们让git列出已知文件，我们会看到前面那样的文件集，temp.md没有注册到git控制，通常也不需要，他应该在构建文件列表之外

	$ git ls-files
	ch1.md
	ch2.md
	ch3.md
	ch4.markdown
	scratch/test.md
	subdir/appendix.md
   	~ch1.md

> 为了可以自动的找到文件，我们使用rake file lists，让我们探究一下file lists是什么，和它能做什么
> 为了创建一个文件列表，我们使用下标操作符号在Rake::FileList上 ,传递一组字符串表示文件

	require 'rake'
	files = Rake::FileList["ch1.md", "ch2.md", "ch3.md"]
	files # => ["ch1.md", "ch2.md", "ch3.md"]

> 目前为止没什么兴奋的，我们刚刚开始， 代替单独文件组成的列表，我们可以传递一个glob模式。这里我们使用*.md

	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList["*.md"]
	files # => ["ch1.md", "temp.md", "ch3.md", "ch2.md", "~ch1.md"]

> 现在我们看到FileList的强大，但是这个file列表不是我们想要的， 也包含了我们不想构建的文件，丢失了一些我们想构建的
> 我们加入丢失的文件，使用*.markdown模式，

	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList["*.md", "*.markdown"]
	files # => ["ch1.md", "temp.md", "ch3.md", "ch2.md", "~ch1.md", "ch4.markdown"]

>但是我们仍然丢失了appendfix 文件， 为了修正这个，我们改变了glob模式， 去匹配任何目录下文件
	
	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList["**/*.md", "**/*.markdown"]
	puts files 

    # >> ch1.md
    # >> temp.md
    # >> ch3.md
    # >> ch2.md
    # >> scratch/test.md
    # >> ~ch1.md
    # >> subdir/appendix.md
    # >> ch4.markdown

> 我们找到了所有的文件和appendix文件，但是也加入了许多没用文件，  我们筛选出不需要的文件，我们使用exclusion模式

	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList["**/*.md", "**/*.markdown"]
	files.exclude("~*")
	puts files 

    # >> ch1.md
    # >> temp.md
    # >> ch3.md
    # >> ch2.md
    # >> scratch/test.md
    # >> subdir/appendix.md
    # >> ch4.markdown

> 我们忽略scratch目录，我们使用排除正则表达式替代shell glob

	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList["**/*.md", "**/*.markdown"]
	files.exclude("~*")
	files.exclude(/^scratch\//)
	puts files 

    # >> ch1.md
    # >> temp.md
    # >> ch3.md
    # >> ch2.md
    # >> subdir/appendix.md
    # >> ch4.markdown

> 我们仍然有temp.md存在，这个文件没有被git控制，我们希望使用一个排除规则，忽略没有被git控制的文件， 我们传递一个block给exclude方法， 在代码块中，使用一个咒语来决定是否git
> 知道这个文件
	
	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList["**/*.md", "**/*.markdown"]
	files.exclude("~*")
	files.exclude(/^scratch\//)
	files.exclude do |f|
		`git ls-files #{f}`.empty?
	end
	puts files 

    # >> ch1.md
    # >> ch3.md
    # >> ch2.md
    # >> subdir/appendix.md
    # >> ch4.markdown

> temp文件被过滤掉了，最后剩下我们关心的文件

> 下一步我们更新代码，让文件列表更完整， 我们将下标操作符变成FileList.new 传递一个代码块给构造函数， FileList根据代码块产生列表，将所有排除代码放在代码块里
	
	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
		fl.exclude("~*")
		fl.exclude(/^scratch\//)
		fl.exclude do |f|
		`git ls-files #{f}`.empty?
		end
	end
	puts files 

    # >> ch1.md
    # >> ch3.md
    # >> ch2.md
    # >> subdir/appendix.md
    # >> ch4.markdown

> 在我们回到Rakefile文件之前还需要做一个改变，在Rakefile里，我们需要一个被构建的文件列表，不是源文件，是与之对应的构建文件， 将输入文件转换成输出的文件，我们使用
> #ext方法，我们给它一个.html扩展名，返回一个新的文件列表，将原来的md文件扩展名替换成.html

	require 'rake'
	Dir.chdir "project"
	files = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
		fl.exclude("~*")
		fl.exclude(/^scratch\//)
		fl.exclude do |f|
			`git ls-files #{f}`.empty?
		end
	end
	puts files.ext(".html")

    # >> ch1.html
    # >> ch3.html
    # >> ch2.html
    # >> subdir/appendix.html
    # >> ch4.html

> 现在我们回到Rakefile文件，我们替换我们原来的硬编码文件列表，

>因为我们现在需要支持markdown文件的.md或.markdown扩展名， 我们不得不做一点改变告诉rake构建他们其中一种为Html,
> 现在我们就简单的重复一个rule.后面我们再改进
	
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

> 现在我们运行rake,编译所有文件到html
	
	$ rake
	pandoc -o ch1.html ch1.md
	pandoc -o ch2.html ch2.md
	pandoc -o ch3.html ch3.md
	pandoc -o subdir/appendix.html subdir/appendix.md
	pandoc -o ch4.html ch4.markdown
