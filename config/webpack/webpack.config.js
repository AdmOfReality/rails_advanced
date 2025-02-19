const { generateWebpackConfig } = require('shakapacker')
const webpack = require('webpack')

const webpackConfig = generateWebpackConfig()

webpackConfig.plugins.push(
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery'
  })
)

module.exports = webpackConfig
