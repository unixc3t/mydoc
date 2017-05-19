### 插件编写

##### 全局插件
> 两个问题 1 插件的独立js文件。命名规则的确定，2 $符号被jquery.noConfilct之后如何使用

    $.say = function() {
      alert("hello world");
    }

    $(function() {
      $.say();
    })

> 解决1 jquery.项目名.功能.js 或 jquery.功能,项目名.js

> 解决2 使用闭包

    (function($) {
        $.say = function() {
          alert("hello world");
        }
    })(jQuery)

> 为插件确定参数,通过options选项解决,options使用json格式传递

    $.complex = function(p1,options,p2) {
      var settings = $.extend({v1:value},options||{})
    }

##### 基于包装集的插件

    $.fn.pluginName = function() {
      //这里面的this等于整个包装集,不用再使用$(this)封装
      this.each(functin(n){
        //但是这里面的this是html对象,所以要使用jquery函数需要$(this)

      })；
      return this;   // 注意基于包装集的函数，一定要支持链式结构 所以一定要返回this
    }

    //使用时
    $(xxx).pluginName()
