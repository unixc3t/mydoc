> 安装

    npm i typescript ts-loader --save-dev
    npm i typescript awesome-typescript-loader --save-dev

> 配置 tsconfig.json,

  {
    "compilerOptions": {
      "module": "commonjs", //模块标准
      "target": "es5", //编译兼容目标
      "allowJs": true //ts文件中允许使用js
    },
    "include": [
      "./src/*" //需要被编译的ts文件
    ],
    "exclude": [
      "./node_modules" //排除的目录
    ]
  }


> webpack.config.js

    module.exports = {
      entry: {
        app: './src/app.ts'
      },
      output: {
        filename: '[name].bundle.js'
      },
      module: {
        rules: [{
          test: /\.tsx?$/,
          use: {
            loader: 'ts-loader'
          },
          exclude: '/node_modules/'
        }]
      }
    }

> 可以直接使用lodash等库


> 声明文件

  npm install @types/lodash
  npm install @types/vue

> 全局安装使用typings 

    npm install typings
    下面是本地安装
    typing install loadsh