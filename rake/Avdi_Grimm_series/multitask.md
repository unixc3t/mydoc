> rake系列教程接近尾声，我希望最后几个视频你会发现rake的强大就如我一样，但是你或许仍然怀疑使用rake相比传统ruby或者
> shell脚本的优势，如果你这么认为，今天我或许改变你的印象，我想展示你一个令人惊叹的能力。

> 假设我们要制作一本电子书,我们有剥离了文本的几百行代码准备使用pygmentize工具转换成高亮的html

> 这有一个rakeFile来处理这个任务，它定义了一个listings列表，一个highlight列表，这个列表里是最后产生的html
> 这还定义了一个highlight任务来处理所有工作。 最后定义了一个rule产生.html文件，通过在listing文件上调用pygmentize方法
> 我们也定义了默认任务依赖于highlight任务

    require "rake/clean"

    task :default => :highlight

    LISTINGS   = FileList["listings/*"]
    HIGHLIGHTS = LISTINGS.ext(".html")
    CLEAN.include(HIGHLIGHTS)

    task :highlight => HIGHLIGHTS

    rule ".html" => ->(f){ FileList[f.ext(".*")].first } do |t|
      sh "pygmentize -o #{t.name} #{t.source}"
    end

> Highlighting源码使用pygmentize处理需要时间，如果我们有很多源文件要处理，就需要大量时间， 如果我们使用time rake命令，
> 会告诉我们处理需要48秒

  $ time rake
  ...
  pygmentize -o listings/fd673484d50a66ea67fcd20e0c55f038a729e4d7.html listings/fd673484d50a66ea67fcd20e0c55f038a729e4d7.rb
  pygmentize -o listings/ff6e24090e794c4db847b10ca993c872ca804101.html listings/ff6e24090e794c4db847b10ca993c872ca804101.rb

  real    0m47.961s
  user    0m41.912s
  sys     0m4.852s

> 当前这些被高亮的文件在一时间处理一个，但是现在是2013年，我的电脑处理器有两个物理内核，通过超线程技术可以变成4个虚拟内核
> 为什么不能在一个时间点构建多个文件

> 事实是，我们可以，我们在rakefile文件上做一个改变，将task修改成multitask

    multitask :highlight => HIGHLIGHTS

> 这意味着，rake可以并行处理:highlight任务，注意，我们做出这个改变基于依赖的任务我们想并行处理它，而不是这个任务是并行的
> 我们再次运行，我们看到一些相当凌乱的输出，rake同时出发很多rake子线程出来，同一时间在标准输出打印出来

> 25秒多一点后，构建结束，改变后，我们几乎节省了一半时间

    $ time rake
    ...

    real    0m25.701s
    user    1m13.492s
    sys     0m8.272s

> 如果我们要调整多少个任务需要并行执行。我们使用-j选项，告诉rake一次使用多少个线程处理任务，我使用4每个虚拟内核处理1个

> 有趣的是，时间上稍微多了一点时间 我不知道为什么

    $ time rake -j 4

    real    0m26.752s
    user    1m10.300s
    sys     0m7.208s

> 前面我说过,将任务变成并行执行需要修改一行代码，这是个谎言，事实上，我们告诉rake以并行方式运行，而不改变代码，我们将
> multitask修改回task，我们在运行rake时加上-m选项，这告诉rake把每个rake当成好像是multitask对待

> rake的并行处理也十分智能，如果有其他任务依赖于hightlight任务，他讲仍然等到所有pygmentize处理完之后，再执行下一阶段
> 所以我们使用rake在自动化构建得到哪些好处？ 不仅仅是以简单的方式声明复杂的依赖和规则来完成任务，不仅仅是一套方便的文件操作方法
> 也不是一个方便的命令行工具，除此之外，我们免费得到了重复任务的并行执行的能力