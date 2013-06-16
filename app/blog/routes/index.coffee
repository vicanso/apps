config = require '../config'
appPath = config.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"
staticsHost = config.getStaticsHost()

routeInfos = [
  {
    route : ['/blog', '/blog/tag/:tag']
    template : 'blog/index'
    staticsHost : staticsHost
    handler : pageContentHandler.index
  }
  {
    route : '/blog/article/:id'
    template : 'blog/article'
    staticsHost : staticsHost
    handler : pageContentHandler.article
  }
  {
    type : 'all'
    route : '/blog/userinfo'
    middleware : [config.sessionParser()]
    handler : pageContentHandler.userInfo
  }
  {
    route : '/blog/node'
    template : 'blog/node'
    staticsHost : staticsHost
    handler : pageContentHandler.node
  }
  {
    route : ['/blog/savearticle', '/blog/savearticle/:id']
    template : 'blog/savearticle'
    middleware : [config.sessionParser()]
    staticsHost : staticsHost
    handler : pageContentHandler.saveArticle
  }
  {
    route : '/blog/ask'
    template : 'blog/ask'
    staticsHost : staticsHost
    middleware : [config.sessionParser()]
    handler : pageContentHandler.ask
  }
  {
    route : '/blog/ask'
    type : 'post'
    middleware : [config.sessionParser()]
    handler : pageContentHandler.ask
  }
  {
    route : '/blog/questions'
    template : 'blog/questions'
    staticsHost : staticsHost
    handler : pageContentHandler.questions
  }
  {
    route : '/blog/question/:id'
    template : 'blog/question'
    staticsHost : staticsHost
    handler : pageContentHandler.question
  }
  {
    route : '/blog/question/:id'
    type : 'post'
    middleware : [config.sessionParser()]
    handler : pageContentHandler.question
  }
  {
    type : 'post'
    route : '/blog/statistics'
    handler : pageContentHandler.statistics
  }
  # {
  #   type : 'post'
  #   route : '/mergeajax'
  #   handler : pageContentHandler.mergeAjax
  # }
  # {
  #   route : '/ys'
  #   handler : (req, res) ->
  #     res.redirect 'http://ys.jennyou.com'
  # }
]
module.exports = routeInfos
