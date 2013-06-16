
# novelMiddleware = (req, res, next) ->
#   if req.url == '/healthchecks'
#     res.send 'success'
#     return
#   else if req.host == 'xiaoshuo.vicanso.com'
#     req.url = '/xiaoshuo' + req.url
#     req.originalUrl = req.url
#   next()

# config = 
#   getAppPath : () ->
#     return __dirname
#   isProductionMode : () ->
#     return process.env.NODE_ENV is 'production'
#   getStaticsHost : () ->
#     if @isProductionMode()
#       return 'http://s.vicanso.com'
#     else
#       return null
#   getMongoDbConfig : () ->
#     {
#       dbName : 'novel'
#       uri : 'mongodb://localhost:10020/novel'
#     }
#   getAppConfig : () ->
#     {
#       routeInfos : require './routes'
#       middleware : [novelMiddleware]
#     }
     
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

_sessionParser = null
sessionParser = (req, res, next) ->
  if !_sessionParser
    next()
  else
    _sessionParser res, res, next

config = 
  getAppPath : ->
    __dirname
  sessionParser : ->
    _sessionParser || sessionParser
  getStaticsHost : ->
    if @isProductionMode
      null
    else
      null
  isProductionMode : process.env.NODE_ENV == 'production'


  middleware : ->
    (req, res, next) ->
      if req.host == setting.host
        req.url = "/xs#{req.url}"
        req.originalUrl = req.url
      next()
  route : ->
    require './routes'
  session : ->
    key : 'vicanso'
    secret : 'jenny&tree'
    ttl : 30 * 60
    client : jtRedis.getClient 'vicanso'
    complete : (parser) ->
      _sessionParser = parser

module.exports = config
