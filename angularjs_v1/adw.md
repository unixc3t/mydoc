> $apply仅仅是进入angular context，然后通过$digest去触发脏检查,$apply如果不给于参数
> 会检查$scope里的所有监听的属性，推荐给于参数

    //正常setInterval执行后，不会进行脏检查
    //我们将代码放在$apply内，对修改的变量每1秒后进行脏检查
    setInterval(function() {
      $scope.$apply(function() {
        //date赋值后就会去进行脏检查
        $scope.date = new Date();
      });
    },1000)

> 不建议直接调用$digest，应该使用$apply(),$eval为前期检查，
> 如果表达式不合法不会触发脏检查,将错误给$exceptionHandler，合法才触发digest

> digest在执行时，如果watch观察的value与上次执行时不一样，就会被触发

  $watch(watchFn,watchAction,deepWatch) 用来手动监听某些东西，变化后，触发某些动作
  watchFn:angular的表达式或函数的字符串
  watchAction:当watchFn监听的函数或者表达式发生变化就调用
  deepWatch，是否监听对象所有属性

eg:

    var firstcontroller =function($scope) {
        $scope.name='jack';
        $scope.count=0;
        $scope.data={
          name:'jack',
          count:20
        }

          $scope.$watch('name',function(newValue,oldValue){
        //当name变化，count增加
          ++$scope.count;
      })
    }
      


> 想监听整个data对象，而不是其中一个属性,第三个属性为true

      $scope.watch('data',function(){},true)

   

