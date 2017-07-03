# 在模态框弹出之后，如果尚未请求过用户数据，就请求
$ ->
  $('#users').on('shown.bs.modal', () ->
    number = $('#valid-users').children().length
    if number == 0
      showLoading()
      $.ajax '/all-valid-users',
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
          hideLoading()
          dd.device.notification.toast({
            text: "请求有效用户数据失败！",
          })
        success: (data, textStatus, jqXHR) ->
          hideLoading()
          displayData(data)
  )
  return

# 显示loading
showLoading = () ->
  $('#loading').css('display','flex')
  return

# 隐藏loading
hideLoading = () ->
  $('#loading').css('display','none')
  return

# 展示数据
displayData = (data) ->
  for d in data
    do (d) ->
      li = $('<li class="list-group-item"></li>')
      li.text(d.name)
      userNameLabel = $('<lable></lable>')
      userNameLabel.hide()
      userNameLabel.text(d.name)
      userNameLabel.appendTo(li)
      useridLabel = $('<lable></lable>')
      useridLabel.hide()
      useridLabel.text(d.userid)
      useridLabel.appendTo(li)
      li.click((target) -> onLiClick(target))
      li.appendTo($('#valid-users'))
  return

# 响应user的li点击
onLiClick = (target) ->
  labels = $(target.currentTarget).children()
  username = $(labels[0]).html()
  userid = $(labels[1]).text()
  $('#choose-user').text(username)
  $('#choose-userid').val(userid)
  $('#users').modal('hide')
  return

# 会在钉钉初始化成功后被调用
@afterDingtalkInitedInUserPage = () ->
  dd.biz.navigation.setRight({
    show: false
  })
  dd.biz.navigation.setTitle({
    title: '扣分'
  })
  return

$ ->
  $('#request-form').submit ->
    $('#submit-button').attr("disabled", true);
    inputs = $('#request-form :input')
    values = {}
    inputs.each ->
      if this.name
        values[this.name] = $(this).val();
    values['creator'] = Cookies.get(COOKIE_CURRENT_USER_ID)
    unless values['name']
      dd.device.notification.alert({
        title: "请正确输入名称",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false
    if !values['grade'] || values['grade'] == '0'
      dd.device.notification.alert({
        title: "请正确输入扣分，仅限数字",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false
    unless values['description']
      dd.device.notification.alert({
        title: "请正确输入概要",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false
    unless values['choose-userid']
      dd.device.notification.alert({
        title: "请选择扣分对象",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false

    values['punish'] = 'true'   # 表示是惩罚
    url = '/user/' + values['choose-userid'] + '/post?fresh=' + Math.random()
    $.ajax url,
      type: 'POST'
      data: values
      error: (jqXHR, textStatus, errorThrown) ->
        dd.device.notification.toast({
          text: "添加扣分请求失败！",
          onSuccess: () -> $('#submit-button').removeAttr("disabled")
        })
      success: (data, textStatus, jqXHR) ->
        if data.status == 'error'
          dd.device.notification.toast({
            text: data.msg,
            onSuccess: () -> $('#submit-button').removeAttr("disabled")
          })
        else if data.status == 'ok'
          dd.device.notification.toast({
            text: data.msg,
            onSuccess: (() ->
              history.go(-1)
            )
          })
        else
          dd.device.notification.toast({
            text: "添加扣分请求失败！",
            onSuccess: () -> $('#submit-button').removeAttr("disabled")
          })
    return false  # 阻止系统的自动提交，使用ajax来提交
  return