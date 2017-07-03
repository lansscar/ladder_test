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

$ ->
  searchURL = window.location.search;
  searchURL = searchURL.substring(1, searchURL.length);
  y = searchURL.split("?")[0].split("=")[1];
  m = searchURL.split("?")[1].split("=")[1];
  d = searchURL.split("?")[2].split("=")[1];
  window.date=new Date(y,m,d)
  $('#daily-increase,#daily-task').hide()
  values={}
  values['year']=y
  values['month']=parseInt(m)+1
  values['day']=d
  values['limit']=100
  str=window.location.pathname
  $.ajax str.substring(0,str.length-9) + '/post?fresh=' + Math.random(),
    type: 'POST'
    data: values
    error: ((jqXHR, textStatus, errorThrown) ->
      dd.device.notification.toast({
        text: "请求绩效数据失败！"
      })
      dd.ui.pullToRefresh.stop()),
    success: ((data, textStatus, jqXHR) ->
      increase=0;
      for db in data
        do (db) ->
          increase+=db.grade*ratio(db.status)
      $('.daily-increase-details').show()
      .text('尊敬的用户，您'+window.date.getFullYear()+'年'+(window.date.getMonth()+1)+'月'+window.date.getDate()+'日的天梯分数增加了'+increase+'分，请继续加油！')
      dd.ui.pullToRefresh.stop()
      showCalendarData("calendarTable2")
      afterDingtalkInitedInGradePage())

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

ratio = (status)->
  switch status
    when 'A+' then result=1.25
    when 'A' then result=1.0
    when 'B' then result=0.5
    when '扣分' then result=-1
    else result=0
  return result

@find=(object)->
  values={}
  values['year']=window.date.getFullYear()
  values['month']=window.date.getMonth()+1
  values['day']=window.date.getDate()
  values['limit']=100
  str=window.location.pathname
  $.ajax str.substring(0,str.length-9) + '/post?fresh=' + Math.random(),
    type: 'POST'
    data: values
    error: ((jqXHR, textStatus, errorThrown) ->
      dd.device.notification.toast({
        text: "请求绩效数据失败！"
      })
      dd.ui.pullToRefresh.stop()),
    success: ((data, textStatus, jqXHR) ->
      increase=0;
      for db in data
        do (db) ->
          increase+=db.grade*ratio(db.status)
      $('.daily-increase-details').show()
      .text('尊敬的用户，您'+window.date.getFullYear()+'年'+(window.date.getMonth()+1)+'月'+window.date.getDate()+'日的天梯分数增加了'+increase+'分，请继续加油！')
      dd.ui.pullToRefresh.stop())
