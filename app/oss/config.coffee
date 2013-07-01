setting = require './setting'
jtRedis = require 'jtredis'
jtRedis.configure
  query : true
  redis : setting.redis

jtMongodb = require 'jtmongodb'
jtMongodb.set {
  queryTime : true
  valiate : true
  timeOut : 0
  mongodb : setting.mongodb
}

sessionParser = null

config = 
  getAppPath : ->
    __dirname
  sessionParser : ->
    sessionParser

  firstMiddleware : ->
    (req, res, next) ->
      if req.host == setting.host
        req.url = "/oss#{req.url}"
        req.originalUrl = req.url
      next()
  route : ->
    require './routes'
  session : ->
    key : 'vicanso_oss'
    secret : 'jenny&tree'
    ttl : 120 * 60
    client : jtRedis.getClient 'vicanso'
    complete : (parser) ->
      sessionParser = parser
module.exports = config