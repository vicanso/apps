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
        req.url = "/ys#{req.url}"
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

# _ = require 'underscore'

# setting = require './setting.json'

# init = ->
#   jtWeb = require 'jtweb'
#   appName = SETTING.appName
#   jtWeb.addInfoParser (req) ->
#     if req.host == SETTING.host
#       {
#         appName : appName
#       }
#     else
#       null
#   redisOptions =
#     ttl : 60 * 60
#   jtWeb.addSessionConfig appName, redisOptions, {
#     key : appName
#   }

# config = 
#   getAppPath : () ->
#     __dirname
#   isProductionMode : () ->
#     process.env.NODE_ENV == 'production'
#   getStaticsHost : () ->
#     if @isProductionMode()
#       'http://jennyou.com'
#     else
#       null
#   getMongoDbConfig : () ->
#     SETTING.mongoDb
#   init : init
#   getAppConfig : () ->
#     {
#       routeInfos : require './routes'
#     }
     
# module.exports = config