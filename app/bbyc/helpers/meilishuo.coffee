config = require '../config'
appPath = config.getAppPath()
request = require 'request'
async = require 'async'
_ = require 'underscore'
zlib = require 'zlib'
tbApi = require "#{appPath}/helpers/taobao"
bbycClient = require('jtmongodb').getClient 'bbyc'

class MeiLiShuo
  constructor : ->
    @host = 'http://www.meilishuo.com'
  getHotItems : (options, cbf) ->
    if _.isFunction options
      cbf = options
      options = null
    hotPath = '/aj/getGoods/goods'
    options = _.extend {
      frame : 0
      page : 0
      view : 1
      word_name : 'hot'
      section : 'hot'
      price : 'all'
    }, options
    pages = _.range 0, 20
    async.eachLimit pages, 1, (page, cbf) =>
      console.dir "page:#{page}"
      async.waterfall [
        (cbf) ->
          bbycClient.find 'items', {}, {limit : 0}, 'id', (err, result) ->
            existIds = _.map result, (item) ->
              item.id.substring 3
            cbf null, existIds
        (existIds, cbf) =>
          @getOnePage options, (err, ids) ->
            if err
              cbf err
            else
              cbf null, _.difference ids, existIds
        (ids, cbf) =>
          idsList = []
          for i in [0...Math.ceil(ids.length / 10)]
            idsList.push ids.slice i, i + 10
          cbf null, idsList
        (idsList, cbf) =>
          async.eachLimit idsList, 1, (ids, cbf) ->
            tbApi.getItems ids, (err, data) ->
              if err
                cbf err
              else
                bbycClient.save 'items', data
                cbf null
          , cbf
      ], cbf
    , cbf

  getOnePage : (options, cbf) ->
    frames = _.range 8
    idsArr = []
    async.eachLimit frames, 1, (frame, cbf) =>
      options.frame = frame
      @_getOneFrame options, (err, ids) ->
        idsArr.push ids
        cbf err
    , (err) ->
      if err
        cbf err
      else
        cbf null, _.uniq _.compact _.flatten idsArr

    # getOneFrame = (options, cbf) =>
    #   params = _.map options, (value, key) ->
    #     "#{key}=#{value}"
    #   url = "#{@host}#{hotPath}?#{params.join('&')}"
    #   async.waterfall [
    #     (cbf) =>
    #       @_getData url, cbf
    #     (data, cbf) ->
    #       try
    #         data = GLOBAL.JSON.parse data
    #         cbf null, data
    #       catch err
    #         cbf err
    #     (data, cbf) =>
    #       urls = _.pluck data.tInfo, 'url'
    #       ids = []
    #       async.eachLimit urls, 10, (url, cbf) =>
    #         @_getItemId url, (err, id) ->
    #           if id
    #             ids.push id
    #           cbf null
    #       , () ->
    #         cbf null, ids
    #   ], cbf

    # getOneFrame options, (err, ids) ->
    #     console.dir ids

  _getOneFrame : (options, cbf) ->
    pathName = '/aj/getGoods/goods'
    options = _.extend {
      frame : 0
      page : 0
      view : 1
    }, options
    params = _.map options, (value, key) ->
      "#{key}=#{value}"
    url = "#{@host}#{pathName}?#{params.join('&')}"
    async.waterfall [
      (cbf) =>
        @_getData url, cbf
      (data, cbf) ->
        try
          data = GLOBAL.JSON.parse data
          cbf null, data
        catch err
          cbf err
      (data, cbf) =>
        urls = _.pluck data.tInfo, 'url'
        ids = []
        async.eachLimit urls, 10, (url, cbf) =>
          @_getItemId url, (err, id) ->
            if id
              ids.push id
            cbf err
        , (err) ->
          cbf err, ids
    ], cbf    

  _getItemId : (pathName, cbf) ->
    getId = (data, cbf) ->
      data = GLOBAL.decodeURIComponent data
      re = /id=([\s\S]*?)\&/
      result = data.match re
      if !result?[0] || !result?[1]
        cbf new Error 'can not find the go url'
      else
        cbf null, result[1]
    url = "#{@host}#{pathName}"
    async.waterfall [
      (cbf) =>
        @_getData url, cbf
      (data, cbf) =>
        re = /<div class=\"code_pic\"[\s\S]*?<a href=\"([\s\S]*?)\"/
        result = data.match re
        if !result?[0] || !result?[1]
          cbf new Error 'can not find the url of item'
        else
          @_getData result[1], {
            'Referer' : url
          },
          cbf
      (data, cbf) ->
        getId data, cbf
    ], cbf
        
  _getData : (url, headers, cbf) ->
    options = 
      url : GLOBAL.encodeURI url
      encoding : null
      timeout : 30000
      headers : 
        'Accept' : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        'Accept-Charset' : 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'
        'Accept-Encoding' : 'gzip,deflate'
        'Accept-Language' : 'en-US,en;q=0.8'
        'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_0) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.99 Safari/537.22'
    if _.isFunction headers
      cbf = headers
      headers = null
    _.extend options,headers, headers
    # console.dir url
    async.waterfall [
      (cbf) ->
        request options, cbf
      (res, body, cbf) ->
        headers = res.headers
        if headers['content-encoding'] == 'gzip'
          zlib.gunzip body, cbf
        else
          cbf null, body
      (data, cbf) ->
        cbf null, data.toString()
    ], cbf


module.exports = MeiLiShuo