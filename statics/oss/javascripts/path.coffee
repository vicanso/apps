ossPath = new OSS.Model.Path
window.OSS_PATH = ossPath
jQuery ($) ->

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

  ossPath.on 'change:path change:bucket', (model) ->
    model.set 'markers', ''
    model.trigger 'getdata', model
    
  ossPath.on 'getdata', (model) ->
    model.fetch {
      success : (model, res) ->
        if res
          window.OBJ_COLLECTION.reset res.items
          setMarkers res.next
      error : ->
        console.dir 'oss path fetch fail!'
    }
  ossPath.listenTo window.OBJ_COLLECTION, 'change:active', (objModel, value) ->
    if value && objModel.get('_type') == 'folder'
      ossPath.set 'path', ossPath.get('path') + '/' + objModel.get 'name'

        # self.listenTo objCollection, 'change:active', (bucket, value) ->
        #   if value
        #     self.changePath self.getAbsolutePath bucket.get 'name'