> 安装依赖
    npm install --save-dev @vue/test-utils mocha mocha-webpack
 
    npm install --save-dev jsdom jsdom-global webapck-node-externals
 
    npm install --save-dev expect
 
    npm install --save-dev nyc babel-plugin-istanbul
> 配置

    webpack.base.conf.js

    if (process.env.NODE_ENV === 'test') {
      module.exports.externals = [require('webpack-node-externals')()]
      module.exports.devtool='inline-cheap-module-source-map'
    }


    .babelrc.js

      "plugins": ["transform-vue-jsx", "transform-runtime", "istanbul"]


    test/steup.js
    
    require('jsdom-global')()
    global.expect = require('expect')