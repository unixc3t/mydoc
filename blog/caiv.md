## [翻译]Class and Instance Variables In Ruby

>[原文](http://www.railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/) 

>首先在开始前,我澄清一点，我们是ruby新手，新是相对于语法而言,我已经试着学习ruby一年，但是最近两个月才开始写rails程序。

>ruby是我学习的第一种语言，它不仅仅是涉及新的语法，还有一些新概念例如迭代器，注入，我最后遇到的一个概念就是类变量和类实例变量

>在过去，无论什么时候,有些东西很难在几分钟内掌握，我仅仅是记住它使用方法和他解决的问题，而不是它是什么，为什么这么做，
> 在过去的一周，我开始不这么做，强迫自己打开最喜欢的编辑器(textmate),弄清楚到底发生了什么


#### Class Variables

> 类变凉很简单,创建一个新类，在类级作用域级别，使用@@创建一个变量,然后添加一个getter方法，如下

    class Polygon
      @@sides = 10
      def self.sides
        @@sides
      end
    end

    puts Polygon.sides # => 10

> 类变量问题是可以继承 我们使用Triangle继承Polygon

    class Triangle < Polygon
      @@sides = 3
    end

    puts Triangle.sides # => 3
    puts Polygon.sides # => 3

> 什么？ polygon的side不是设置的10么？当你设置一个类变量，适用于所有的父类和子类

    最终证据:

    class Rectangle < Polygon
      @@sides = 4
    end

    puts Polygon.sides # => 4


#### Class Level Instance Variables

> ok，所以一个rubyist要做怎么做？让我们思考几秒，类是什么？是一个对象，对应可以有什么？对象可以拥有类和实例变量，这意味着一个类可以有实例变量。让我们重新打开polygon类并且添加一个实例变量

  class Polygon
    @sides = 10
  end


> 现在，你可以使用一个反射技术检查polygon的类和实例变量

    puts Polygon.class_variables # => @@sides
    puts Polygon.instance_variables # => @sides

> 有意思，让我们再尝试继承，从零开始，这次我们使用类级实例变量

    class Polygon
      attr_accessor :sides
      @sides = 10
    end

    puts Polygon.sides # => NoMethodError: undefined method ‘sides’ for Polygon:Class

> 为什么错了。我们创建了实例方法getter和setter,使用attr_accessor和并且设置了实例变量sides的值是10， 这个地方很狡猾，attr_accessor创建的getter和setter方法用于polygon的实例，而不是polygon类本身，尝试下面

    puts Polygon.new.sides # => nil

> 我们得到 nil,不是方法未定义，现在有道理了，嗯？我们创建的方法用是实例方法sides,那么我们怎样创建一个类级实例方法呢？

      class Polygon
        class << self; attr_accessor :sides end
        @sides = 8
      end

      puts Polygon.sides # => 8

> 这次加入side属性访问方法到类级而不是实例级作用域。留给我们的是类级实例变量，现在我们尝试继承

    class Triangle < Polygon
      @sides = 3
    end

    puts Triangle.sides # => 3
    puts Polygon.sides # => 8


> 现在每个类都有自己的sides，现在问题是如何设置默认值，有些人会认为是8，polygon的默认值

    class Octogon < Polygon; end
    puts Octogon.sides # => nil

> 但是猜错了，那么我们该怎么解决这个问题呢？好的，我们创建一个模块去做这个脏活，模块可以被引入任何类，达到功能复用目的

    module ClassLevelInheritableAttributes
      def self.included(base)
        base.extend(ClassMethods)    
      end
      
      module ClassMethods
        def inheritable_attributes(*args)
          @inheritable_attributes ||= [:inheritable_attributes]
          @inheritable_attributes += args
          args.each do |arg|
            class_eval %(
              class << self; attr_accessor :#{arg} end
            )
          end
          @inheritable_attributes
        end
        
        def inherited(subclass)
          @inheritable_attributes.each do |inheritable_attribute|
            instance_var = "@#{inheritable_attribute}"
            subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
          end
        end
      end
    end

> 当模块被引入到一个类中，添加了两个类方法，inheritable_attributes 方法和inherited方法，inherited方法工作方式和上面的 self.included 一样，无论何时一个类引入了这个模块并且有子类，它为每个已经声明的，从父类继承的实例变量，在其子类上设置一个类实例变量，如果你没理解，看下面

    class Polygon
      include ClassLevelInheritableAttributes
      inheritable_attributes :sides
      @sides = 8
    end

    puts Polygon.sides # => 8

    class Octogon < Polygon; end

    puts Polygon.sides # => 8
    puts Octogon.sides # => 8

> 叮，钱来了，我们甚至可以像下面这么做

    class Polygon
      include ClassLevelInheritableAttributes
      inheritable_attributes :sides, :coolness
      @sides    = 8
      @coolness = 'Very'
    end

    class Octogon < Polygon; end

    puts Octogon.coolness # => 'Very'