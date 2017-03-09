> 下面是我们前面写的Rakefile文件，它找到项目里sources目录里的markdown文件，生成html文件在output目录里，
> 输出结构对应源目录

    SOURCE_FILES = Rake::FileList.new("sources/**/*.md", "sources/**/*.markdown") do |fl|
       fl.exclude("**/~*")
       fl.exclude(/^scratch\//)
       fl.exclude do |f|
         `git ls-files #{f}`.empty?
       end
    end

    task :default => :html
    task :html => SOURCE_FILES.pathmap("%{^sources/,outputs/}X.html")

    rule ".html" => ->(f){source_for_html(f)} do |t|
        sh "pandoc -o #{t.name} #{t.source}"
    end

    def source_for_html(html_file)
      SOURCE_FILES.detect{|f| f.ext('') == html_file.ext('')}
    end
  
> 我们在output目录里重新构建了输入文件的对应结构，我们需要确保output目录在生成html文件之前存在， 在Rake中有一个简单的方式
> 就是一个directory任务，除了目录外，这像是一个文件任务，但是与文件任务不同的是，我们不要提供任何代码确保目录存在，如果目录
> 不存在的话，我们给rake一个简单的暗示，如果需要就创建

> 我们添加这个目录到依赖列表里

    rule ".html" => [->(f){source_for_html(f)}, "outputs"] do |t|
      sh "pandoc -o #{t.name} #{t.source}"
    end

> 现在当我们运行rake时，在买个markdown文件编译成html前，确保目标目录存在

    $ rake
    mkdir -p outputs/backmatter
    pandoc -o outputs/backmatter/appendix.html sources/backmatter/appendix.md
    mkdir -p outputs
    pandoc -o outputs/ch1.html sources/ch1.md
    mkdir -p outputs
    pandoc -o outputs/ch2.html sources/ch2.md
    mkdir -p outputs
    pandoc -o outputs/ch3.html sources/ch3.md
    mkdir -p outputs
    pandoc -o outputs/ch4.html sources/ch4.markdown

> 通常当编写构建代码时，有一个简单方式快速的清理生成的文件，让我添加一个任务处理这个，替代在shell里运行， 使我们使用
> rake的一个帮助方法叫做rm_rf,对应的rm -rf命令　不需要警告和提示直接删除文件和目录

    task :clean do
      rm_rf "outputs"
    end

> rake有很多文件操作帮助方法,他们都以unix shell相同的命令命名，基于多种原因这样很方便，其中一点就是，因为他们都是ruby方法
> 我们可以直接传递文件和文件列表给方法，不需要字符串插值

> 这有一个对于rake免肝的quiet标记，我们可以运行rake命令的同时携带 -q标记，　rake将会做以前一样的工作，除了打印出输出信息
> 到stdout

    $ rake -q
    $

> 几乎所有的帮助方法都继承自FileUtils标准库，所以你想看哪些方法可以用可以到这里[链接](http://www.ruby-doc.org/stdlib-2.1.1/libdoc/fileutils/rdoc/FileUtils.html)