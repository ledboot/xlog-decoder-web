/**
 * @description 导出默认通用配置
 */
const setting = {
  //开发以及部署时的URL，hash模式时在不确定二级目录名称的情况下建议使用""代表相对路径或者"/二级目录/"，history模式默认使用"/"或者"/二级目录/"
  publicPath: '',
  //生产环境构建文件的目录名
  outputDir: 'dist',
  //放置生成的静态资源 (js、css、img、fonts) 的 (相对于 outputDir 的) 目录。
  assetsDir: 'static',
  //开发环境每次保存时是否输出为eslint编译警告
  lintOnSave: true,
  //进行编译的依赖
  transpileDependencies: ['vue-echarts', 'resize-detector'],
  //默认的接口地址 如果是开发环境和生产环境走vab-mock-server，当然你也可以选择自己配置成需要的接口地址
  baseURL:
    process.env.NODE_ENV === 'development'
      ? 'http://127.0.0.1:8080'
      : 'https://xlog.hellotalk8.com',
  //标题 （包括初次加载雪花屏的标题 页面的标题 浏览器的标题）
  title: 'xlog-decoder-web',
  //标题分隔符
  titleSeparator: ' - ',
  //标题是否反转 如果为false:"page - title"，如果为ture:"title - page"
  titleReverse: false,
  //开发环境端口号
  devPort: '9999',
  //版本号
  version: process.env.VUE_APP_VERSION,
  //缓存路由的最大数量
  keepAliveMaxNum: 99,
  //路由模式，可选值为 history 或 hash
  routerMode: 'hash',
  //token存储位置localStorage sessionStorage cookie
  storage: 'localStorage',
  //token失效回退到登录页时是否记录本次的路由
  recordRoute: true,
  //语言类型zh、en
  i18n: 'zh',
  //在哪些环境下显示高亮错误
  errorLog: ['development', 'production'],
  //需要自动注入并加载的模块
  providePlugin: {},
  //npm run build时是否自动生成7z压缩包
  build7z: false,
  //代码生成机生成在view下的文件夹名称
  templateFolder: 'project',
}
module.exports = setting
