> 安装需要的模块

    npm install asar --save-dev
    npm install electron-packager --save-dev

> 构建脚本

     "build": "electron-packager . appname"

##### 指定程序图标

> 注意，在Linux平台如果想使用自定义程序图标需要在建立browserwindow时指定

     let win = new BrowserWindow({
       width: 800, height: 600,
        icon: __dirname + '/ball.png' });

> 同时将图标拷贝到程序目录

      "build": "electron-packager . youtube && cp ball.png youtube-linux-x64/ball.png"


> 如果是mac平台，需要在build时指定

   "build": "electron-packager . youtube && cp ball.icns youtube-darwin-x64/youtube.app/Contents/Resources/electron.icns"

##### 解决打包后文件可以被随意修改

    //这里youtube-linux-x64是build后的目录
    “package”： “asar pack hello-linux-x64/resources/app youtube-linux-x64/resources/app.asar”

    npm run build
    npm run package
    然后删除 resources/app 目录

  package.json

  {
    "name": "electronlearn",
    "version": "1.0.0",
    "description": "",
    "main": "index.js",
    "scripts": {
      "start": "electron ./index.js",
      "package": "asar pack hello-linux-x64/resources/app hello-linux-x64/resources/app.asar",
      "build": "electron-packager . hello && cp ball.png hello-linux-x64/ball.png"

    },
    "author": "",
    "license": "ISC",
    "devDependencies": {
      "asar": "^0.14.3",
      "electron": "^1.8.4",
      "electron-packager": "^11.1.0"
    }
  }