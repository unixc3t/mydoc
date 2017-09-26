### 函数参数

> 函数定义多个参数时[]中不适用逗号分割，调用时不使用[]包裹
      (defn hello [n x] (println n) (println x))
      (hello 2 1 )

> 嵌套参数时，形式与函数声明一致，但是最外层不适用[]包裹

    (defn hello [a [b c]] (println a) (println b) (prinltln c))

    (hello 1 [2 3] )