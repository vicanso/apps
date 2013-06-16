_ = require 'underscore'


webConfig = 
  getHeader : (requestUrl) ->
    # urlPrefix = '/blog'
    # requestUrl = decodeURI(requestUrl).substring urlPrefix.length
    navData = [
      {
        url : '/'
        title : '首页'
      }
      {
        url : '/tag/node'
        title : 'node'
      }
      {
        url : '/tag/javascript'
        title : 'javascript'
      }
      {
        url : '/tag/others'
        title : 'others'
      }
      # {
      #   url : '/questions'
      #   title : '问题区'
      # }
      # {
      #   url : '/ask'
      #   title : '提问'
      # }
    ]
    
    urlPrefix = '/blog'
    urlList = _.map navData, (item) ->
      urlPrefix + item.url
    sortUrlList = _.sortBy urlList, (url) ->
      return -url.length
    baseUrl = ''
    console.dir requestUrl
    if requestUrl == "#{urlPrefix}/"
      baseUrl = requestUrl
    else
      _.each sortUrlList, (url, i) ->
        if !baseUrl && url != '/'
          if ~requestUrl.indexOf url
            baseUrl = url
    return {
      selectedIndex : _.indexOf urlList, baseUrl
      navData : navData
    }

module.exports = webConfig