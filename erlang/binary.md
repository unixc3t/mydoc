
> 每个segment(区段)有下面语法:

    Value:Size/TypeSpecifierList

###### 默认值
> 就上面形式来说，一个segment默认类型type是integer，默认类型不是基于值的
>例如<<31.4>>也是整数，不是浮点

>Size大小默认基于类型，integer就是8，浮点是64，

> unti 对于integer, float, and bitstring 默认是 1. 对于 binary 默认是 8.

> 默认是无符号，默认是大字节序列


> Size和TypeSpecifierList都可以忽略,下面的形式都是允许的

    Value
    Value:Size
    Value/TypeSpecifierList




###### 下面说一下TypeSpecifierList和Size的理解

> value可以是用与组成二进制的任何表达式,用于二进制匹配,value必须是一个字面量或者变量

> segment的size部分乘以通过TypeSpecifierList的unit，就是分配给segment的总位数
>例如 一个整形4个字节，需要32个比特位，32就是总位数

>unit以unit:IntegerLiteral这样形式给予，就是说用的时候是 unit:1或unit:8
>unit取值范围是1-256 ,unit的大小制定了在没有size时二进制segments的对其方式
> integer,float,bitstring类型默认unit是1

> erlang中小端序列是<<72,0,0,0>>， 大端序列是<<0,0,0,72>>

> 下面表示,小字节序,有符号，整形，单位是8，我理解就是8位,整个元素总大小4*8 = 32 bits
    X:4/little-signed-integer-unit:8

>例如 <<25:4/unit:8>>把25编码成一个4字节整数，<<0,0,0,25>>每个数8位，


###### 示例

    <<N:8/unit:1>> = <<72>> 
    <<N:8/unit:1>>完整形式<<N:8/big-unsigned-integer-unit:1>>
> 上面示例，
>72转换成二进制1001000
>然后以分配总空间为8位(8乘以Unit的1) ，整形(integer),size为8 ，小字节序列(小端排序，低字节存放地有效字节)1个字节大小，其实大端小端没啥区别,将72的二进制形式以这些条件赋值给N,还是十进制72，可以<<"H">>表示，一个字符,72对应ASII码表H，N是72


    <<X1/unsigned>> = <<-44>>
    <<X1/unsigned>> 等价于 <<X1:8/big-unsigned-integer-unit:1>>
> -44的补码形式是11010100
> erlang以大端序列，无符号，整形，总空间是8位1个字节读取这个补码
> 结果是 212(128+64+16+4)