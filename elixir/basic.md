#### 列表创建

> 使用方括号，包含一组使用逗号分割的值

    [ "Humperdinck", "Buttercup", "Fezzik" ]
    [ "milk", "butter", [ "iocane", 12 ] ]

> 在同一次匹配中，变量只可以赋值一次，可以在新的匹配中重新赋值，如果想使用上一次存储的值，使用^

   a = 1 
   a = 2  此时a存储2

   a = 3 成立 但是使用 ^a = 3 就不成立，因为^a引用的是2