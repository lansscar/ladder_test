class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name # 姓名
  field :dingtalk_id # 钉钉返回的id，唯一

  field :valid_in_dingtalk, type: Boolean, default: true # 在钉钉中是否有效，存在-有效，不存在-无效
  field :visible, type: Boolean, default: true # 是否可见
  field :score, type: Float, default: 0.0 # 当月量化考核评分
  field :base_score, type: Float, default: 0.0 # 当月任务基本分

  field :authority # 权限
  field :level # 等级，保留着，以后再用

  index({dingtalk_id: 1}, {unique: true}) # 基于dingtalk_id的unique索引

  embeds_many :score_records
  has_and_belongs_to_many :groups

  ALL_USER_CACHE_KEY = 'User::ALL_USER_CACHE_KEY'

  AUTHORITY_NORMAL = '普通'
  AUTHORITY_ADMIN = '管理员'

  LAST_MONTH_RECORD_RATIO = 0.1 # 计算上个月绩效考核结果转移到本月的比例

  # 构造
  # @param [String] name
  # @param [String] dingtalk_id
  def initialize(name, dingtalk_id)
    super()
    self.name = name
    self.dingtalk_id = dingtalk_id
    self.authority = AUTHORITY_NORMAL
  end

  # 重载save，如果是新user就刷新缓存
  # @return nothing
  def save
    super

    # 这里无论是是new，都需要刷新缓存，因为计算每个月绩效的时候，不是new，而此时需要强制刷新
    self.class.find_all_users_with_cache(true)
  end

  # 判断是否是管理员
  # @return [TrueClass/FalseClass]
  def admin?
    authority == AUTHORITY_ADMIN
  end

  # 计算绩效记录
  # @return [Nothing]
  def calc_grade_record
    now = Time.now.localtime
    record = calc_monthly_grade_record(now.year, now.month)
    self.score = record[:score]
    self.base_score = record[:base_score]
    self.save
  end

  class << self

    # 根据钉钉返回的结果更新所有user
    # @param [Array[Dingtalk::UserInfo]] data 钉钉返回的user结果
    def update_all(data)
      dingtalk_results = data.dup

      # 根据是否存在于钉钉的结果，更新数据库里面的用户有效性
      self.all.each do |db_user|
        find = false
        dingtalk_results.each_index do |index|
          if db_user.dingtalk_id == dingtalk_results[index]['userid']
            db_user.valid_in_dingtalk = true
            db_user.save
            dingtalk_results.delete_at(index)
            find = true
            break
          end
        end
        unless find
          db_user.valid_in_dingtalk = false
          db_user.save
        end
      end

      # 将新增的用户插入数据库
      dingtalk_results.each do |dingtalk_user|
        user = User.new(dingtalk_user['name'], dingtalk_user['userid'])
        user.save
      end
    end

    def ratio (status)
        case status
          when 'A+' then result=1.25
          when 'A' then result=1.0
          when 'B' then result=0.5
          when '扣分' then result=-1
          else result=0
        end
        result
    end

    # 查找所有用于显示在天梯展示页面的数据
    # @return [Array[Hash{name:, score:}]]
    def find_all_users_for_main_page
      year=Time.new.year.to_i
      month=Time.new.month.to_i
      day=Time.new.day.to_i
      find_all_users_with_cache.select { |user| user.valid_in_dingtalk && user.visible }.map do |user|
        grades = Grade.find_daily_grades(user.dingtalk_id,Time.local(year,month,day),Time.now,nil,Grade.all.length)
        increase=0
        grades.map do |grade|
          increase+=grade[:grade]*ratio(grade[:status])
        end
        pre_score=(user.score-increase).round(2)
        {name: user.name, score: user.score.round(2),pre_score: pre_score,id:user.dingtalk_id}
      end
    end

    # 查找所有有效用户
    # @return [Array[Hash{name:, dingtalk_id:}]]
    def find_all_valid_users
      find_all_users_with_cache.select { |user| user.valid_in_dingtalk && user.visible }.map do |user|
        {name: user.name, userid: user.dingtalk_id}
      end
    end

    # 根据dingtalk_id查询用户
    # @param [String] id dingtalk id
    # @return [User] 未找到返回nil
    def find_user_by_dingtalk_id(id)
      users = find_all_users_with_cache
      results = users.select do |user|
        user.dingtalk_id == id
      end
      if results.empty?
        users = find_all_users_with_cache(true)
        results = users.select do |user|
          user.dingtalk_id == id
        end
      end
      return nil if results.empty?
      results[0]
    end

    # 根据dingtalk_id查询用户名
    # @param [String] id dingtalk_id
    # @return [String]
    def username_to_s(id)
      user = User.find_user_by_dingtalk_id(id)
      if user.nil?
        username = '未知用户'
      else
        username = user.name
      end
      username
    end

    # 判断是否是管理员
    # @param [String] dingtalk_id
    def admin?(dingtalk_id)
      user = User.find_user_by_dingtalk_id(dingtalk_id)
      return true if !user.nil? && user.admin?
      false
    end
  end

  private

  # 计算月度绩效考核结果
  # @param [Fixnum] year
  # @param [Fixnum] month
  # @return [Float]
  def calc_monthly_grade_record(year, month)
    result = {score: 0.0, base_score: 0.0}

    # 比较待计算的月份与用户创建日期之间的大小
    if Time.local(year, month) < Time.local(created_at.year, created_at.month)
      # 待计算的月份较小，直接返回0.0
      return result
    else
      # 待计算的月份较大，递归调用计算上个月的考核结果
      last_month = Timeable::prev_month(year, month)
      last_month_record = calc_monthly_grade_record(last_month[:year], last_month[:month])
    end

    last_month_record[:score] *= LAST_MONTH_RECORD_RATIO # 这里得到了上个月绩效考核结果中应当计入本月的分数

    # 比较该用户在指定月份中最后一次修改单个grade的时间与grade record的更新时间大小
    next_month = Timeable::next_month(year, month)
    grade = Grade.find_last_update_grade(dingtalk_id, Time.local(year, month),
                                         Time.local(next_month[:year], next_month[:month]))
    if grade.nil?
      result[:score] = last_month_record[:score]
      return result
    end

    current_month_record = query_score_record(year, month)
    prev_month = Timeable::prev_month(year, month)
    prev_month_record = query_score_record(prev_month[:year], prev_month[:month])
    if !current_month_record.nil? && current_month_record.updated_at > grade.updated_at
      if prev_month_record.nil? || # prev_month_record 这个为nil说明上个月的记录不存在，视作不用更新，因此是"或"的关系
          current_month_record.updated_at > prev_month_record.updated_at
        # 无需更新的
        result[:score] = current_month_record.score
        result[:base_score] = current_month_record.base_score
        return result
      end
    end

    # 走到这里说明当月的得分需要重新计算
    all_grades = Grade.find_all_grades_by_time(dingtalk_id, Time.local(year, month),
                                               Time.local(next_month[:year], next_month[:month]))
    ratio_score = last_month_record[:score]
    current_base_score = 0.0
    all_grades.each do |g|
      if g.need_calc_grade?
        ratio_score += g.ratio_grade
        current_base_score += g.grade
      end
    end

    update_score_record(year, month, ratio_score, current_base_score)

    result[:score] = ratio_score
    result[:base_score] = current_base_score
    result
  end

  # 查询指定月份的score record
  # @param [Fixnum] year
  # @param [Fixnum] month
  # @return [ScoreRecord] 未找到就返回nil
  def query_score_record(year, month)
    query = self.score_records.where(year: year, month: month)
    if query.count > 1
      # 走到这里说明已经发生了数据重复，全部删掉
      query.delete
    end
    query.first
  end

  # 更新指定月份的score record，不存在就插入一条
  # @param [Fixnum] year
  # @param [Fixnum] month
  # @param [Float] score
  # @param [Float] base_score
  def update_score_record(year, month, score, base_score)
    record = query_score_record(year, month)
    if record.nil?
      record = ScoreRecord.new(year, month, score, base_score)
      self.score_records << record
    else
      record.score = score
      record.base_score = base_score
    end
    self.save
  end

  class << self

    # 直接查找所有用户，不使用缓存
    # @return [Array[User]] 不会返回nil
    def find_all_users_directly
      User.all.map do |user|
        user
      end
    end

    # 使用缓存查找所有用户
    # @param [TrueClass/FalseClass] 默认false，如果需要强制刷新就传true
    # @return [Array[User]] 不会返回nil
    def find_all_users_with_cache(force = false)
      Rails.cache.fetch(ALL_USER_CACHE_KEY, expires_in: 1.days, force: force) do
        find_all_users_directly
      end
    end
  end
end