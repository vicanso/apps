jQuery ($) ->
  App = Backbone.View.extend {
    events : 
      'click .paths .path' : 'clickPath'
      'click .op.refreshBucket' : 'initBucketsView'
      'click #objectTableContainer .ctrlsContainer .nextPage' : 'clickNextPage'
      'click #objectTableContainer .ctrlsContainer .prevPage' : 'clickPrevPage'
      'click #objectTableContainer .ctrlsContainer .invertSelection' : 'clickInvertSelection'
      'click #objectTableContainer .ctrlsContainer .attrGroup' : 'clickAttrGroup'
      'click #objectTableContainer .ctrlsContainer .remove' : 'clickRemove'
      'click #bucketListContainer .opContainer .createBucket' : 'clickCreateBucket'
      'click #bucketListContainer .opContainer .setting' : 'clickSetting'
    resize : ->
      height = $(window).height()
      $('#objectTableContainer .objectTableView .content').height height - 110
      $('#bucketListContainer .buckets').height height - $('#bucketListContainer .opContainer').outerHeight() - 30
    clickNextPage : ->
      @refreshObjectView()
    clickPrevPage : ->
      paths = @objPathModel.get 'paths'
      paths.pop()
      paths.pop()
      @objPathModel.set 'paths', paths
      @refreshObjectView()
    clickInvertSelection : ->
      $('#objectTableContainer .objectTableView .content .item .check').toggleClass 'iOk iBorder'
    clickPath : (e) ->
      obj = $ e.currentTarget
      if !obj.hasClass 'active'
        @changePath obj.attr 'data-path'
      @
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
      remove = (comfirm, cbf) ->
        if comfirm
          objs = $('#objectTableContainer .content .item .check.iOk').map ->
            $(@).closest('.item').find('.name').text()
          cbf null, objs.toArray()
        else
          cbf null

      async.waterfall [
        userSelectCbf
        remove
      ], (err, objs) =>
        if objs?.length
          currentPath = @objPathModel.get 'name'
          if currentPath
            currentPath = currentPath.substring 1
          $.ajax({
            url : "#{@activeBucket.url()}/deleteobjects"
            type : 'post'
            data : {
              currentPath : currentPath
              objs : objs
            }
          }).success =>
            paths = @objPathModel.get 'paths'
            if paths
              paths.pop()
              @objPathModel.set 'paths', paths
            @refreshObjectView()

    clickCreateBucket : ->
      createBucketDlg = new JT.View.Alert {
        model : new JT.Model.Dialog {
          title : '创建bucket'
          content : '<p>请输入bucket的名字：<input type="text" class="bucket" /></p>'
          modal : true
          btns : 
            '确定' : ($el) =>
              bucket = $el.find('.bucket').val()
              $.get("/createbucket/#{bucket}").success( (res) =>
                @bucketCollection.add {
                  name : bucket
                }
              ).error () ->
                console.dir 'fail'
            '取消' : ->

        }
      }

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
        currentPath = @objPathModel.get 'name'
        objs = $('#objectTableContainer .content .item .check.iOk').map ->
            currentPath + $(@).closest('.item').find('.name').text()
        objs = objs.toArray()
        if objs.length
          $.ajax({
            url : "/headobjects/#{@activeBucket.get('name')}"
            type : 'post'
            data : 
              headers : result.headers
              objs : objs
          }).success((res) ->

          ).error (res) ->
            console.dir 'headobjects fail!'
    clickSetting : ->
      new JT.View.Alert {
        model : new JT.Model.Dialog {
          title : '设置'
          content : '<p>请输入bucket的名字：<input type="text" class="bucket" /></p>'
          modal : true
          btns : 
            '确定' : ($el) =>
              
            '取消' : ->

        }
      }
    initBucketsView : ->
      self = @
      $.get('/buckets').success((res) ->
        if self.bucketCollection
          self.bucketCollection.reset res
        else
          bucketCollection = new OSS.Collection.Bucket res
          bucketView = new OSS.View.Bucket {
            el : $ '#bucketListContainer .buckets'
            model : bucketCollection
          }
          self.listenTo bucketCollection, 'change:active', (bucket, value) ->
            if value
              self.bucketActive bucket
          bucketCollection.at(0).set 'active', 'active'
          self.bucketCollection = bucketCollection
          self.bucketView = bucketView
      ).error (res) ->
        console.dir res
      @
    initObjectTableView : (items) ->
      self = @
      currentPath = @objPathModel.get 'name'
      # items = data.items
      _.each items, (item) ->
        item.bucketPath = self.activeBucket.url()
        item.currentPath = currentPath
      if !@objCollection
        objCollection = new OSS.Collection.Obj items
        objView = new OSS.View.Obj {
          el : $ '#objectTableContainer .objectTableView'
          model : objCollection
          changePath : (folder) ->
            self.changePath self.getAbsolutePath folder
          getAttr : (objName) ->
            self.getAttr self.getAbsolutePath objName
          delete : (objName) ->
            self.delete self.getAbsolutePath objName
        }
        self.listenTo objCollection, 'change:active', (bucket, value) ->
          if value
            self.changePath self.getAbsolutePath bucket.get 'name'
        self.listenTo objCollection, 'change:viewAttr', (bucket, value) ->
          if value
            self.getAttr self.getAbsolutePath bucket.get 'name'
        @objCollection = objCollection
        @resize()
      else
        @objCollection.reset items
      @
    getAbsolutePath : (name) ->
      currentPath = @objPathModel.get 'name'
      if currentPath.charAt(currentPath.length - 1) != '/'
        currentPath += '/'
      "#{currentPath}#{name}"
    delete : (pathName) ->
      self = @
      console.dir self.activeBucket.url()
      if pathName.charAt(0) == '/'
        pathName = pathName.substring 1
      $.ajax({
        type : 'delete'
        url : "#{self.activeBucket.url()}?obj=#{pathName}"
      }).success((res) ->
        self.refreshObjectView()
      ).error (res) ->

    getAttr : (pathName) ->
      self = @
      objAttr = new OSS.Model.ObjAttr {
        bucketPath : self.activeBucket.url()
        name : pathName
      }
      objAttr.fetch {
        success : (model, res) ->
          new OSS.View.ObjAttr {
            model : objAttr
          }
        error : (model, res) ->
          console.dir res
      }
    changePath : (pathName) ->
      self = @
      activeBucketPath = self.activeBucket.url()
      self.setPaths "#{activeBucketPath}#{pathName}"
      if @objPathModel
        @objPathModel.set 'active', false
      objPathModel = new OSS.Model.ObjPath {
        bucketPath : activeBucketPath
        name : pathName
        active : true
      }
      @objPathModel = objPathModel
      @refreshObjectView()
      @
    refreshObjectView : ->
      self = @
      @objPathModel.fetch {
        success : (model, res) ->
          if model.get 'active'
            pathName = model.get 'name'
            if pathName
              pathNameLength = pathName.length - 1
              res.items = _.map res.items, (item) ->
                item.name = item.name.substring pathNameLength
                if item.name
                  item
                else
                  null
            self.pageHandle model, res.next
            # if res.next
            #   paths = model.get('paths') || []
            #   paths.push res.next
            #   model.set 'paths', paths
            self.initObjectTableView _.compact res.items
        error : (model, res) ->
          console.dir res
      }
      @
    pageHandle : (model, next) ->
      ctrlsObj = @$el.find '.ctrlsContainer'
      prevPage = ctrlsObj.find '.prevPage'
      nextPage = ctrlsObj.find '.nextPage'
      paths = model.get('paths') || []
      if paths.length
        prevPage.show()
      else
        prevPage.hide()
      if next
        paths.push next
        model.set 'paths', paths
        nextPage.show()
      else
        nextPage.hide()
      console.dir paths
      @
    bucketActive : (bucket) ->
      self = @
      self.activeBucket = bucket
      self.changePath ''
      @
      # self.setPaths _.compact url.split '/'
      # bucket.fetch {
      #   success : (model, res, options) ->
      #     if model.get 'active'
      #       self.initObjectTableView res
      #   error : (model, res, options) ->
      #     console.dir res
      # }
    setPaths : (url) ->
      paths = _.compact url.split '/'
      paths.shift()
      lastPath = paths.pop()
      dataPath = ''
      pathHtmlArr = _.map paths, (currentPath) ->
        if !dataPath
          dataPath = '/'
        else
          dataPath += "#{currentPath}/"
        '<a href="javascript:;" class="path" data-path="' + dataPath + '">' + currentPath + '</a>'
      pathHtmlArr.push '<a href="javascript:;" class="path active">' + lastPath + '</a>'
      $('#objectTableContainer .paths').html "当前位置：#{pathHtmlArr.join('')}"
      @
    initialize : ->
      self = @
      # @initBucketsView()
      # $(window).resize _.debounce @resize, 200
      # $(document).ajaxError (err, res) ->
      #   console.dir res.responseText
      @

  }

  # new App {
  #   el : document
  # }
  do ->
    urlPrefix = ''
    if window.location.host != 'oss.vicanso.com'
      urlPrefix = '/oss'
    $(document).ajaxSend((e, xhr, setting) ->
      if setting.dataType != 'script'
        setting.url = urlPrefix + setting.url
    ).ajaxError (e, res) ->

    _.delay ->
      $(window).trigger 'resize'
    , 100

    # $.getScript '/static/oss/javascripts/objectattribute.coffee'
    # window.OSS_PATH = new OSS.Model.Path

 