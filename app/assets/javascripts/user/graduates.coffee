# 会在钉钉初始化成功后被调用
@afterDingtalkInitedInUserPage = () ->
  dd.biz.navigation.setRight({
    show: false
  })
  dd.biz.navigation.setTitle({
    title: '交大同学'
  })
  return