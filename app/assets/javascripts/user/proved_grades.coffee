# 会在钉钉初始化成功后被调用
@afterDingtalkInitedInGradePage = () ->
  dd.biz.navigation.setRight({
    show: false
  })
  dd.biz.navigation.setTitle({
    title: '已审批'
  })
  dd.ui.pullToRefresh.enable({
    onSuccess: (()->
      requestLatestProvedData()
    ),
    onFail: (()->
      dd.ui.pullToRefresh.stop()
    )
  })
  return

# 向服务器请求数据
$ ->
  requestLatestProvedData()
  return

# 向服务器请求最新的已审批数据
requestLatestProvedData = ()->
  $.ajax window.location.pathname + '/post?fresh=' + Math.random(),
    type: 'POST'
    error: ((jqXHR, textStatus, errorThrown) ->
      dd.device.notification.toast({
        text: "请求绩效数据失败！"
      })
      dd.ui.pullToRefresh.stop()),
    success: ((data, textStatus, jqXHR) ->
      onRequestGradesDataSuccess(data)
      displayReloadMore(()->
        requestMoreProvedData(parseLastDataID(data))
      )
      dd.ui.pullToRefresh.stop())
  return

# 从返回数据中解析最新的data id
parseLastDataID = (data)->
  result = null
  if data.length > 0
    result = data[data.length - 1].id
  return result

# 向服务器请求更多的已审批数据
requestMoreProvedData = (lastDataID)->
  url = window.location.pathname + '/post?fresh=' + Math.random()
  url += '&from=' + lastDataID if lastDataID?
  $.ajax url,
    type: 'POST'
    error: ((jqXHR, textStatus, errorThrown) ->
      dd.device.notification.toast({
        text: "请求绩效数据失败！"
      })),
    success: ((data, textStatus, jqXHR) ->
      if data.length > 0
        onRequestGradesDataSuccess(data, false)
        displayReloadMore(()->
          requestMoreProvedData(parseLastDataID(data))
        )
      else
        displayNoMore()
    )
  return
