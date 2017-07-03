@afterDingtalkInitedInGradePage = () ->
  dd.biz.navigation.setTitle({
    title: window.date.getFullYear()+'年'+(window.date.getMonth()+1)+'月'
  })
  dd.biz.navigation.setLeft({
    show: true,
    control: true,
    text: '返回'
  })
  dd.biz.navigation.setRight({
    show: true,
    control: true,
    text: '月历'
  })
  return

# 根据score来排序
sortByScore = (left, right) ->
  return 1 if left.score < right.score
  return -1 if left.score > right.score
  return 0

# 生成排名
rankByScore = (data) ->
  rank = 1
  length = data.length
  lastScore = 0
  for value, index in data
    rank = index + 1 unless value.score == lastScore
    lastScore = value.score
    value.percent = calcRankPercent(rank, length)
    value.rank = rank
  return data


# 计算排名百分比
calcRankPercent = (rank, total) ->
  return Math.ceil(rank * 10.0 / total) * 10

# 根据排名生成颜色
colorByRank = (data) ->
  for hash in data
    if hash.percent <= 10
      hash.color = '#16C195' # 优，绿色
      hash.grade = 'A'
    else if hash.percent <= 80
      hash.color = '#F7B55E' # 中，黄色
      hash.grade = 'B'
    else
      hash.color = '#F2725E' # 差，红色
      hash.grade = 'C'

    if hash.score <= 0
      hash.color = '#F2725E' # 差，红色
      hash.grade = 'D'
  return data

# 数据预处理
pretreatData = (data) ->
  data = data.sort(sortByScore)
  data = rankByScore(data)
  return colorByRank(data)

# 向服务器请求数据
$ ->
  time = new Date().getHours()
  if time>6 and time<11
    time='早上好，'
    $('#greeting-left').removeClass().addClass('sun')
  else if time>=11 and time<14
    time='中午好，'
    $('#greeting-left').removeClass().addClass('sun')
  else if time>=14 and time<18
    time='下午好，'
    $('#greeting-left').removeClass().addClass('sun')
  else
    time='晚上好，'
    $('#greeting-left').removeClass().addClass('moon')

  $.ajax '/ladder/scores',
    type: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      $('body').append "请求天梯数据失败！"
    success: (data, textStatus, jqXHR) ->
      data = pretreatData(data)
      for value in data
        value.temp_score=value.score;
        value.temp_rank=value.rank;
        value.score=value.pre_score;
      data = pretreatData(data)
      for value in data
        value.pre_rank=value.rank;
        value.score=value.temp_score;
        value.rank=value.temp_rank;
      data = pretreatData(data)
      for value in data
        if value.id==Cookies.get(COOKIE_CURRENT_USER_ID)
          $('.greeting-mid').text(time+value.name)
          $('.rank').text('排名：第'+value.rank+'名')
          $('.score').text('总分：'+value.score+'分')
          $('.grade').text('等级：'+value.grade)
          if value.pre_rank<value.rank
            $('.info-right-increase').text(' ↓'+(value.rank-value.pre_rank)).css("color","#F2725E")
          else if value.pre_rank>value.rank
            $('.info-right-increase').text(' ↑'+(value.pre_rank-value.rank)).css("color","#16C195")
          else
            $('.info-right-increase').text('   ≡').css("color","#16C195")
    dd.ui.pullToRefresh.stop()

  $('#daily-task').click(()->
    y=window.date.getFullYear()
    m=window.date.getMonth()
    d=window.date.getDate()
    window.location.href=window.location.href+'/task?year='+y+'?month='+m+'?day='+d;
  )

  $('#daily-increase').click(()->
    y=window.date.getFullYear()
    m=window.date.getMonth()
    d=window.date.getDate()
    window.location.href=window.location.href+'/increase?year='+y+'?month='+m+'?day='+d;
  )
  return






