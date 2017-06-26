[原文](http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/)

> 虽然app和gems看起来都是分享依赖,但是他们之间有一些重要的不同, gem依赖于名称和版本号,不关心依赖来自于哪里,app需要控制部署,需要保证所有机器都使用完全相同的代码

> 当开发一个gem时，使用gemspec方法在你的Gemfile文件里，目的是避免重复,通常一个gem的Gemfile文件应该包含rubygems源地址和单独一行的gemspec， 不要将你的Gemfile.lock放到你的
>版本控制系统里，因为会强制控制gem命令执行时，安装不存在的gem版本，即使版本可以被强制控制
> 你也不想，因为这样会防止人们使用来自自己的依赖库,不同于开发时用的版本

> 当开发一个app是，要将你的Gemfile.lock放到版本库里,因为你将在不同的机器使用bundler工具
> 对于应用程序来说使用bundler控制gem版本一致是可以的



#### Ruby Libraries

> Ruby Libraries 同城被打包成gem格式，使用rubygems.org分发,一个gem包含了一组有用的信息
> 例如下面

* 一组元数据，名字，版本号，描述信息，简介，电子邮件
* 被打包的所有文件列表
* 一组gem的执行程序和位于gem中的位置
* 一组ruby应该加载到path的目录
* 一组ruby Libraies需要的依赖库

> 只有最后一个项目依赖项列表，与Gemfile的目的重叠，当一个gem列出一个依赖，它列出实际的名字和版本号范围, 重要的是它不关心依赖来自哪里,这使得在内部使用一个镜像或者hack一个依赖版本在你自己的系统上安装, 总之,rubygems依赖是一个符号名字,并不实际链接到一个在internet上能找到代码的实际位置

> 除了别的之外,这也是整个系统的特性

> 并且,gem作者选择一个他们可接收的范围内的依赖版本,必须在假设依赖版的版本的作者在依赖部署之前已经测试了可能的改变, 依赖关系的依赖性尤其如此

#### Ruby Applications

> 一个Ruby Application程序，例如一个rails程序,对一组测试过的第三方程序有着复杂的需求
> 当application的作者不关心哪个nokogiri版本被使用,在开发中关心的很多版本将会将会停留在生产
> 版本里，因为application作者控制部署环境，不像gem作者，他不需要担心第三方代码,因为他可以控制版本精度

> 结果,application作者想指定部署环境所使用的，精确的gem服务器，相比gem作者，application作者，更新换长期稳定而不是短期可靠

> application作者常常想要一种方式去修改社区里被分享的gem，例如仅仅是edge版本的gem，还没releas的gem,bunndler解决了这个问题，允许application作者覆盖一个制定的gem和版本，使用git仓库或者一个目录，因为gem作者有制定的gem的依赖，一个名字和版本范围，application开发者能够选择满足依赖，从其他的源，例如git

> 现在，application开发者必须能够要求 gem来自特定的源，正如你所看到的，在描述gem开发者(关注长期和稳定)和app开发者(关注所有代码必须有保证,包括第三方代码,在不同环境也要精确一致)有关键的不同，一个关注长期稳定适应性，


#### Rubygems and Bundler

> 这些rubygems libraries， cli 和 gemspec api 都是围绕 gem作者和rubygems 生态系统来构建， 实际上，gemspec是一个标准的格式用来描述所有信息，用来打包gem，然后被发布到rubygems.org ，并不存储哪里找到依赖的临时信息

> 另一方面，bundler是围绕app开发者构建的， 这个gemfile不包含元数据, 文件列表, 包暴露的执行文件, 或者应该加载的目录， 这些东西都是bundler范围之外， 关注的是方便的保障在不同机器有一样代码, 所以包含一组在哪里找到这些依赖的信息

#### Git "Gems"

> 基于上面描述原因,对于application 开发者去描述一个没有released的依赖的gem很有用， 当bundler 抓去了这个gem， 它使用在git仓库中找到的.gemspec文件，提取元数据，发现在开发中附加
> 的依赖的gem,这意味着，git gems能够无缝的被bundler使用， 因为他们的.gemspec允许他们被直接查看,像一个普通的gem，仅有的不同就是application开发者要告诉bundler去哪里找到gem

#### Gem Development

> 正在开发的gem遇到这两种情况，有两个原因

* 正在开发gem阶段,通常包含没有released，发送给rubygems.org的gem，所以指定gem所在地址找到依赖就十分重要，在开发期间


* 在gem开发期间，不能依赖rubygems去设置一个环境,相反,你需要一个混合换将，一个gem来自文件系统(当前gem在开发中)，一些gem或许来自gem(依赖的gem还没released)， 并且额外的gem来自传统的源，这种情况例如就是rails开发


> 因为在开发中的gem最红将会变成常规的gem，他们需要声明常规的元数据，被gem build使用， 这些
> 信息在.gemspec中声明，因为gemfile仅仅用来描述依赖声明

> 为了更简单的使用bundler在gem开发中， 不会重复的在.gemspec和gemfile中声明依赖，bundler有一个单独的指令，在你的gemfile中

    source "http://www.rubygems.org"

    gemspec  


> 这个gemspec指令告诉bundler，它可以去找到一个.gemspec文件，在gemfile旁边,让你运行bundle install是，bundler将会找到这个.gemspec并且将本地目录当做本地未打包的gem，他将
> 查找并且解析在.gemspec中的依赖列表， bundler运行时将会添加这些.gempec中列出的依赖到load
> path里，同样读取load path中的gem作为依赖，所以你使用bundler开发一个gem不会重复依赖


> 如果你发现，你开发需要依靠一个没有released的gem, 你可以自己添加gem地址，告诉bundler去哪里找到这个gem， 它将让俺使用.gemspec列出的依赖方案，但是它现在知道直接去哪找到开发期间依赖的gem

    source "http://www.rubygems.org"

    gemspec

    # if the .gemspec in this git repo doesn't match the version required by this
    # gem's .gemspec, bundler will print an error
    gem "rack", :git => "git://github.com/rack/rack.git"  

> 你不想在.gemspec中引入这个信息(指上面的git=>....信息)，最后在开发的gem 被发布后，这些被删除
> 这是的整个系统更灵活有弹性，不会基于临时的外部url， 这些信息纯粹用于设置开发环境在开发期间

> 这也是为什么我们推荐人们不要将Gemfile.lock文件放到gem开发环境的版本仓库中，这个文件被bundler激活
>保障所有依赖，包括依赖的依赖都要一致， 然而，当做某些gem开发时, ，您希望立即知道在整个生态系统中的一些变化是否破坏了您的设置。当你想坚持用一个gem的git location，你不想硬编码你的开发环境设置特殊的gem， 后来发现一个gem
> released版本，在你运行bunlder install 后发布的，与你的版本不兼容，代码不能运行



    It's not a way to guarantee that your code works on all versions that you specified in your .gemspec, but the incentive to lock down the exact versions of each gem simply doesn't exist when the users of your code will get it via gem install.


#### Update

> 你应该将Gemfile.lock在applications开发中check 而不是gem开发中