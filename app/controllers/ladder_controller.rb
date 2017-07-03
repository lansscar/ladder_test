class LadderController < ApplicationController

  def index
  end

  # 查询实时绩效考核成绩
  def realtime_score
    data = User.find_all_users_for_main_page || []
    render json: data
  end

end
