> 在前面的章节里，我们定义了一个任务用来清理我们脚本产生的文件，它通过简单的方式递归删除Outputs目录

    task :clean do
      rm_rf "outputs"
    end

> 有时清理不是那么简单，今天,我们以我们已经开发的，有了一些修改的Rakefile版本开始

> 在以前。我们转换markdown文件为html文件，不像前面的章节那样，这个html文件生成紧挨着他的源文件，而不是制定到输出目录

>除了构建markdwon为html的规则外，我们加入了一些新的规则，一个规则用来将所有html片段文件转换到一个单独的book.html文件
>然后这有一个规则将book.html转换成epub格式的ebook，使用来自Calibre电子书的ebook-covert命令,最后，这有一个规则将epub文件转换到
>兼容kindle的.mobi文件，使用kindlegen

> 最后的调整，我们更新:default规则，基于.epub和.mobi目标

    SOURCE_FILES = Rake::FileList.new("**/*.md", "**/*.markdown") do |fl|
        fl.exclude("~*")
        fl.exclude(/^scratch\//)
        fl.exclude do |f|
          `git ls-files #{f}`.empty?
        end
    end

    task :default => ["book.epub", "book.mobi"]
    task :html => SOURCE_FILES.ext(".html")

    rule ".html" => ->(f){source_for_html(f)} do |t|
      sh "pandoc -o #{t.name} #{t.source}"
    end

    file "book.html" => SOURCE_FILES.ext(".html") do |t|
        chapters   = FileList["**/ch*.html"]
        backmatter = FileList["backmatter/*.html"]
      sh "cat #{chapters} #{backmatter} > #{t.name}"
    end

    file "book.epub" => "book.html" do |t|
        sh "ebook-convert book.html #{t.name}"
    end

    file "book.mobi" => "book.epub" do |t|
        sh "kindlegen book.epub -o #{t.name}"
    end

    def source_for_html(html_file)
        SOURCE_FILES.detect{|f| f.ext('') == html_file.ext('')}
    end

> 构建脚本产生了２种不同的类型文件

* 生成中间类型文件，所有的html文件都是这种类型，这些文件的另一个名字是临时文件，因为一旦整个构建过程结束，他们就不被需要
* 也会生成最后需要的ebook文件，这些文件是整个过程的最终目标

> 当自动清理我们的项目目录时，我们想区别对待两种文件，有时我们想仅仅清理中间文件，有时我们想清理整个生成的文件
> 我们编写我们自己的任务处理这两种类型的清理工作，或者我们可以使用rake的 rake/clean库

> 使用rake/clean，我们首先需要require它，一旦我们引入后，一个新的全局常量叫做CLEAN就可以使用了，这个常量是FileList类型，默认是空的

    require 'rake/clean'

    CLEAN                           # => []
    CLEAN.class                     # => Rake::FileList

>我们使用CLEAN这个list告诉rake哪些是中间文件，首相，我们加入从markdown生成的html文件

    CLEAN.include(SOURCE_FILES.ext(".html"))

> 然后我们将book.html链接到这个列表

    file "book.html" => SOURCE_FILES.ext(".html") do |t|
      chapters   = FileList["**/ch*.html"]
      backmatter = FileList["backmatter/*.html"]
      sh "cat #{chapters} #{backmatter} > #{t.name}"
    end
    CLEAN.include("book.html")

> 下面，我们加入文件到另一个列表，这个列表叫做CLOBBER.这个列表告诉rake那些文件是最终产品文件，我们加入.epub和.mobi文件到CLOBBER列表里

    file "book.epub" => "book.html" do |t|
      sh "ebook-convert book.html #{t.name}"
    end
    CLOBBER << "book.epub"

    file "book.mobi" => "book.epub" do |t|
      sh "kindlegen book.epub -o #{t.name}"
    end
    CLOBBER << "book.mobi"

> 我们已经添加这些文件到CLEAN和CLOBBER列表在rakefile文件里的同样的地方，我们在每个构建规则下面添加这个文件，使我们在移除这个规则时，
> 我们会记得更新关联在CLEAN和CLOBBER列表里的文件

> 当我们在命令行上使用rake -AT命令遍历所有的rake任务

> 我们运行rake,但是没有使用任何命令参数，这样是构建我们的电子书文件，我们可以看到项目下的.html中间文件和最终的
> .epub和.mobi文件

    $ rake
    $ tree
    .
    ├── backmatter
    │   ├── appendix.html
    │   └── appendix.md
    ├── book.epub
    ├── book.html
    ├── book.mobi
    ├── ch1.html
    ├── ~ch1.md
    ├── ch1.md
    ├── ch2.html
    ├── ch2.md
    ├── ch3.html
    ├── ch3.md
    ├── ch4.html
    ├── ch4.markdown
    ├── Rakefile
    ├── scratch
    │   └── test.md
    └── temp.md
  
> 如果我们运行rake clean,我们没有看到任何输出，但是我们再次查看项目里的文件，.html文件已经不见了

    $ rake clean
    avdi@hazel:~/Dropbox/rubytapas/134-rake-clean/project
    $ tree
    .
    ├── backmatter
    │   └── appendix.md
    ├── book.epub
    ├── book.mobi
    ├── ~ch1.md
    ├── ch1.md
    ├── ch2.md
    ├── ch3.md
    ├── ch4.markdown
    ├── Rakefile
    ├── scratch
    │   └── test.md
    └── temp.md
  
> 如果我们运行rake clobber，我们会看到一组警告，不能找到的警告，因为clobber首先执行clean任务，我们已经运行过了
> 这个任务尝试移除已经移除的文件，不用担心，这样的告是我无害的，并且可以安全的忽略

> 当我们运行玩clobber后，再看项目里，电子书文件和中间文件已经都不见了

> 这就是rake/clean的全部了，我们不要编写我们自己的清理任务移除构建文件，我们仅仅需要添加合适的文件或者文件匹配模式到CLEAN
> 和CLOBBER列表里，让rake来做 