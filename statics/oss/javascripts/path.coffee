ossPath = new OSS.Model.Path
window.OSS_PATH = ossPath
jQuery ($) ->
  pathsObj = $('#objectTableContainer .paths').on 'click', '.path', ->
    obj = $ @
    if !obj.hasClass 'active'
      ossPath.set 'path', obj.attr 'data-path'
  setMarkers = (next) ->
    if !next
      ossPath.set 'lastPage', true
      return
    markers = ossPath.get('markers') || []
    if markers.length
      ossPath.set 'firstPage', false
    else
      ossPath.set 'firstPage', true
    markers.push next
    ossPath.set 'markers', markers
    ossPath.set 'lastPage', false
  setPaths = ->
    paths = _.compact ossPath.get('path').split '/'
    paths.unshift ossPath.get 'bucket'
    lastPath = paths.pop()
    dataPath = null
    pathHtmlArr = _.map paths, (currentPath, i) ->
      if dataPath == null
        dataPath = ''
      else
        dataPath += "#{currentPath}/"
      '<a href="javascript:;" class="path" data-path="' + dataPath + '">' + currentPath + '</a>'
    pathHtmlArr.push '<a href="javascript:;" class="path active">' + lastPath + '</a>'
    pathsObj.html "当前位置：#{pathHtmlArr.join('')}"

  ossPath.on 'change:path change:bucket', (model) ->
    model.set 'markers', ''
    model.trigger 'getdata', model
    setPaths()
    
  ossPath.on 'getdata', (model) ->
    model.fetch {
      success : (model, res) ->
        if res
          path = model.get 'path'
          bucket = model.get 'bucket'
          items = _.map res.items, (item) ->
            item.bucket = bucket
            item.path = path
            item.name = item.name.substring path.length
            if item.name
              item
          if path
            items.unshift {
              name : '../'
              lastModified : '-'
              back : true
              op : '-'
              _type : 'folder'
            }
          window.OBJ_COLLECTION.reset _.compact items
          setMarkers res.next
      error : ->
        console.dir 'oss path fetch fail!'
    }
  ossPath.listenTo window.OBJ_COLLECTION, 'change:active', (objModel, value) ->
    if value && objModel.get('_type') == 'folder'
      path = ossPath.get 'path'
      if objModel.get 'back'
        paths = _.compact path.split '/'
        paths.pop()
        if paths.length
          ossPath.set 'path', "#{paths.join('/')}/"
        else
          ossPath.set 'path', ''
      else
        if path
          path += "#{objModel.get('name')}"
        else
          path = objModel.get 'name'
        ossPath.set 'path', path
