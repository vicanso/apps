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


sessionParser = (req, res, next) ->
  next()

config = 
  getAppPath : ->
    __dirname
  sessionParser : ->
    sessionParser
  getStaticsHost : ->
    if @isProductionMode
      null
    else
      null
  isProductionMode : process.env.NODE_ENV == 'production'


  route : ->
    require './routes'
  session : ->
    key : 'vicanso'
    secret : 'jenny&tree'
    ttl : 30 * 60
    client : jtRedis.getClient 'vicanso'
    complete : (parser) ->
      sessionParser = parser

module.exports = config