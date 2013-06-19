jQuery ($) ->
  ossPath = window.OSS_PATH
  objCollection = new OSS.Collection.Obj
  
  new OSS.View.Obj {
    el : $ '#objectTableContainer .objectTableView'
    model : objCollection
    changePath : (folder) ->
      console.dir 'changePath'
      # self.changePath self.getAbsolutePath folder
    getAttr : (objName) ->
      console.dir 'getAttr'
      # self.getAttr self.getAbsolutePath objName
    delete : (objName) ->
      console.dir 'delete'
      # self.delete self.getAbsolutePath objName
  }

  window.OBJ_COLLECTION = objCollection

 
