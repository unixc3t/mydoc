
    class D {
       fun bar() { ... }
    }

    class C {
        fun baz() { ... }

        fun D.foo() {
            bar()   // calls D.bar D是扩展接收者
            baz()   // calls C.baz 这里隐式的C叫做分发接收者
        }

        fun caller(d: D) {
            d.foo()   // call the extension function
        }
    }

> 声明为成员的扩展可以声明为open并在子类中覆盖。这意味着这些函数的分发	对于分发接
> 收者类型是虚拟的,但对于扩展接收者类型是静态的

    open	class	D	{
    }
    class	D1	:	D()	{
    }
    open	class	C	{
            open	fun	D.foo()	{
                    println("D.foo	in	C")
            }
            open	fun	D1.foo()	{
                    println("D1.foo	in	C")
            }
            fun	caller(d:	D)	{
                    d.foo()			//	调用扩展函数
            }
    }
    class	C1	:	C()	{
            override	fun	D.foo()	{
                    println("D.foo	in	C1")
            }
            override	fun	D1.foo()	{
                    println("D1.foo	in	C1")
            }
    }
    C().caller(D())			//	输出	"D.foo	in	C"
    C1().caller(D())		//	输出	"D.foo	in	C1"	——	分发接收者虚拟解析
    C().caller(D1())		//	输出	"D.foo	in	C"	——	扩展接收者静态解析

> 上文的 分发接收者的虚拟解析和扩展接收者静态解析怎么理解？

> 静态解析的理解,c1继承c中的caller方法，caller方法中的参数d是扩展接收者，这是个D类型，它不会因为你传入的是D1而改变成D1，因为定义的
> 时候，我们定义的就是D类型，这就是所谓的静态解析，

> 所谓动态解析就是，这个caller方法，调用所在类的D.foo，当在C中的时候，调用c中的 open fun D.foo()方法，而在c1的时候，调用c1中的
> override fun D.foo()方法

