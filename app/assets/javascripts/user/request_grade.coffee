# 会在钉钉初始化成功后被调用
@afterDingtalkInitedInUserPage = () ->
  dd.biz.navigation.setRight({
    show: false
  })
  dd.biz.navigation.setTitle({
    title: '绩效申请'
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
        title: "请正确输入任务名称",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false
    if !values['grade'] || values['grade'] == '0'
      dd.device.notification.alert({
        title: "请正确输入任务基本分，仅限数字",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false
    unless values['description']
      dd.device.notification.alert({
        title: "请正确输入任务完成情况",
        onSuccess: () -> $('#submit-button').removeAttr("disabled")
      })
      return false

    $.ajax window.location.pathname + '/post?fresh=' + Math.random(),
      type: 'POST'
      data: values
      error: (jqXHR, textStatus, errorThrown) ->
        dd.device.notification.toast({
          text: "添加绩效请求失败！",
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
            text: "添加绩效请求失败！",
            onSuccess: () -> $('#submit-button').removeAttr("disabled")
          })
    return false  # 阻止系统的自动提交，使用ajax来提交
  return