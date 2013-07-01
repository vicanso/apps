config = require '../config'
appPath = config.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"

routeInfos = [
  {
    route : ['/bbyc', '/bbyc/']
    template : 'bbyc/index'
    handler : pageContentHandler.index
  }
  {
    route : '/bbyc/mls'
    handler : pageContentHandler.mls
  }
]


module.exports = routeInfos