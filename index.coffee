jtCluster = require 'jtcluster'
jtApp = require 'jtapp'
commander = require 'commander'
do (commander) ->
  splitArgs = (val) ->
    return val.split ','
  commander.version('0.0.1')
  .option('-p, --port <n>', 'listen port', parseInt)
  .option('-s, --slave <n>', 'slave total', parseInt)
  .option('-l, --launch <items>', 'the luanch app list, separated by ","', splitArgs)
  .parse process.argv

slaveHandler = ->
  setting = 
    express : 
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
    launch : commander.launch || 'all'
    favicon : ''
    apps : "#{__dirname}/app"
    port : commander.port || 10000
  jtApp.init setting, (err, app) ->
    if err
      console.dir err

if process.env.NODE_ENV == 'production'
  jtCluster.start {
    slaveTotal : commander.slave
    slaveHandler : slaveHandler
    error : (err) ->
      console.error err
  }
else
  slaveHandler()
