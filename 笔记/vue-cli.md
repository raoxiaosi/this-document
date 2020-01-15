[toc]

### 安装nodejs

~~~shell
node -v
npm -v
~~~

### 安装 vue-cli

~~~shell
# 安装
npm install vue-cli -g --registry=https://registry.npm.taobao.org

# 查看是否安装成功
vue list

  ★  browserify - A full-featured Browserify + vueify setup with hot-reload, linting & unit testing.
  ★  browserify-simple - A simple Browserify + vueify setup for quick prototyping.
  ★  pwa - PWA template for vue-cli based on the webpack template
  ★  simple - The simplest possible Vue setup in a single HTML file
  ★  webpack - A full-featured Webpack + vue-loader setup with hot reload, linting, testing & css extraction.
  ★  webpack-simple - A simple Webpack + vue-loader setup for quick prototyping.
~~~

### 初始化项目

~~~shell
# 下载模板
vue init webpack project-name

# 全部为no，不自动安装
no

# 进入目录，手动安装依赖
npm install --registry=https://registry.npm.taobao.org
~~~

### 运行项目

~~~shell
npm run [环境]
~~~

