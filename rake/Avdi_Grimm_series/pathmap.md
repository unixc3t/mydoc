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

> 为了转换我们的目录列表到命令行参数,告诉ruby将每个目录添加到加载路径里，我们在使用pathmap方法时，每个目录名字前面加上-I，