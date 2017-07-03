class UserController < ApplicationController

  def main
    user_id = cookies['current-user-id'] || ''
    @admin = User.admin?(user_id)
  end

  def request_grade
    @grade_name = '任务名称'
    @grade_number = '任务基本分'
    @grade_description = '任务完成情况'
  end

  def punish
    @grade_name = '名称'
    @grade_number = '扣分'
    @grade_description = '概要'
    @grade_user = '扣分对象'

    @punish = true
    render 'request_grade'
  end

  # 接收post请求，添加一个grade
  def add_grade
    user_id = params[:user_id] || ''
    name = params[:name] || ''
    grade = params[:grade].to_f
    description = params[:description] || ''
    creator = cookies['current-user-id'] || ''
    punish_flag = params[:punish]
    result = {}
    if user_id.empty? || name.empty? || grade.zero? || description.empty? || creator.empty?
      result = {status: 'error', msg: '添加绩效请求失败！'}
    else
      save_result = false
      new_grade = Grade.new(user_id, name, grade, description, creator)
      new_grade.convert_to_punish if 'true' == punish_flag
      save_result = new_grade.save rescue nil
      if save_result
        result = {status: 'ok', msg: "添加绩效请求成功！"}
      else
        result = {status: 'error', msg: '添加绩效请求失败！'}
      end
    end
    render json: result
  end

  # 查询指定用户正在等待批准的grades
  def waiting_grades_data
    user_id = params[:user_id] || ''
    grades = Grade.find_waiting_by_dingtalk_id(user_id)
    render json: grades
  end

  def waiting_grades
    @waiting = true
    render 'grades'
  end

  def grade_details
    user_id = cookies['current-user-id'] || ''
    @admin = User.admin?(user_id)
  end

  # 查询指定grade的详细信息
  def grade_details_data
    grade_id = params[:grade_id]
    details = Grade.find_grade_details(grade_id)
    render json: details
  end

  def all_waiting_grades
    @waiting = true
    render 'grades'
  end

  # 查询所有待审批的grades
  def all_waiting_grades_data
    user_id = cookies['current-user-id'] || ''
    results = []
    if User.admin?(user_id)
      results = Grade.find_all_waiting_grades
    end
    render json: results
  end

  # 修改grade当前状态
  def grade_status_update
    grade_id = params[:grade_id] || ''
    user_id = cookies['current-user-id'] || ''
    status = params[:status] || ''
    rtn = false
    if User.admin?(user_id)
      rtn = Grade.update_status(grade_id, user_id, status)
    end
    result = {}
    if rtn
      result[:status] = 'ok'
    else
      result[:status] = 'failed'
    end
    render json: result
  end

  # 查询指定用户已审批的grades
  def proved_grades_data
    user_id = cookies['current-user-id'] || ''
    from_id = params[:from]   # 如果不存在这个字段，就把nil传到后面的函数中去
    grades = Grade.find_proved_grades(user_id, from_id)
    render json: grades
  end

  def proved_grades
    @proved = true
    render 'grades'
  end

  def calendar
    render 'calendar'
  end

  def daily_increase
    render 'daily_increase'
  end

  def daily_task
    render 'daily_task'
  end

  def find_daily_task
    user_id = cookies['current-user-id'] || ''
    from_id = params[:from]   # 如果不存在这个字段，就把nil传到后面的函数中去
    year = params[:year]
    month = params[:month]
    day = params[:day]
    limit = params[:limit]
    grades = Grade.find_daily_grades(user_id,Time.local(year,month,day),Time.local(year,month,day.to_i,23,59,59),from_id,limit)
    render json: grades
  end

  # 查询所有有效的用户
  def find_all_valid_users
    render json: User.find_all_valid_users
  end

  def graduates
  end

  # 查询所有交大研究生的分数
  def graduates_scores
    scores = Group.find_sjtu_core_graduates_info
    render json: scores
  end
end
