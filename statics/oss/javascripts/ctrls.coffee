jQuery ($) ->
  Ctrls = Backbone.View.extend {
    events : 
      'click .nextPage' : 'clickNextPage'
      'click .prevPage' : 'clickPrevPage'
      'click .invertSelection' : 'clickInvertSelection'
      'click .attrGroup' : 'clickAttrGroup'
      'click .remove' : 'clickRemove'
    clickNextPage : ->
      window.OSS_PATH.nextPage()
    clickPrevPage : ->
      window.OSS_PATH.prevPage()
    clickInvertSelection : ->
      window.OBJ_COLLECTION.invertCheck()

    clickAttrGroup : ->
      resHeaders = [
        {
          name : 'Content-Language'
          tip : 'zh-CN'
        }
        {
          name : 'Expires'
          tip : 'Tue, 04 Jun 2013 02:45:23 GMT'
        }
        {
          name : 'Cache-Control'
          tip : 'max-age=300'
        }
        {
          name : 'Content-Encoding'
          tip : 'gzip'
        }
        {
          name : 'Content-Disposition'
          tip : 'attachment; filename=1359517123_33_937.gif'
        }
      ]
      MimeSetting.openDlg $('<div class="mimeSetting" />').appendTo('body'), resHeaders, (err, result) =>
        if !result
          return
        objs = @getCheckObjs true
        if objs.length
          $.ajax({
            url : "/headobjects/#{window.OSS_PATH.get('bucket')}"
            type : 'post'
            data : 
              headers : result.headers
              objs : objs
          }).success((res) ->

          ).error (res) ->
            console.dir 'headobjects fail!'
    getCheckObjs : (filterFolder) ->
      path = window.OSS_PATH.get 'path'
      bucket = window.OSS_PATH.get 'bucket'
      if path
        path += '/'
      objs = _.compact window.OBJ_COLLECTION.map (objModel) ->
        if objModel.get '_check'
          if !filterFolder
            path + objModel.get 'name'
          else if objModel.get('_type') != 'folder'
            path + objModel.get 'name'
        else
          ''
      objs
    clickRemove : ->
      userSelectCbf = (cbf) ->
        new JT.View.Alert {
          model : new JT.Model.Dialog {
            title : "确定要删除这些文件"
            content : '<p>删除该文件之后无法恢复，确定需要删除吗？</p>'
            btns : 
              '确定' : ->
                cbf null, true
              '取消' : ->
                cbf null, false
          }
        }
      getObjs = (comfirm, cbf) =>
        if comfirm
          objs = @getCheckObjs()
          cbf null, objs
        else
          cbf null
      async.waterfall [
        userSelectCbf
        getObjs
      ], (err, objs) =>
        if objs.length
          $.ajax({
            url : "/deleteobjects/#{window.OSS_PATH.get('bucket')}"
            type : 'post'
            data :
              objs : objs
          }).success((res) =>

          ).error (res) ->
            console.dir 'deleteobjects fail!'
    showPageBtn : (selector, hidden) ->
      pageBtn = @$el.find selector
      if hidden
        pageBtn.hide()
      else
        pageBtn.show()
    initialize : ->
      @listenTo window.OSS_PATH, 'change:firstPage', (model, value) =>
        @showPageBtn '.prevPage', value
      @listenTo window.OSS_PATH, 'change:lastPage', (model, value) =>
        @showPageBtn '.nextPage', value

  }

  new Ctrls {
    el : '#objectTableContainer .ctrlsContainer'
  }