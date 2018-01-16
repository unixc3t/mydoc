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

> vue 实例方法

    vm.$el
    vm.$data
    vm.$mount
    vm.$options访问el,data同级属性
    vm.$log 查看数据状态

> ｖ-for 遍历重复数据

      v-for="item in datas" track-by="$index"

## 组件

###### 全局组件

    var Aaa = Vue.extend({
      template: '<h3>我是标题</h3>'
    });

    Vue.component('aaa',Aaa)


    htmlcode:
    <aaa></aaa>  

    or

    var Aaa = Vue.extend('aaa',{
      template: '<h3>我是标题</h3>'
    });

###### 局部组件

      var vm = new Vue({
        el: '#box',
        data:{
          bSign:true
        },
        components:{
          'aaa':Aaa
        }
      });

      or


      var vm = new Vue({
        el: '#box',
        data:{
          bSign:true
        },
        components:{
          'aaa':{
            data:() {
              return {
                msg:'welcome me'
              }
            },
            template:'<h2>{{ msg  }}</h2>'
          }
        }
      });

> 单独编写模板

      <template id = "aa">
            <ul>
                <li></li>
            </ul>
      </template>



      var vm = new Vue({
        el: '#box',
        data:{
          bSign:true
        },
        components:{
          'aaa':{
            data:() {
              return {
                msg:'welcome me'
              }
            },
            template:'#aa'
          }
        }
      });

> 动态组件

      <component :is = "aaa"></component>

      var vm = new Vue({
        el: '#box',
        data:{
          bSign:true
        },
        components:{
          'aaa':{
            data:() {
              return {
                msg:'welcome me'
              }
            },
            template:'<h2>{{ msg  }}</h2>'
          }
        }
      });

父子组件使用时，子组件用在父组件的 template 代码中

传递数据使用

      prop:['msg']
      或
      prop:{
          key:type //'msg':String
      }

## vue2.0 改变

> 定义组件简洁方式

    //全局
     var Home = {
        data(){},
        methods:{}
        template:{}
     }

     Vue.component("name",Home)

     //局部

       new Vue({
         el:"",
         data:{

         },
         component:{
           "aaa":Home
         }
       })

> 生命周期的改变

    * beforeCreate 组件实例刚刚被创建，属性没有
    * created 实例已经创建完成，属性已经绑定
    * beforeMount 末班编译之前
    * mounted　模板编译完成，　ready 时机 变成 mounted
    * beforeUpdate　 组件数据更新之前
    * updated　组件数据更新之后
    * beforeDestroy　组件销毁之前
    * destroyed 组件销毁之后

> 默认 for 循环可以添加重复数据

    ｖ-for ="x in list"
     v-for ="(val, index) in list" :key=index

     track-by=id 变成 ：key=index

> 按键定义时间

    Vue.config.keyCodes.ctrl=17

> 过滤器，全部删除

> 自定义过滤器

     Vue.filter('tuDou',function(input){
       ...
     })

     但是，

     1.0: {{ msg | toDou '1','2'}}
     2.0: {{ msg | toDou('1','2') }}

     Vue.filter('tuDou',function(msg,a,b){
       ...
     })
