> 如果我们没有使用Jbuilder,那么我们通过使用respond_to块来返回json

    def show
      @article = Article.find(params[:id])
      respond_to do |format|
        format.json { render json: @article }
      end
    end

> 结果如下

    {
    "id": 1,
    "name": "java",
    "content": "hello java content",
    "published_at": "2017-03-26T09:37:32.573Z",
    "author_id": 1,
    "created_at": "2017-03-26T09:37:32.573Z",
    "updated_at": "2017-03-26T09:37:32.573Z"
    }

> 返回的json,包含了文章的所有属性，但是如果我们想定制呢，我们在article上使用as_json，定制返回的属性, 假设我们想返回id,name,
> content，并且返回作者还有他的留言，其中留言也包含这三个属性

    def show
      @article = Article.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @article.as_json(only: [:id, :name, :content], include: [:author, {comments: {only:[:id, :name, :content]}}]) }
      end
    end

> 返回的结果

    {
      "id": 1,
      "name": "java",
      "content": "hello java content",
          "author": {
              "id": 1,
              "name": "jack",
              "created_at": "2017-03-26T09:19:56.590Z",
              "updated_at": "2017-03-26T09:19:56.590Z"
              },
          "comments": [
              {
                "id": 1,
                "name": "jack",
                "content": "comment1 content"
              },
              {
                "id": 2,
                "name": "peter",
                "content": "comment2 content"
              },
              {
                "id": 3,
                "name": "nika",
                "content": "comment3 content"
              }
          ]
    }

> 如果定制作者返回信息可以如下

    format.json { render json: @article.as_json(only: [:id, :name, :content], include: [{author: {only:[:id]}}, {comments: {only:[:id, :name, :content]}}]) }

> 上面工作正常，但是代码不是很漂亮，我们能够在model里重写as_json方法，但是这么做也不会更漂亮，这时我们使用jbuilder

#### 使用jbuider
> 在gemifle里声明，使用bundle install 安装

    # To use Jbuilder templates for JSON
    gem 'jbuilder'

> 我们在控制器里移除respond_to，回归到默认的行为，根据请求格式响应对应的模板

    def show
      @article = Article.find(params[:id])
    end

> 我们在 /app/views/articles目录里，我们创建一个json模板，在模板里，我们可以使用ruby代码定义json输出， 我们可以访问json对象
> 定义他的属性，像下面这样定义输出

    /app/views/articles/show.json.jbuilder
    json.id @article.id
    json.name @article.name

> 输出结果

  {
    "id": 1,
    "name": "java"
  }

> 每次需要自己手动写出每个属性可能有些麻烦，我们可以使用 extract!方法在json对象上调用， 同时传递给它一个对象，还有在这个对象上调用的> 方法或者属性列表

    /app/views/articles/show.json.jbuilder
    json.extract! @article, :id, :name, :published_at

> 还有另一种写法

    /app/views/articles/show.json.jbuilder
    json.(@article, :id, :name, :published_at)

> 这种方式好处是我们可以使用所有帮助方法在模板视图里

    /app/views/articles/show.json.jbuilder
    json.(@article, :id, :name, :published_at)
    json.edit_url edit_article_url(@article) if current_user.admin?

> 结果

    {
      "id": 1,
      "name": "java",
      "published_at": "2017-03-26T09:37:32.573Z",
      "edit_url": "http://localhost:3000/articles/1/edit"
    }

#### 嵌套

> Article belongs_to author, 一次性的显示author属性可以这样

    json.(@article, :id, :name, :published_at)
    json.edit_url edit_article_url(@article) if current_user.admin?

    json.author @article.author, :id, :name

> 输出结果

    {
      "id": 1,
      "name": "java",
      "published_at": "2017-03-26T09:37:32.573Z",
      "edit_url": "http://localhost:3000/articles/1/edit",
      "author": {
        "id": 1,
        "name": "jack"
       }
      }

> 如果我们想要更复杂的author属性列表，例如把url分配给author显示，可以传递一个block给author

    /app/views/articles/show.json.jbuilder
    json.(@article, :id, :name, :published_at)
    json.edit_url edit_article_url(@article) if current_user.admin?

    json.author do |json|
      json.(@article.author, :id, :name)
      json.url author_url(@article.author)
    end

> 输出结果

    {
      "id": 1,
      "name": "java",
      "published_at": "2017-03-26T09:37:32.573Z",
      "edit_url": "http://localhost:3000/articles/1/edit",
      "author": {
      "id": 1,
        "name": "jack",
        "url": "http://localhost:3000/authors/1"
      }
    }

> 如果是has_many关联， articles has many comments 我们也可以直接显示属性列表
  
    /app/views/articles/show.json.jbuilder
    json.(@article, :id, :name, :published_at)
    json.edit_url edit_article_url(@article) if current_user.admin?

    json.author do |json|
      json.(@article.author, :id, :name)
      json.url author_url(@article.author)
    end

    json.comments @article.comments, :id, :name, :content

> 输出结果

    {
      "id": 1,
      "name": "java",
      "published_at": "2017-03-26T09:37:32.573Z",
      "edit_url": "http://localhost:3000/articles/1/edit",
      "author": {
          "id": 1,
          "name": "jack",
          "url": "http://localhost:3000/authors/1"
      },
      "comments": [
          {
            "id": 1,
            "name": "jack",
            "content": "comment1 content"
          },
          {
            "id": 2,
            "name": "peter",
            "content": "comment2 content"
          },
          {
            "id": 3,
            "name": "nika",
            "content": "comment3 content"
          }
      ]
    }

> 如果我们需要使用block语法，我们需要迭代每个comment, 我们需要传递json和comment给block，

    json.comments @article.comments do |json, comment|
      json.(comment , :id, :name, :content)
    end

#### Partials

> 如果我们在comment块里有很多细节操作，又在很多地方重复使用，我们可以使用partial, 使用方式类似视图的模板的partials，
> 我们在json对象上调用partial!方法，传递一个partial路径或者一个对象 

    /app/views/articles/show.json.jbuilder
    json.comments @article.comments do |json, comment|
      json.partial! comment
    end

> 上面代码块中，寻找app/views/comments目录下的 _comment.json.jbuilder。在 partial里我们同样访问json对象，和comment块中
> 做一样的事情， 访问传递的comment对象， 

    /app/views/comments/_comment.json.jbuilder
    json.(comment, :id, :name, :content)