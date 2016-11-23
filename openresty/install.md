#### ubuntu 16.04 64bit 安装Lua luajit 及openresty

1 安装lua ,因为luajit 支持lua5.1较好.貌似不支持5.2和5.3作为学习,我就安装5.1

    sudo apt-get update
    sudo apt-get install lua5.1

2 安装luajit 这个默认Ubuntu仓库里是2.04,我自己手动下下载最新的测试版,有本书叫
<< openresty最佳实践 >>上说,beta版也很稳定.我也是为了学习了解,就安装测试版

  下载页面 http://luajit.org/download.html

  下载这个版本 LuaJIT-2.1.0-beta2

  然后默认编译安装就行

    make && sudo make install


  #### 注意最后终端会提示 你创建一个软里链接,你需要执行一下.我这里找不到那条语句了


3 安装openresty,也是下载编译安装,编译时候我使用下面的编译配置


        ./configure --prefix=/opt/openresty\
                    --with-luajit\
                    --with-http_iconv_module

  然后执行

      make
      sudo make install

  安装过程没有错误就行.

4 openresty的程序目录是/opt/openresty,最好加入到path里去


#### 注意 openresty默认自带了nginx,你不需要再安装nginx了

5 测试hello

   按照这个教程就行
    https://moonbingbing.gitbooks.io/openresty-best-practices/content/openresty/helloworld.html


#### 注意在启动的时候,你需要到/opt/openresty/nginx/sbin目录下,使用里面的nginx来启动应用

    sudo ./nginx -p ~/projects/openresty/openresty-test
