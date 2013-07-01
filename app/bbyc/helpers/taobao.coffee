TOP = require 'yi-top'
config = require '../config'
appPath = config.getAppPath()
_ = require 'underscore'
setting = require "#{appPath}/setting"

tbApi = new TOP {
  appkey : setting.taobao.appKey
  secret : setting.taobao.appSecret
}


taobao = 
  getItems : (ids, cbf) ->
    tbApi.api {
      method : 'taobao.items.list.get'
      format : 'json'
      fields : 'detail_url, num_iid, title, props_name, cid, props, pic_url, delist_time, item_imgs, price'
      num_iids : ids.join ','
    }, (err, data) ->
      items = _.map data.items_list_get_response.items.item, (item) ->
        newItem = {
          url : item.detail_url
          id : "tb_#{item.num_iid}"
          title : item.title
          propsName : item.props_name
          cid : item.cid
          props : item.props
          picUrl : item.pic_url
          delistTime : new Date item.delist_time
          delist : !new Date(item.delist_time).getTime() > Date.now()
          price : item.price
        }
        if !_.isEmpty item.item_imgs
          newItem.picUrls = item.item_imgs
        newItem
      cbf null, items



module.exports = taobao
