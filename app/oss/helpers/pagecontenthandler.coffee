_ = require 'underscore'
async = require 'async'
JTOss = require 'jtoss'
ossClient = new JTOss 'Z8pQTAkCNNDAOPjt', 'z014NFAjKNLpvP07TSACKjNDgQDsqS'
pageContentHandler =
  index : (req, res, cbf) ->
    cbf null, {
      title : '测试'
    }
  buckets : (req, res, cbf) ->
    # buckets = [
    #   {
    #     name : 'jennytest'
    #     createdAt : '2013-06-01T12:28:35.000Z'
    #   }
    #   {
    #     name : 'vicanso1'
    #     createdAt : '2013-06-15T13:12:14.000Z'
    #   }
    #   {
    #     name : 'vicanso11'
    #     createdAt : '2013-06-15T13:12:31.000Z'
    #   }
    # ]
    # cbf null, buckets
    # return
    ossClient.listBuckets (err, buckets) ->
      if err
        cbf err
      else
        console.dir buckets
        cbf null, buckets 
  headObject : (req, res, cbf) ->
    bucket = req.param 'bucket'
    obj = req.param 'obj'
    if req.method == 'POST'
      headers = _.pick req.body, 'Content-Language Expires Cache-Control Content-Encoding Content-Disposition'.split ' '
      # console.dir headers
      # return 
      ossClient.updateObjectHeader bucket, obj, headers, cbf
    else

      # cbf null, {
      #   Connection : "close"
      #   'Content-Encoding' : "gzip"
      #   'Content-Length' : "16011"
      #   'Content-Type' : "text/plain"
      #   Date : "Wed, 19 Jun 2013 02:02:27 GMT"
      #   ETag : '"519328458B6A177B06752ECCE317D601"'
      #   'Last-Modified' : "Sat, 15 Jun 2013 13:39:25 GMT"
      #   server : "AliyunOSS"
      #   'x-oss-bucket-location' : "oss-hangzhou-a"
      #   'x-oss-request-id' : "51C11133D7F49A9F7B343B41"
      # }
      # return

      ossClient.headObject bucket, obj, (err, res) ->
        if err
          cbf err
        else
          cbf null, res
  headObjects : (req, res, cbf) ->
    bucket = req.param 'bucket'
    headers = req.body.headers || {}
    objs = req.body.objs
    # console.dir objs
    # cbf null, {}
    # return

    async.eachLimit objs, 10, (obj, cbf) ->
      console.dir obj
      ossClient.updateObjectHeader bucket, obj, headers, cbf
    , cbf
  bucket : (req, res, cbf) ->
  #   bucket = req.param 'bucket'
  #   return
  #   if !bucket
  #     err = new Error 'the bucket is null'
  #     cbf err
  #   else
  #     method = req.method
  #     if method == 'GET'
  #       prefix = req.param('prefix') || ''
  #       if prefix && prefix.charAt(0) == '/'
  #         prefix = prefix.substring 1
  #       next = req.param 'next'
  #       ossClient.listObjects bucket, {prefix : prefix, delimiter : '/', marker : next, 'max-keys' : 100}, (err, objs) ->
  #         if err
  #           cbf err
  #         else
  #           console.dir objs
  #           cbf null, objs
  #     else if method == 'DELETE'
  #       obj = req.param 'obj'
  #       ossClient.deleteObject bucket, obj, cbf
  objects : (req, res, cbf) ->
    bucket = req.param 'bucket'
    prefix = req.param('prefix') || ''
    marker = req.param 'marker'
    # cbf null, {
    #   total : 2
    #   next : (marker || 0) + 1
    #   items : [
    #     {
    #       name : '中文'
    #       _type : 'folder'
    #     }
    #     {
    #       name : '和尚塚.txt'
    #       lastModified : '2013-06-15T13:39:25.000Z'
    #       eTag : '"519328458B6A177B06752ECCE317D601"'
    #       type : 'Normal'
    #       size : '16011'
    #     }
    #     {
    #       name : '序章 七魔使降临！职业决斗者冰狩登场.txt'
    #       lastModified : '2013-06-15T13:43:01.000Z'
    #       eTag : '"24FD6DBEDE72B1227426038B1B2706B3"'
    #       type : 'Normal'
    #       size : '11889'
    #     }
    #   ]
    # }
    # return
    ossClient.listObjects bucket, {prefix : prefix, delimiter : '/', marker : marker, 'max-keys' : 1000}, (err, objs) ->
      if err
        cbf err
      else
        cbf null, objs
  deleteObject : (req, res, cbf) ->
    bucket = req.param 'bucket'
    obj = req.param 'obj'
    ossClient.deleteObject bucket, obj, cbf
  deleteObjects : (req, res, cbf) ->
    bucket = req.param 'bucket'
    data = req.body
    # currentPath = data.currentPath
    objs = data.objs
    if bucket && objs?.length
      xmlArr = ['<?xml version="1.0" encoding="UTF-8"?><Delete><Quiet>true</Quiet>']
      _.each objs, (obj) ->
        len = obj.length
        if obj.charAt(len - 1) == '/'
          obj = obj.substring 0, len - 1
        xmlArr.push "<Object><Key>#{obj}</Key></Object>"
      xmlArr.push '</Delete>'
      # cbf null
      # return
      ossClient.deleteObjects bucket, xmlArr.join(''), cbf
    else
      cbf null
  createBucket : (req, res, cbf) ->
    bucket = req.param 'bucket'
    if bucket
      ossClient.createBucket bucket, cbf
module.exports = pageContentHandler