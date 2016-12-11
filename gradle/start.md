#### Command-line options

> -x 排除不想执行的任务名
> -i 改变任务打印日志界别为info
> -s 当出现任务错误时打印错误堆栈信息
> 使用的时候可以 gralde taskName -is 或者 gradle taskName -i -s
> -?, -h, --help 显示所有命令行选项和帮助信息
> -b, --build-file 如果构建叫本没有使用默认名称build时，使用-b指定 例如
> gradle -b test.gradle

> --offline 运行gradle构建在离线模式，仅仅检查本地仓库是否包含依赖需要的库

#### property option

>-D ,--system-prop gradle作为一个jvm进程，和所有的java进程一样，可以提供系统属性
>-Dmyprop=myvalue
>-P,--project-prop 项目属性作为变量，在你构建脚本里起作用，可以从命令行直接传递一个属性值给脚本


#### Logging options

>-i,--info 默认情况gradle不输出太多信息，使用这个选项得到更多信息
>-q,--quiet 减少构建时信息输出

#### help tasks

> tasks 显示出所有可运行的任务，包括依赖的任务
> properties 给出一组有效的属性，这个属性由gradle项目对象提供，

#### Gradle daemon

> 减少构建需要的时间，将gradle变成后台运行 使用时 命令行添加 --daemon 
> 查看是否生效,linux系统 ps | grep gradle
> 不使用daemon在命令行后面添加 -daemon
> 停止 daemon模式 gradle --stop
> gradle properties 显示出可以设置的选项和插件的属性，可以修改和扩展

#### MODIFYING PROJECT AND PLUGIN PROPERTIES

> 在build.grdle中添加自定义属性

	apply plugin: 'java'
	version = 0.1
	sourceCompatibility = 1.7

	jar {
		manifest {
			attributes 'Main-Class': 'com.manning.gia.todo.ToDoApp'
		}
	}
>修改项目代码位置

	sourceSets {
		main {
			java {
				srcDirs = ['src']
			}
		}
		test {
			java {
				srcDirs = ['test']
			}
		}
	}
	buildDir = 'out'

	
#### Configuring and using external dependencies

> 定义中央仓库

repositories {
	mavenCentral()
}

>声明依赖

dependencies {
	compile group: 'org.apache.commons', name: 'commons-lang3', version: '3.1'
}
