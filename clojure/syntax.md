### 函数参数

> 函数定义多个参数时[]中不适用逗号分割，调用时不使用[]包裹
      (defn hello [n x] (println n) (println x))
      (hello 2 1 )

> 嵌套参数时，形式与函数声明一致，但是最外层不适用[]包裹

    (defn hello [a [b c]] (println a) (println b) (prinltln c))

    (hello 1 [2 3] )

> clojure中调用java语法

    (new class arguments)

    (new java.io.FIle "myfile.dat") : 返回一个java.io.File实例，传递字符串调用构造方法
    (. class filed) : 返回类的静态属性值
    (. java.lang.Math PI) :返回Java.lang.Math类的静态属性PI的值
    (. foo bar) : 返回实例foo的bar属性值
    (. (ack) bar) : 通过(ack)返回的实例，返回这个实例的bar属性
    (. class (method arguments))  : 调用静态方法
    (. instance (method arguments)):调用实例方法
    (. java.lang.Math (atan 5)): 通过参数5调用java.lang.Math的静态方法atan
    (. foo (bar)): 不适用参数调用实例foo的 bar方法
  
  >分配表达式的值给实例或者类属性

  (set! (. java.lang.Math PI) 3): 分配3给java.lang.Math类的静态属性PI
  (set! (.foo bar) 3) : 分配3给实例foo的属性bar


> 返回一个存储函数的向量

(loop [x 2 y []]
  (if (< x 5)
    (recur 
      (inc x)
      (conj y (fn [] (print x))))
      y
  )
 )