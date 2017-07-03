# 会在钉钉初始化成功后被调用
@afterDingtalkInitedInGradePage = () ->
  dd.biz.navigation.setRight({
    show: false
  })
  dd.biz.navigation.setTitle({
    title: '待审批'
  })
  return

# 向服务器请求数据
$ ->
  $.ajax window.location.pathname + '/post?fresh=' + Math.random(),
    type: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      dd.device.notification.toast({
        text: "请求绩效数据失败！"
      })
    success: (data, textStatus, jqXHR) ->
      onRequestGradesDataSuccess(data)
  return