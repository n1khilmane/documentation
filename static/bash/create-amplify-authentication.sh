#!/bin/bash
# from https://docs.amplify.aws/lib/project-setup/create-application/q/platform/js/
# TODO paramterize directory (or use TMP directory)
mkdir -p auth-test3/src && cd auth-test3
touch index.html src/app.js webpack.config.js


npm init
npm install aws-amplify
npm install webpack webpack-cli webpack-dev-server copy-webpack-plugin --save-dev

cat << EOF >> package.json
"scripts": {
    "start": "webpack && webpack-dev-server --mode development",
    "build": "webpack"
}
EOF

cat << EOF >> index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Amplify</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      html,
      body {
        font-family: 'Amazon Ember', 'Helvetica', 'sans-serif';
        margin: 0;
      }
      a {
        color: #ff9900;
      }
      h1 {
        font-weight: 300;
      }
      hr {
        height: 1px;
        background: lightgray;
        border: none;
      }
      .app {
        width: 100%;
      }
      .app-header {
        color: white;
        text-align: center;
        background: linear-gradient(30deg, #f90 55%, #ffc300);
        width: 100%;
        margin: 0 0 1em 0;
        padding: 3em 0 3em 0;
        box-shadow: 1px 2px 4px rgba(0, 0, 0, 0.3);
      }
      .app-body {
        width: 400px;
        margin: 0 auto;
        text-align: center;
      }
      .app-body button {
        background-color: #ff9900;
        font-size: 14px;
        color: white;
        text-transform: uppercase;
        padding: 1em;
        border: none;
      }
      .app-body button:hover {
        opacity: 0.8;
      }
    </style>
  </head>

  <body>
    <div class="app">
      <div class="app-header">
        <h1>Welcome to Amplify</h1>
      </div>
      <div class="app-body">
        <h1>Mutation Results</h1>
        <button id="MutationEventButton">Add data</button>
        <div id="MutationResult"></div>
        <hr />

        <h1>Query Results</h1>
        <div id="QueryResult"></div>
        <hr />

        <h1>Subscription Results</h1>
        <div id="SubscriptionResult"></div>
      </div>
    </div>
    <script src="main.bundle.js"></script>
  </body>
</html>
EOF

cat << EOF >> webpack.config.js
const CopyWebpackPlugin = require('copy-webpack-plugin');
const webpack = require('webpack');
const path = require('path');

module.exports = {
  mode: 'development',
  entry: './src/app.js',
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/
      }
    ]
  },
  devServer: {
    client: {
      overlay: true
    },
    hot: true,
    watchFiles: ['src/*', 'index.html']
  },
  plugins: [
    new CopyWebpackPlugin({
      patterns: ['index.html']
    }),
    new webpack.HotModuleReplacementPlugin()
  ]
};
EOF

##########
amplify init
## TODO Paramters
