## Syntax example

> 这有一个事例, 一个Slim模板像下面这样

    doctype html
    html
      head
        title Slim Examples
        meta name="keywords" content="template language"
        meta name="author" content=author
        link rel="icon" type="image/png" href=file_path("favicon.png")
        javascript:
          alert('Slim supports embedded javascript!')

      body
        h1 Markup examples

        #content
          p This example shows you how a basic Slim file looks.

        == yield

        - if items.any?
          table#items
            - for item in items
              tr
                td.name = item.name
                td.price = item.price
        - else
          p No items found. Please add some inventory.
            Thank you!

        div id="footer"
          == render 'footer'
          | Copyright &copy; #{@year} #{@author}

> 缩进是很重要,但是你可以自己选择喜欢的缩进深度.你想一次缩进2个 然后5个,是你的选择 ,嵌套你只需要缩进一个就可以

#### Line indicators 行指示器

##### Verbatim text |
> 这个| 管道 符号告诉 Slim仅仅拷贝这一行  ,本质上是避开所有处理,  比管道符号多缩进的每一行都被拷贝

    body
      p
        |
          This is a test of the text block.
> 上面的结果如下

    <body><p>This is a test of the text block.</p></body>

> 看下面例子

  body
  p
    | 
      This line is on the left margin.
      This is a test of the text block.
      This is a test of the text block.
      This is a test of the text block.
      This is a test of the text block.

> 被编译成
    <body><p>This is a test of the text block.
      This is a test of the text block.
      This is a test of the text block.
      This is a test of the text block.</p></body>

> 如果管道符号与文本在同一行 , 文本左边与管道符号有一个空格 . 后面任何额外的空格将被复制.

> 例子1 在一行,|管道符号后面有空格,ccck前面空格被保留
    body
      p
        |              ccck       aat         ch
          This is a test of the text block.
          This is a test of the text block.
          This is a test of the text block.

> 被编译成

    <body><p>             ccck       aat         ch
     This is a test of the text block.
     This is a test of the text block.
     This is a test of the text block.</p></body>

> 例子2 不在一行管道符号后面没有空格

    body
      p
        |
                  ccck       aat         ch
          This is a test of the text block.
          This is a test of the text block.
          This is a test of the text block.
> 被编译成

    <body><p>ccck       aat         ch
    This is a test of the text block.
    This is a test of the text block.
    This is a test of the text block.</p></body>

> 你也可以嵌入html文本内容
    - articles.each do |a|
      | <tr><td>#{a.name}</td><td>#{a.description}</td></tr>

##### Verbatim text with trailing white space '

> 这个单引号告诉Slim 拷贝这一行(类似 | 符号用法) 但是会自动插入空格,确保单引号后面有个空格

##### Inline html <

> 你可以编写html标记直接在Slim里 ,允许你使用闭合标签编写模板，以一个html风格或者混合Html 和silm的风格，这个 
> 开头的< 符号工作方式像| 管道符号

    <html>
      head
        title Example
      <body>
        - if articles.empty?
        - else
          table
            - articles.each do |a|
              <tr><td>#{a.name}</td><td>#{a.description}</td></tr>
      </body>
    </html>

##### Control code -

> 这个链接符号 - 表示控制代码, 控制代码,例如循环和条件判断  ,end符号禁止出现在-后面,块定义通过缩进形式
> 如果你的ruby代码块需要多行,行末尾加入一个反斜杠\,表示没有结束
> 若果你在行末尾加一个逗号，你不需要附加反斜杠

    body
      - if articles.empty?
        | No inventory

##### Output =

> 这个等号 告诉 Slim 这是一个 ruby代码调用, 产生输出到buffer里, 如果你的ruby代码需要使用多行 使用反斜杠在行尾 

    = javascript_include_tag \
      "jquery",
      "application"

如果你行尾使用逗号,就不需要在断行前添加一个反斜杠. 对于开头和结尾的空格 修改 >和< 来支持

输出使用结尾空白符 =>. 除了结尾添加一个空格　作用等同于单独的等号(=) ,

输出使用开头空白符 =<. 除了开头添加一个空格，作用等同于单独的等号(=)

> Output without HTML escaping ==
> 一般像这种单独等号,是不会经过 escape_html 方法. 语句的尾部和头部加空格通过添加 >和< 来支持

> 输出不会经过html转义 and 尾部加空格使用 ==>,除了尾部附加空格,作用和两个等号==一样
> 输出不会经过html转义 and 头部添加空格使用 ==<,除了头部添加空格,作用和两个等号==一样

##### Code comment /
> 使用向前斜杠 / 的代码注释 不会被渲染到最后的结果里, 使用/!的注释属于html注释会在最后渲染的文档里出现

    body
      p
        / This line won't get displayed.
          Neither does this line.
        /! This will get displayed as html comments.

    The parsed result of the above:

    <body><p><!--This will get displayed as html comments.--></p></body>

##### HTML comment /!

> 向前斜杠紧跟着惊叹号表示html注释


##### IE conditional comment /[...]

    /[if IE]
        p Get a better browser.

> 显示结果:

    <!--[if IE]><p>Get a better browser.</p><![endif]-->

## HTML tags

##### <!DOCTYPE> declaration

      XML VERSION

      doctype xml
        <?xml version="1.0" encoding="utf-8" ?>

      doctype xml ISO-8859-1
        <?xml version="1.0" encoding="iso-8859-1" ?>

      XHTML DOCTYPES

      doctype html
        <!DOCTYPE html>

      doctype 5
        <!DOCTYPE html>

      doctype 1.1
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
          "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

      doctype strict
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

      doctype frameset
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

      doctype mobile
        <!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN"
          "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">

      doctype basic
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN"
          "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">

      doctype transitional
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
      HTML 4 DOCTYPES

      doctype strict
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
          "http://www.w3.org/TR/html4/strict.dtd">

      doctype frameset
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
          "http://www.w3.org/TR/html4/frameset.dtd">

      doctype transitional
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
          "http://www.w3.org/TR/html4/loose.dtd">

