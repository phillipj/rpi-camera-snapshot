const path = require('path')

module.exports = {
  entry: './frontend/index.js',
  output: {
    filename: 'compiled.min.js',
    path: path.resolve(__dirname, 'public/build')
  },
  module: {
    loaders: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack-loader'
    }]
  },
  devServer: {
    publicPath: '/build/',
    contentBase: path.join(__dirname, 'public'),
    compress: true,
    proxy: {
      '/api': 'http://localhost:3000'
    }
  }
}
