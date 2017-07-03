# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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

# 绘制图形
draw = (data) ->
  length=data[0].score;
  length=Math.ceil(length/10)*10
  for hash in data
    item = $('.item').clone();
    item.removeClass();
    item.find('.item-left').text(hash.name).css("background-color",hash.color);
    item.find('.item-top').text('第'+hash.rank+'名').css("background-color",hash.color);
    item.find('.item-top').width(hash.score/length*$('.item-right').width())
    item.find('.item-bottom1').text(hash.score+'分 / '+hash.grade);
    if hash.pre_rank<hash.rank
      item.find('.item-bottom2').text(' ↓'+(hash.rank-hash.pre_rank)).css("color","#F2725E")
    else if hash.pre_rank>hash.rank
      item.find('.item-bottom2').text(' ↑'+(hash.pre_rank-hash.rank)).css("color","#16C195")
    else
      item.find('.item-bottom2').text('   ≡').css("color","#16C195")
    item.appendTo($('#root'))
  $('.item').hide()
  return

# 请求天梯数据并绘制图形
refreshChart = () ->
  $.ajax '/ladder/scores',
    type: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      $('#root').height(0)
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
      draw(data)
      $('.root').show()
  return

# 载入完成后立即请求天梯数据
$ ->
  year=new Date().getFullYear()
  month=new Date().getMonth()+1
  $('.head-left-bottom').text(year+'年'+month+'月实时量化绩效考核系统')
  $('title').text('上海柏岸电子科技有限公司')
  $('.item-right').width($('.item').width()-$('.item-left').width()-10)
  $('.root').hide()
  refreshChart()
  return

$ ->
  $(document).on("click", '.home_page_btn', () ->
    window.location.href = '/user'
  )
  return

$ ->
  $(document).on("click", '.ladder_rank_btn', () ->
    window.location.href = '/'
  )
  return

$ ->
  $(document).on("click", '.new_request_btn', () ->
    searchURL = window.location.search;
    searchURL = searchURL.substring(1, searchURL.length);
    currentUserId = searchURL.split("?")[0].split("=")[1];
    if currentUserId
      window.location.href = '/user/' + currentUserId
    else
      window.location.reload
  )
  return