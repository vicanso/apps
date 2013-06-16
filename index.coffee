jtCluster = require 'jtcluster'
jtApp = require 'jtapp'

slaveHandler = ->
  setting = 
    express : 
      enable : ["trust proxy"]
      disabled : ["trust proxy"]
      set : 
        'view engine' : 'jade'
        views : "#{__dirname}/views"
    static : 
      path : "#{__dirname}/statics"
      urlPrefix : '/static'
      mergePath : "#{__dirname}/statics/temp"
      mergeUrlPrefix : 'temp'
      maxAge : 3000
      mergeList : [
        ['/common/javascripts/utils/underscore.min.js', '/common/javascripts/utils/async.min.js']
      ]
      mount : '/static'
    launch : ['blog', 'ys', 'novel']
    favicon : ''
    apps : "#{__dirname}/app"
    port : 10000
  jtApp.init setting, (err, app) ->
    if err
      console.dir err

if process.env.NODE_ENV == 'production'
  jtCluster.start {
    slaveHandler : slaveHandler
  }
else
  slaveHandler()
