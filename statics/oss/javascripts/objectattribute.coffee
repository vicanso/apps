jQuery ($) ->
  window.OBJ_COLLECTION.on 'change:viewAttr', (model, value) ->
    if value
      ossPath = window.OSS_PATH
      bucket = ossPath.get 'bucket'
      path = ossPath.get 'path'
      name = model.get 'name'
      if path
        name = path + '/' + name
      new OSS.Model.ObjAttr({
        bucket : bucket
        name : name
      }).fetch {
        success : (model) ->
          new OSS.View.ObjAttr {
            model : model
          }
        error : ->
          console.dir 'obj attr fetch fail!'
      }