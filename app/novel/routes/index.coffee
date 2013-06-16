config = require '../config'
appPath = config.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"

staticsHost = config.getStaticsHost()

routeInfos = [
  {
    route : ['/xs', '/xs/page/:page', '/xs/type/:type', '/xs/type/:type/page/:page']
    template : 'novel/index'
    staticsHost : staticsHost
    handler : pageContentHandler.index
  }
  {
    route : '/xs/item/:id'
    template : 'novel/item'
    staticsHost : staticsHost
    handler : pageContentHandler.item
  }
  {
    route : '/xs/item/:id/page/:page'
    template : 'novel/itempage'
    staticsHost : staticsHost
    handler : pageContentHandler.itemPage
  }
  {
    route : '/xs/getnovel/:id'
    handler : pageContentHandler.getNovel
  }
]

module.exports = routeInfos