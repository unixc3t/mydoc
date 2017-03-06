> 我们继续深入学习rake，我们接下来学习更强大的方法pathmap
> 这有我们前面章节使用的文件列表，这些文件是用来转换成html文件的markdown文件

    require "rake"
    Dir.chdir "project"
    SOURCE_FILES = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
        fl.exclude("~*")
        fl.exclude(/^scratch\//) 
        fl.exclude do |f|
          `git ls-files #{f}`.empty?
         end
    end

    SOURCE_FILES
    # => ["ch1.md", "ch3.md", "ch2.md", "subdir/appendix.md", "ch4.markdown"]

> 我们使用ext方法将输入文件的扩展名转换成目标文件，通过将markdown的扩展名转换成.html

     require './source_files'
     SOURCE_FILES.ext('html')
     # => ["ch1.html", "ch3.html", "ch2.html", "subdir/appendix.html", "ch4.html"]
  
> 当我们从事软件构建，软件打包，或系统管理任务时，我们经常通过一个文件列表生成另一个，将个一组文件的扩展名转换成另一种，只是问题之一。
> 当我们想做其他替代扩展名的任务时，我们需要使用rake的强大工具来修改文件名： pathmap

> pathmap方法的参数形式，一个字符传关联了含了原始文件不同部分

> %p 返回给我们原始的jiegou。
 
> %f 返回给我们文件名，不包含任何目录部分,例如 subdir/appendix.md变成ppendix.md

> %n 返回文件的基本名字，不包括扩展名和目录部分

> %d 返回给我们目录部分，没有文件名

> %x 只得到扩展名

> %X 返回所有，包括目录部分和文件名，但是没有扩展名

    require './source_files'
    SOURCE_FILES.ext('html')
    SOURCE_FILES.pathmap("%p")
    # => ["ch1.md", "ch3.md", "ch2.md", "subdir/appendix.md", "ch4.markdown"]
    SOURCE_FILES.pathmap("%f") 
    # => ["ch1.md", "ch3.md", "ch2.md", "appendix.md", "ch4.markdown"]
    SOURCE_FILES.pathmap("%n")
    # => ["ch1", "ch3", "ch2", "appendix", "ch4"]
    SOURCE_FILES.pathmap("%d")
    # => [".", ".", ".", "subdir", "."]
    SOURCE_FILES.pathmap("%x")
    # => [".md", ".md", ".md", ".md", ".markdown"]
    SOURCE_FILES.pathmap("%X")
    # => ["ch1", "ch3", "ch2", "subdir/appendix", "ch4"]

> 传递给pathmap方法的字符串不仅可以包含占位符号，我们也可以包含任意文本，假设我们想以附加ruby处理一个特殊的配置库加载开始。
> 我们有一个目录列表，我们想包含在读取的fileList里

> 为了转换我们的目录列表到命令行参数,告诉ruby将每个目录添加到加载路径里，我们在使用pathmap方法时，每个目录名字前面加上-I

> 当我们插入这个列表到我们的命令行字符串，我们得到列表中的每个目录前面有个I

    require "rake"
    load_paths = FileList["mylibs", "yourlibs", "sharedlibs"]
    ruby_args  = load_paths.pathmap("-I%p")
    command    = "ruby #{ruby_args} myscript.rb"
    # => "ruby -Imylibs -Iyourlibs -Isharedlibs myscript.rb"

> 这也展示了FileList的另一个特性，不同于数组，当转换成一个字符串，将使用空格分割列表元素

    load_paths.to_s                 # => "mylibs yourlibs sharedlibs"
    load_paths.to_a.to_s            # => "[\"mylibs\", \"yourlibs\", \"sharedlibs\"]"

> 我们可以使用pathmap方法做的另一件事就是文本替换，让我们回头看我们的markdown列表，假设我们将所有源makrdown文件移动到一个项目的子目录里，目录叫做sources
> 与其将所有的生成的html文件挨着源文件放置，我们想将他们放到一个指定的输出目录里，对应源文件目录结构


> 为了编译出列表中的html文件， 我们还是在pathmap方法中用吧%符号，但是我们插入一个大括号替代原来的单个字符，在大括号里面，我们制定了一个简单的正则表达式，用来
> 查找sources/开头的字符串，然后接着是一个逗号，接着是要替换它的字符串， outputs/，下一步我们需要告诉pathmap在什么地方可以替换，我们使用大写X，前面提到用来
> 返回一切除了扩展名， 最后我们加入html作为文件扩展名

    require "rake"
    Dir.chdir "project2"
    SOURCE_FILES = Rake::FileList.new("sources/**/*.md", "sources/**/*.markdown")

    SOURCE_FILES 
    # => ["sources/ch1.md", "sources/ch3.md", "sources/ch2.md", "sources/subdir/appendix.md", "sources/ch4.markdown"]

    OUTPUT_FILES = SOURCE_FILES.pathmap("%{^sources/,outputs/}X.html")
    OUTPUT_FILES
    # => ["outputs/ch1.html", "outputs/ch3.html", "outputs/ch2.html", "outputs/subdir/appendix.html", "outputs/ch4.html"]

> 当我们执行这个代码后，我们看到。我们得到一个使用outputs作为输出目录的文件列表， 注意这个appendix文件，对应了替换前的目录结构

> 我们仔细看一下代码，当我们尝试构建文件，我们可能会得到一个错误，即使我们已经创建了outputs目录， 我们或许可能没有创建subdir目录， 如果我们告诉pandoc去生成
> 这个文件， 可能会提示不能打开输出文件，因为目录不存在

> 我们可以使用mkdir -p令创建目录，但是我们需要给mkdir的仅仅是目录名，不包含文件名，对于这点，我们使用pathmap方法传递%d,告诉pathmap方法仅仅返回目录
> 注意我们在字符串上调用pathmap方法，而不是FileFlist上，类似前面看到的ext方法，rake将pathmap方法加入到String类中， 所以我们能够在文件列表和单个文件名字符
> 交替使用

    require "rake"
    Dir.chdir "project2"
    SOURCE_FILES = Rake::FileList.new("sources/**/*.md", "sources/**/*.markdown")
    OUTPUT_FILES = SOURCE_FILES.pathmap("%{^sources/,outputs/}X.html")

    f = OUTPUT_FILES[3]
    f                               # => "outputs/subdir/appendix.html"
    cmd = "mkdir -p #{f.pathmap('%d')}"
    cmd                             # => "mkdir -p outputs/subdir"</pre> </div>