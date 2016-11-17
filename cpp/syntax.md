##### 基础语法

1. C++语法要求main函数的定义以 int main()开头,可以使用下面变体更明确些

		int main(void) //在c中让括号空着表示对是否接受参数保持沉默,在c++中表示不接受参数
		
2. 如果编译器认为main函数末尾没有返回语句,默认以 return 0;返回 但是这一点只适用于main函数不适用其他函数

3. c++11初始化可以使用大括号.这种方式多数用于数组和结构,但是也可以用于变量,变量使用这种方式时可以使用等号或者不适用等号

		int umus{7};
		int rheas = {12};

大括号内可以不包含任何东西,这种情况int型被初始化为零
	    
		int rocs = {};
		int pysh{};
		
4. wcha_t

  cin和cout不适合将输入输出看作是char流,因此不适合用来处理wchar_t类型, iostream头文件的最新版提供了作用相似的工具wcin和wcout 用于处理wchar_t流,另外可以用过L来指示宽字符常量和宽字符串,下面代码将字母P的wchar_t版本存储在变量的bob中,并显示但是tall的wchar_t版本
	  
		wchar_t bob = L'P';
		wcout << L"tall"<< endl;

5. char16_t和char32_t

char16_t无符号 长16位,char32_t无符号长32位,使用前缀u表示char16_t,例如 u'C'和u"be good",使用U表示char32_t,例如U'R'和U"dirtyrat"
