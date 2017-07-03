# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# 响应新申请
$ ->
  $(document).on("click", '#new-grade', () ->
    currentUserId = Cookies.get(COOKIE_CURRENT_USER_ID)
    if currentUserId
      window.location.href = '/user/' + currentUserId
    else
      window.location.reload
  )
  return

# 响应待审批
$ ->
  $(document).on("click", '#request-grade', () ->
    currentUserId = Cookies.get(COOKIE_CURRENT_USER_ID)
    if currentUserId
      window.location.href = '/user/' + currentUserId + '/grades/waiting'
    else
      window.location.reload
  )
  return

# 响应已审批
$ ->
  $(document).on("click", '#proved-grade', () ->
    currentUserId = Cookies.get(COOKIE_CURRENT_USER_ID)
    if currentUserId
      window.location.href = '/user/' + currentUserId + '/grades/proved'
    else
      window.location.reload
  )
  return

# 响应个人管理
$ ->
  $(document).on("click", '#calendar', () ->
    currentUserId = Cookies.get(COOKIE_CURRENT_USER_ID)
    if currentUserId
      window.location.href = '/user/' + currentUserId + '/calendar'
    else
      window.location.reload
  )
  return

# 响应交大研究生数据
$ ->
  $(document).on("click", '#graduates', () ->
    window.location.href = '/group/graduates'
  )
  return

# 响应待我审批
$ ->
  $(document).on("click", '#admin-all-waiting', () ->
    window.location.href = '/admin/grades/waiting'
  )
  return

# 响应扣分
$ ->
  $(document).on("click", '#admin-punish', () ->
    window.location.href = '/admin/grades/punish'
  )
  return

# 会在钉钉初始化成功之后被调用
@afterDingtalkInitedInUserPage = () ->
  dd.biz.navigation.setRight({
    show: true,
    control: true,
    text: '新申请',
    onSuccess: (() ->
      currentUserId = Cookies.get(COOKIE_CURRENT_USER_ID)
      if currentUserId
        window.location.href = '/user/' + currentUserId
      else
        window.location.reload
    )
  })
  return