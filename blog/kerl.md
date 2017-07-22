### 使用kerl安装erlang遇到的问题及解决办法，ubuntu平台 64bit

> 1 需要安装相关包

    1 sudo apt-get install build-essential git wget libssl-dev libreadline-dev libncurses5-dev zlib1g-dev m4 curl wx-common libwxgtk3.0-dev autoconf

> 2 出现下面错误

* documentation : 
* xsltproc is missing.
* fop is missing.
* xmllint is missing.
* The documentation can not be built.

> 解决

     sudo apt-get  install libxml2-utils  xsltproc fop

> 3 下面错误,

    odbc : ODBC library – link check failed

> 解决 

    sudo  apt-get install unixodbc unixodbc-bin unixodbc-dev

> 4 下面错误

    I encounter the similar fail,
    the following:
    make[2]: Entering directory `/root/software/otp_src_R15B02/lib/jinterface'
    === Entering application jinterface
    make[3]: Entering directory `/root/software/otp_src_R15B02/lib/jinterface/java_src'
    make[4]: Entering directory `/root/software/otp_src_R15B02/lib/jinterface/java_src/com/ericsson/otp/erlang'
    if [ ! -d "/root/software/otp_src_R15B02/lib/jinterface/priv/" ];then mkdir "/root/software/otp_src_R15B02/lib/jinterface/priv/"; fi
    /bin/sh: 1: jar: not found
    make[4]: *** [/root/software/otp_src_R15B02/lib/jinterface/priv/OtpErlang.jar] Error 127
    make[4]: Leaving directory `/root/software/otp_src_R15B02/lib/jinterface/java_src/com/ericsson/otp/erlang'
    make[3]: *** [opt] Error 2
    make[3]: Leaving directory `/root/software/otp_src_R15B02/lib/jinterface/java_src'
    make[2]: *** [opt] Error 2
    make[2]: Leaving directory `/root/software/otp_src_R15B02/lib/jinterface'
    make[1]: *** [opt] Error 2
    make[1]: Leaving directory `/root/software/otp_src_R15B02/lib'
    make: *** [tertiary_bootstrap_build] Error 2

> 解决: 配置Java环境变量 保证在控制台可以查看javac 和java