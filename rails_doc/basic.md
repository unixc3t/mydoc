> 生成控制器时 控制器的开头字母大写

    $ bin/rails generate controller Welcome index
> 控制器复数根据语义,如下管理文章使用复数
  
    $ bin/rails generate controller Articles

> 生成的代码类名是复数

    class ArticlesController < ApplicationController
  
    end

> 创建模型开头字母大写，用的是单数
  
     bin/rails generate model Article title:string text:text

> 覆盖命名约定语法如下,这时就需要手动创建需要的my_products表,如果没有对应模型的表

    class Product < ApplicationRecord
      self.table_name = "my_products"
    end

> 还可以使用 ActiveRecord::Base.primary_key= 方法指定表的主键
> 如果没有对应列，手动添加 
    alter table 'products' add product_id int
    class Product < ApplicationRecord
      self.primary_key = "product_id"
    end

> 改变表结构和告知rails如何回滚表结构
> 1 运行 rake db:migrate 将name字段改为text类型，
> 2 运行 rake db:rollback 将字段name改回string

      class ChangeProductsName < ActiveRecord::Migration[5.1]
        def change
          reversible do |dir|
            change_table :products do |t|
              dir.up   { t.change :name, :text } # 将name字段更新为text
              dir.down { t.change :name, :string } #如果不喜欢，将name字段改回string类型
            end
          end
        end
      end

> 或者用分开的 up 和 down方法

    class ChangeProductsPrice < ActiveRecord::Migration[5.0]
      def up
        change_table :products do |t|
          t.change :price, :string
        end
      end
    
      def down
        change_table :products do |t|
          t.change :price, :integer
        end
      end
    end