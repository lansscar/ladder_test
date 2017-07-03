# 会在钉钉初始化成功之后被调用
@afterDingtalkInitedInUserPage = () ->
  dd.biz.navigation.setTitle({
    title: '绩效详情'
  })
  dd.biz.navigation.setRight({
    show: false
  })
  return

# 如果是admin的话，就请求grade的所有状态
$ ->
  if $('#dropdown-menu')?
    $.ajax '/admin/grade/status?fresh=' + Math.random(),
      type: 'POST'
      error: (jqXHR, textStatus, errorThrown) ->
        dd.device.notification.toast({
          text: "请求绩效状态失败！"
        })
      success: (data, textStatus, jqXHR) ->
        if data.length > 0
          dom = $('#dropdown-menu').children('li')
          dom.remove()
          for str in data
            do(str) ->
              newDom = dom.clone()
              newDom.children('a').html(str)
              newDom.click((event) ->
                $('#dropdown-menu').removeClass('open')
                $.ajax window.location.pathname + '/update/status?fresh=' + Math.random(),
                  type: 'POST',
                  data: {'status': $(event.currentTarget).text()}
                  error: (jqXHR, textStatus, errorThrown) ->
                    dd.device.notification.toast({
                      text: "修改绩效状态失败！"
                    })
                  success: (data, textStatus, jqXHR) ->
                    if data.status? && data.status == 'ok'
                      dd.device.notification.toast({
                        text: "修改绩效状态成功！"
                      })
                      $('#dropdownMenu1').html('状态： ' + $(event.currentTarget).text() +
                          ' ' + '<span class="caret"></span>')
                    else
                      dd.device.notification.toast({
                        text: "修改绩效状态失败！"
                      })
              )
              newDom.appendTo($('#dropdown-menu'))
  return

# 请求详情数据
$ ->
  $.ajax window.location.pathname + '/post?fresh=' + Math.random(),
    type: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      dd.device.notification.toast({
        text: "请求绩效数据失败！"
      })
    success: (data, textStatus, jqXHR) ->
      if data.details?
        $('#no-result-div').css('display', 'none')
        $('#results-div').css('display', 'block')
        displayData(data.details)
      else
        $('#no-result-div').css('display', 'block')
        $('#results-div').css('display', 'none')
  return

# 展示数据
displayData = (details) ->
  $('#details-title').html(details.title)
  $('#details-name').html(details.name)
  $('#details-status').html('状态： ' + details.status) if $('#details-status')?
  $('#dropdownMenu1').html('状态： ' + details.status + ' ' + '<span class="caret"></span>') if $('#dropdownMenu1')?
  $('#details-description').html(details.description)
  for log in details.log
    do(log) ->
      newDom = $('#log-sample').clone()
      newDom.css('display', 'block')
      newDom.html(log)
      newDom.appendTo($('#logs'))
  return