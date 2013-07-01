window.TIME_LINE.timeEnd 'loadjs'
window.TIME_LINE.time 'execjs'
jQuery ($) ->
  window.TIME_LINE.timeEnd 'all', 'html'
  setTimeout () ->
    data = window.TIME_LINE.getLogs()
    data.type = 'timeline'
    $.post '/statistics', data
  , 0


