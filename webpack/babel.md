
> 安装babel最新测试版

    npm install babel-loader@8.0.0-beta.0 @babel/core @babel/preset-env webpack --save-dev

> 如果你使用稳定版
    
    npm install babel-loader babel-core babel-preset-env webpack --save-dev

> 示例

    module.exports = {
      entry: {
        app: './app.js'
      },
      output: {
        filename: '[name].[hash:8].js'
      },
      module: {
        rules: [{
          test: /\.js$/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                ['@babel/preset-env', {
                  targets:{
                    browsers:['last 2 versions']
                  }
                }]
              ]
            }
          },
          exclude: '/node_modules/'
        }]
      }
    }

> babel是针对语法不针对api进行转换，针对api我们需要Babel polyfill和babel runtime transform

> polyfill 是针对全局替换，为开发应用准备 ,使用时安装稳定版 
    下面就支持最新的babel8.0
    npm i babel-polyfill -save
    npm i babel-runtime -save
    //使用时直接引入
    import "babel-polyfill"

> runtime transform 是局部替换，为框架准备，不会污染全局，在局部替换

    下面是安装稳定版
    npm i babel-plugin-transform-runtime -save-dev
    npm i babel-runtime -save

    配合最新babel8.0版我们需要安装最新的版本
    npm install @babel/runtime --save
    npm install @babel/plugin-transform-runtime --save-dev
    //使用时.babelrc中配置

    webpack.config.js

    module.exports = {
      entry: {
        app: './app.js'
      },
      output: {
        filename: '[name].[hash:8].js'
      },
      module: {
        rules: [{
          test: /\.js$/,
          use: {
            loader: 'babel-loader'
          },
          exclude: '/node_modules/'
        }]
      }
    }

    .babelrc

  {
      "presets": [
        ["@babel/preset-env", {
          "targets":{
            "browsers":["last 2 versions"]
          }
        }]
      ],
      "plugins":["@babel/transform-runtime"]
    }

> 实际开发中配置presets就可以，不需要配置插件，presets使用  presets: ['@babel/preset-env'],，也可以使用polyfill开发应用