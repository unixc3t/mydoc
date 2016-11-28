##### 基础语法

 >C++语法要求main函数的定义以 int main()开头,可以使用下面变体更明确些

    int main(void) //在c中让括号空着表示对是否接受参数保持沉默,在c++中表示不接受参数

> 如果编译器认为main函数末尾没有返回语句,默认以 return 0;返回 但是这一点只适用于main函数不适用其他函数

> c++11初始化可以使用大括号.这种方式多数用于数组和结构,但是也可以用于变量,变量使用这种方式时可以使用等号或者不适用等号

    int umus{7};
    int rheas = {12};

>大括号内可以不包含任何东西,这种情况int型被初始化为零

	int rocs = {};
	int pysh{};

>wcha_t

>cin和cout不适合将输入输出看作是char流,因此不适合用来处理wchar_t类型, iostream头文件的最新版提供了作用相似的工具wcin和wcout 用于处理wchar_t流,另外可以用过L来指示宽字符常量和宽字符串,下面代码将字母P的wchar_t版本存储在变量的bob中,并显示但是tall的wchar_t版本

    wchar_t bob = L'P';
    wcout << L"tall"<< endl;


> char16_t和char32_t

>char16_t无符号 长16位,char32_t无符号长32位,使用前缀u表示char16_t,例如 u'C'和u"be good",使用U表示char32_t,例如U'R'和U"dirtyrat"

> 数组初始化规则

>只有在定义数组时才能初始化,此后就不能初始化了,也不能将一个数组赋给另一个数组 ,但是可以使用下标给数组元素赋值

    int cards[4] = {3,6,7,8}; //ok
	int hard[4]; //ok

	hand[4] ={3,4,5,6}; //not allowed
	hand = cards; //not allowed

>数组元素初始化0

	long totals[500] = {0}; //如果初始化为{1}不是{0},那么第一个元素被设置为1,其他都是0

>如果初始化数组时方括号[]里为空,c++编译器将计算元素个数

>c++ 11新增加初始化数组方式,可以省略=(等号)

    double earnings[4] {1.2,1.3,1.4,1.5}

>或者下面方式,不在大括号内包括任何东西,将把所有元素置为零

	 float blances[100] {}

>列表初始化禁止缩窄转换

	long p[] ={23,9.3} //浮点数转换为整数 禁止

> 常量字符串声明,应该确保数组足够大,能够储存所有字符,包括空字符(\0),使用常量字符串声明,让编译器计算长度比较安全
> > (千万不要忘记将空字符串计算在数组长度之内)

    char birds[11] = "Mr. Cheeps";
	char fish[] = "Bubbles";

> 字符串 
> 使用字符串的程序必须 #include <string>并且 使用 std::string来引用它
>  可以使用c-风格字符串来初始化string对象

    string str1; //创建一个空字符串对象
    string str2 = "panther"; //创建一个初始化的字符串

> c++11 字符串初始化
> c++11允许将列表初始化用于c-风格字符串和string对象

	char first_date[] = {"Le Chapon Dou"}
	char second_date[] = {"The Elegant Plate"}
	string third_date ={"The Bread Bow"}
	string fourth_date {"Hank's Fine Eats"}
	
> 不能将一个数组赋给另一个数组,可以将一个字符串赋给另一字符串
> 使用L,u,U来创建 char16_t,char32_t 字符串

	wchar_t title[]= L"Chief Astrongator"; //w_char string
	char16_t title2[]= u"Chief Astrongator"; //char16 string
	char32_t title3[]= U"Chief Astrongator"; //char32 string

> c++11还支持Unicode字符编码方案UTF-8,使用u8前传表示这种类型字符串
> c++11还新增另一种类型字符串,叫做原始(raw)字符串,字符表示自己,例如\n不表示换行,而表示两个常规字符--斜杠和n.
> 原始字符使用"(和)"来界定字符,并使用前缀R来标识字符串.

	cout<< R"(Jim "King" Tutt use "\n" instead of endl.)" << '\n'

> 上述代码将显示

	Jim "King" Tutt uses \n instead of endl
	
> 如果想在原始字符串中添加"(和)"时,就用 R"+*(和)+*"代替"(和)"

	cout<< R"+*( "(who wouldn't?)", she whispered. )+*" <<endl;

> 将显示如下

	"(Who wouldn't?)", she whispered.

> 自定义界定符,如上面的"+*( 就是一个自定义界定符的开始部分,
> 可以再默认界定符之间添加任意数量基本字符(+*就是添加的任意基本字符),但空格,左括号,右括号,斜杠和控制字符(如制表符和换行符号)除外
> 可以将R与 u,U配合使用 例如Ru,RU标识 宽字符
	
