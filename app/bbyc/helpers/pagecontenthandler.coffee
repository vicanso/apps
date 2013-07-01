config = require '../config'
appPath = config.getAppPath()
_ = require 'underscore'
meiLiShuo = new (require "#{appPath}/helpers/meilishuo")
bbycClient = require('jtmongodb').getClient 'bbyc'
pageContentHandler = 
  index : (req, res, cbf) ->
    cutTitle = (title) ->
      len = 0
      index = 0
      for i in [0...title.length]
        index = i
        ch = title.charCodeAt i
        if ch > 0xff
          len += 2
        else
          len += 1
        if len > 26
          break
      if index == title.length - 1
        title
      else
        title.substring(0, index) + '...'
    bbycClient.find 'items', {delist : false}, {limit : 60}, (err, data) ->
      items = []
      columnTotal = 4
      items.push [] for i in [0...columnTotal]
      _.each data, (item, i) ->
        item.shortTitle = cutTitle item.title
        items[i % columnTotal].push item
      cbf null, {
        title : '百变衣橱'
        viewData :
          waterfallItems : items
      }
  mls : (req, res, cbf) ->
    meiLiShuo.getHotItems (err) ->
    # tbApi.core.call {
    #     method : 'get'
    #   }, {
    #     method : 'taobao.item.get'
    #     format : 'json'
    #     fields : 'detail_url, num_iid, title, props_name, cid, props, pic_url, delist_time, item_imgs, price'
    #     num_iid : 25859072964
    #   }, (data) ->
    #     console.dir data
    # async.waterfall [
    #   (cbf) ->
    #     meiLiShuo.getHotItems cbf
    #   (ids, cbf) ->
    #     tbApi.core.call {
    #       method : 'get'
    #     }, {
    #       method : 'taobao.item.get'
    #       format : 'json'
    #       fields : 'detail_url, num_iid, title, props_name, cid, props, pic_url, delist_time, item_imgs, price'
    #       num_iid : 25859072964
    #     }, (data) ->
    # ]


module.exports = pageContentHandler