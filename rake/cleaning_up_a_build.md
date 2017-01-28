> 有时，你可能需要使用rake任务删除生成的文件，回到构建时的初始状态,或许你想删除构建产生的临时文件或者移除最终文件，确保
> 编译环境赶紧可靠，我们可以学习一下rake内建机制帮助我们做到这一点， 

#### Setting up a project

> 推荐你通过实践来了解git-scirbe这个工具，到git-scirbe主页安装这个工具，然后使用下面命令生成骨架
	
	$git scribe init <directory-name>

>生成的模板足够这本书生成任何格式使用， 当然这个工具也可以生成html,pdf等，也可以通过模板生成一个网站，
>让我们使用rake为这个工具写一个包装集，首先创建一个task用来生成你的目标格式，使用git-scribe gen 命令
>git-scribe gen pdf命令太长， 将它变短 rake pdf,另一个是清理生成的临时文件

	1 生成电子书项目
	$git scribe init the-book
	2 进入项目目录
	$cd the-book
	3 确保没有任何输出
	4 运行下面命令生成pdf格式
	$git scribe gen pdf

> 上面的命令，创建了一个输出目录，里面有很多文件
> 从控制台输出目录来看，有很多我们不感兴趣的文件生成，他们是临时文件。我们不得不手动删除他们，标准的rake任务帮助我们清理
> 我们稍后会编写Rakefile解决这个问题，
> 我们开始使用包装器生成这本书可能的格式html,pdf,mobi epub

	FORMATS = [:pdf, :html, :mobi, :epub]
	FORMATS.each do |f|
		desc "Generate the book in '#{f}'"
		task f do |t|
			sh "git-scribe gen #{t.name}"
		end
	end

#### The cleaning tasks

> 现在，我们需要引入一些条件，帮助我们编写clean任务， 我们使用下面代码引入cleaner
	
	require 'rake/clean'

> 同时，定义了2个常量 CLEAN和CLOBBER和两个任务，clean 和blobber

> CLEAN： 列表中的文件将会被清理，clean任务通过这个列表清除文件
> CLOBBER： 生成文件列表，这些文件通过rake任务生成，通常是最后生成的文件， clobber任务通过这个列表移除他们，这个任务的依赖任务是clean

	require 'rake/clean'
	FORMATS = [:pdf, :html, :mobi, :epub]
	FORMATS.each do |f|
		desc "Generate the book in '#{f}'"
		task f do |t|
			sh "git-scribe gen #{t.name}"
		end
	end

	CLOBBER.include("output/*.#{f}")
	CLEAN.include('output/*.asc')
	CLEAN.include('output/*.fo')
	CLEAN.include('output/*.xml')
	CLEAN.include('output/stylesheets/')
	CLEAN.include('output/include/')	
	
	CLOBBER.include('output/image/')	
	
> 执行下面命令，看你的控制台
	$ rake pdf
	
> 通过控制台，看到生成的不仅仅是pdf文件，还有其他文件，通过clobber任务来移除，使用下面代码
	
	$rake clobber
	$ ls -ln output

> clobber依赖于clean任务，clean被调用，清理删除文件，除了image目录，这个目录被html文件格式需要。我们应该在clobber任务里删除，
> clobber完整删除整个output目录里的内容，clobber任务执行完之后，整个output目录被删除 