##### Closed tags (trailing /)

> 你可以关闭标签直接在尾部附加 /

    img src="image.png"/

> 这个通常不需要自己添加 / ,标准的HTML标签会自动关闭

##### Trailing and leading whitespace (<, >)

> 通过a标签后加入一个 >， 你可以强制Slim添加一个尾部空格在一个标签后面

    a> href='url1' Link1
    a> href='url2' Link2

> 编译成

    a href="url1">Link1</a>这里有空格<a href="url2">Link2</a> 

    a href='url1' Link1
    a> href='url2' Link2

> 编译成

  <a href="url1">Link1</a><a href="url2">Link2</a>  两个a之间没空格

> 你也可以开头添加空格通过使用<

    a< href='url1' Link1
    a< href='url2' Link2

> 也可以两边都添加

  a<> href='url1' Link1

##### Inline tags

> 有时你或许想要更紧凑和内联标签
    ul
      li.first: a href="/a" A link
      li: a href="/b" B link

> 为了可读性,不要忘记你可以包装属性

    ul
      li.first: a[href="/a"] A link
      li: a[href="/b"] B link

##### Text content

> 文本内容与任意一标签在同一行 

    body
      h1 id="headline" Welcome to my site.

> 或者内嵌 你必须使用一哥管道符号 | 或者 单引号来转义处理

    body
      h1 id="headline"
        | Welcome to my site.

> 或者能够 激活 依靠文本缩进

    body
      h1 id="headline"
        Welcome to my site.

##### Dynamic content (= and ==)

> 调用可以与标签在同一行

    body
      h1 id="headline" = page_headline

> 或者嵌套

    body
      h1 id="headline"
        = page_headline

##### Attributes

> 可以在标前后直接写属性 对于普通的文本属性使用双引号或者单引号 

    a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage

> 你可以使用文本插入在引号里

##### Attributes wrapper

> 如果界定符号可以使得可读性更好,你能使用字符 {...}, (...), [...] 去包裹属性 你可以配置这些符号 看选项(:attr_list_delims)

    body
      h1(id="logo") = page_logo
      h2[id="tagline" class="small tagline"] = page_tagline

> 也可以放在多行

    h2[id="tagline"
      class="small tagline"] = page_tagline

>也可以使用空格

    h1 id = "logo" = page_logo
    h2 [ id = "tagline" ] = page_tagline

##### Quoted attributes

    Example:

    a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage

> 可以使用文本插入

    a href="http://#{url}" Goto the #{url}

> 属性值会被默认转义 ,如果你想关闭转义使用两个等号==

    a href=="&amp;" 这就不会转义原样输出

>可以使用反斜杠\ 来分割引号包裹的属性

    a data-title="help" data-content="extremely long help text that goes on\
      and one and one and then starts over...."

##### Ruby attributes

> 在等号=后面直接写ruby代码 . 如果代码包含空白间隔,你需要使用()包裹代码,你也可以直接编写hash{} 和数组[]

    body
      table
        - for user in users
          td id="user_#{user.id}" class=user.role
            a href=user_action(user, :edit) Edit #{user.name}
            a href=(path_to_user user) = user.name

>属性值会被默认转义 ,如果你想关闭转义使用两个等号==

    a href==action_path(:start) 这样就不会被转义

> 你也可以断开ruby属性 使用反斜杠\或者  trailing , 描述控制部分.

##### Boolean attributes

> 属性值是 true false nil被解释成 布尔值,如果你使用属性包裹,你可以忽略这些值的分配

    input type="text" disabled="disabled"
    input type="text" disabled=true
    input(type="text" disabled)

    input type="text"
    input type="text" disabled=false
    input type="text" disabled=nil

> Attribute merging

> 如果给定多个属性,你可以配置属性合并 (See option :merge_attrs) 在默认配置里,当使用空白符分割的时候 class属性会自动合并 

    a.menu class="highlight" href="http://slim-lang.com/" Slim-lang.com

> 被渲染成 

    <a class="menu highlight" href="http://slim-lang.com/">Slim-lang.com</a>

> 你也可以使用 一个数组形式的属性值,数组元素使用其限定符合并

    a class=["menu","highlight"]
    a class=:menu,:highlight

##### Splat attributes *

> 这个* 简写方式 允许你将一个hash变成 属性/值 对儿

    .card*{'data-url'=>place_path(place), 'data-id'=>place.id} = place.name

> This renders as:

    <div class="card" data-id="1234" data-url="/place/1234">Slim's house</div>

> 你可以使用方法或者实例变量 返回一个hash,返回的hash接上前面*符号

    .card *method_which_returns_hash = place.name
    .card *@hash_instance_variable = place.name

> 这个hash属性支持 属性合并  将给定的数组合并

    .first *{class: [:second, :third]} Text

> This renders as:

    div class="first second third"

##### Dynamic tags *

> 你可以创建一个动态标签 使用 *符号操作属性 仅仅是创建一个方法返回一个 使用:tag的hash

      ruby:
        def a_unless_current
          @page_current ? {tag: 'span'} : {tag: 'a', href: 'http://slim-lang.com/'}
        end
      - @page_current = true
      *a_unless_current Link
      - @page_current = false
      *a_unless_current Link
>解析结果:

      <span>Link</span>
      <a href="http://slim-lang.com/">Link</a>