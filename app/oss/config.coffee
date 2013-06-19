setting = require './setting'
config = 
	getAppPath : ->
    __dirname


  firstMiddleware : ->
    (req, res, next) ->
      if req.host == setting.host
        req.url = "/oss#{req.url}"
        req.originalUrl = req.url
      next()
  route : ->
    require './routes'

module.exports = config