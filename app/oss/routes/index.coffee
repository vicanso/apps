config = require '../config'
appPath = config.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"

routeInfos = [
  {
    route : '/oss'
    template : 'oss/index'
    handler : pageContentHandler.index
  }
  {
    route : '/oss/buckets'
    handler : pageContentHandler.buckets
  }
  {
    route : '/oss/headobject/:bucket'
    handler : pageContentHandler.headObject
  }
  {
    type : 'post'
    route : '/oss/headobject/:bucket'
    handler : pageContentHandler.headObject
  }
  {
    type : 'post'
    route : '/oss/headobjects/:bucket'
    handler : pageContentHandler.headObjects
  }
  {
    route : '/oss/objects/:bucket'
    handler : pageContentHandler.objects
  }
  {
    type : 'all'
    route : '/oss/bucket/:bucket'
    handler : pageContentHandler.bucket
  }
  {
    type : 'post'
    route : '/oss/deleteobjects/:bucket'
    handler : pageContentHandler.deleteObjects
  }
  {
    type : 'delete'
    route : '/oss/deleteobject/:bucket'
    handler : pageContentHandler.deleteObject
  }
  {
    route : '/oss/createbucket/:bucket'
    handler : pageContentHandler.createBucket
  }
  # {
  #   type : 'post'
  #   route : '/updateobjectheader/:bucket'
  #   handler : pageContentHandler.updateObjectHeader
  # }
]
module.exports = routeInfos