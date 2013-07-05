OSS = window.OSS ?= {}
OSS.Model ?= {}
OSS.Collection ?= {}
OSS.View ?= {}

OSS.Model.Path = Backbone.Model.extend {
  defaults : 
    path : ''
    bucket : ''
    delimiter : '/'
  url : ->
    url = "/objects/#{@get('bucket')}"
    params = []
    path = @get 'path'
    prefix = @get('keyword') || @get 'prefix'
    if path
      if prefix
        path += prefix
      params.push "prefix=#{path}"
    else if prefix
      params.push "prefix=#{prefix}"
    _.each 'delimiter searchType'.split(' '), (type) =>
      value = @get type
      if value
        params.push "#{type}=#{value}"
    # keyword = @get 'keyword'
    # if keyword
    #   params.push "keyword=#{keyword}"

    markers = @get 'markers'
    if markers?.length
      params.push "marker=#{_.last(markers)}"
    if params.length
      url += "?#{params.join('&')}"
    url
  reset : ->
    @set 'prefix', ''
    @set 'keyword', ''
    @set 'markers', []
    @set 'delimiter', '/'

  nextPage : ->
    @trigger 'getdata', @
  prevPage : ->
    markers = @get 'markers'
    markers.pop()
    if !@get 'lastPage'
      markers.pop()
    @set 'markers', markers
    @trigger 'getdata', @
}

# window.OSS_PATH = new OSS.Model.Path

OSS.Model.Bucket = Backbone.Model.extend {
  defaults : 
    name : ''
    active : ''
    className : ''
  initialize : ->
    @className = 'active' if @get 'active'
  idAttribute : 'name'
  urlRoot : '/bucket'

}

OSS.Collection.Bucket = Backbone.Collection.extend {
  model : OSS.Model.Bucket
  url : '/buckets'
}

OSS.View.Bucket = Backbone.View.extend {
  template : _.template '<div class="bucket <%= className %>">' +
    '<div class="arrowLeft"></div>' +
    '<div class="icon iBucket"></div>' +
    '<p class="name"><%= name %></p>' +
  '</div>'
  events :
    'click .bucket' : 'clickBucket'
  clickBucket : (e) ->
    obj = $ e.currentTarget
    index = obj.index '.bucket'
    @model.each (bucket, i) ->
      if i == index
        bucket.set 'active', 'active'
      else
        bucket.set 'active', ''
    @
  active : (bucket, value) ->
    index = @model.indexOf bucket
    obj = @$el.find('.bucket').eq index
    if value
      obj.addClass 'active'
    else
      obj.removeClass 'active'
    @
  item : (type, models, options) ->
    $el = @$el
    if !_.isArray models
      models = [models]
    if type == 'add'
      _.each models, (model) ->
        data = model.toJSON()
        $el.append self.template data
    else if type == 'remove'
      $el.find('.bucket').eq(options.index).remove()
    @

  initialize : ->
    $el = @$el
    $el.addClass 'buckets'
    _.each 'add remove'.split(' '), (event) =>
      @listenTo @model, event, (models, collection, options) =>
        @item event, models, options
    @listenTo @model, 'change:active', (bucket, value) =>
      @active bucket, value
    @listenTo @model, 'reset', @render
    @render()
  render : ->
    self = @
    bucketHtmlArr = _.map @model.toJSON(), (data) ->
      self.template data
    @$el.html bucketHtmlArr.join ''
    @


}