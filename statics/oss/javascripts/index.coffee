jQuery ($) ->

  loginDlg = new JT.View.Dialog {
    el : $ '#loginDialog'
    model : new JT.Model.Dialog {
      title : '登录OSS'
      content : "<div class='inputItem'><span class='name'>Key ID:</span><input class='keyId' type='text' /></div>
      <div class='inputItem'><span class='name'>Key Secret:</span><input class='keySecret' type='text' /></div>
      "
      modal : true
      destroyOnClose : false
      btns : 
        '登录' : (dlg) ->
          keyId = dlg.find('.keyId').val()
          keySecret = dlg.find('.keySecret').val()
          if keyId && keySecret
            $.ajax({
              url : '/login'
              type : 'post'
              data : 
                keyId : keyId
                keySecret : keySecret
            }).success(() ->
              window.location.reload()
            ).error () ->

        '取消' : ->
    }
  }
  loginDlg.close()
  # loginDlg.open()

  do ->
    msgList = new MsgCollection
    new MsgListView {
      model : msgList
      el : $ '#msgListContainer'
    }
    window.MSG_LIST = msgList
    $(document).ajaxError (e, res) ->
      if res.status == 401
        loginDlg.open()
do ->
  urlPrefix = ''
  if window.location.host != 'oss.vicanso.com'
    urlPrefix = '/oss'

  $('#loadingMask').on 'click', '.bgExec', ->
    $('#loadingMask').hide()
  $(document).ajaxSend((e, xhr, setting) ->
    if setting.dataType != 'script'
      setting.url = urlPrefix + setting.url
    $('#loadingMask').show()
  ).ajaxComplete (e, res) ->
    $('#loadingMask').hide()
  _.delay ->
    $(window).trigger 'resize'
  , 100