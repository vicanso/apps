config = require '../config'
appPath = config.getAppPath()
async = require 'async'
JTOss = require 'jtoss'
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"
sessionParser = config.sessionParser()
infoParser = (req, res, next) ->
  async.series [
    (cbf) ->
      sessionParser req, res, cbf
    (cbf) ->
      sess = req.session
      ossInfo = sess.ossInfo
      if ossInfo?.keyId && ossInfo.keySecret
        ossClient = new JTOss ossInfo.keyId, ossInfo.keySecret
        if sess.userMetas
          # console.dir sess.userMetas
          ossClient.userMetas sess.userMetas
        req.ossClient = ossClient
        next()
      else
        err = new Error 'is not login!'
        err.status = 401
        next err
  ]
  # sessionParser req, res, () ->



routeInfos = [
  {
    route : '/oss'
    template : 'oss/index'
    handler : pageContentHandler.index
  }
  {
    route : '/oss/buckets'
    middleware : [infoParser]
    handler : pageContentHandler.buckets
  }
  {
    route : '/oss/headobject/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.headObject
  }
  {
    type : 'post'
    route : '/oss/headobject/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.headObject
  }
  {
    type : 'post'
    route : '/oss/headobjects/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.headObjects
  }
  {
    route : '/oss/objects/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.objects
  }
  # {
  #   type : 'all'
  #   route : '/oss/bucket/:bucket'
  #   handler : pageContentHandler.bucket
  # }
  {
    type : 'post'
    route : '/oss/deleteobjects/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.deleteObjects
  }
  {
    type : 'delete'
    route : '/oss/deleteobject/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.deleteObject
  }
  {
    route : '/oss/createbucket/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.createBucket
  }
  {
    type : 'all'
    route : '/oss/upload'
    middleware : [infoParser]
    handler : pageContentHandler.upload
  }
  {
    type : 'post'
    route : '/oss/login'
    middleware : [sessionParser]
    handler : pageContentHandler.login
  }
  {
    type : ['post', 'get']
    route : '/oss/setting'
    middleware : [sessionParser]
    handler : pageContentHandler.setting
  }
  {
    route : '/oss/createfolder/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.createFolder
  }
  {
    route : '/oss/search/:bucket'
    middleware : [infoParser]
    handler : pageContentHandler.search
  }
  # {
  #   type : 'post'
  #   route : '/updateobjectheader/:bucket'
  #   handler : pageContentHandler.updateObjectHeader
  # }
]
module.exports = routeInfos