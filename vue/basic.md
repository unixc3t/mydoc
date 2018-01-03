> 注册点击事件

    v-on:click="show"
    或
    @click="show"
    或
    @click="show(arg,$event)"

> 阻止事件冒泡

    @click.stop="show"
    或
    @click = show($event)
    function show(event) {
      event.cancelBulbble=true
    }

> 阻止默认形式

    @contextmenu= "show($event)"
    function show(event) {
      event.preventDefault();
    }

    或

    @contextmenu.prevent=show(); 

> jsonp

    this.$http.jsonp("url"),wd:"", jsonp:'默认callback'

> 防止数据闪烁

     v-cloak 
     {{}} = v-text
     {{{}}} = v-html

> vue实例方法

    vm.$el
    vm.$data
    vm.$mount
    vm.$options访问el,data同级属性
    vm.$log 查看数据状态

> ｖ-for遍历重复数据
    
      v-for="item in datas" track-by="$index"