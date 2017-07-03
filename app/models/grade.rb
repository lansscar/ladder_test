class Grade

  include Mongoid::Document
  include Mongoid::Timestamps

  field :dingtalk_id # 钉钉返回的id，唯一
  field :title # 任务标题
  field :grade, type: Float # 评分
  field :description # 描述
  field :status #状态

  embeds_many :grade_logs, after_add: :sort_grade_logs_by_time # 操作日志

  # 各种状态
  STATUS_WAITING = '等待审批'
  STATUS_A_PLUS_PLUS = 'A++'
  STATUS_A_PLUS = 'A+'
  STATUS_A = 'A'
  STATUS_B = 'B'
  STATUS_C = 'C'
  STATUS_D = 'D'
  STATUS_CANCELLED = '已废弃'
  STATUS_PUNISH = '扣分'

  # 构造
  def initialize(dingtalk_id, title, grade, description, create_id = dingtalk_id)
    super()
    self.dingtalk_id = dingtalk_id
    self.title = title
    self.grade = grade
    self.description = description
    self.status = STATUS_WAITING

    create_log = GradeLog.initialize_create(create_id)
    grade_logs << create_log
  end

  # 自定义的status setter
  # @param [String] value
  def status=(value)
    if value.in?(self.class.all_status)
      self[:status] = value
      self.save
    end
  end

  # 是否需要进行计分
  # @return [TrueClass/FalseClass]
  def need_calc_grade?
    status.in?([STATUS_A_PLUS_PLUS, STATUS_A_PLUS, STATUS_A, STATUS_B, STATUS_C, STATUS_D, STATUS_PUNISH])
  end

  # 加上绩效后的分数
  # @return [Float]
  def ratio_grade
    grade * ratio
  end

  # 转换成惩罚
  # @return [Nothing]
  def convert_to_punish
    self.status = STATUS_PUNISH

    # 重新算分
    user = User.find_user_by_dingtalk_id(self.dingtalk_id)

    p 'start'
    p user
    user.calc_grade_record unless user.nil?

    p 'close'
  end

  class << self

    # 基于用户ID查找等待审批的grade
    # @param [String] dingtalk_id
    # @return [Array[Grade]] 未找到就返回一个空Array
    def find_waiting_by_dingtalk_id(dingtalk_id)
      dingtalk_id ||= ''
      find_waiting_grades(dingtalk_id)
    end

    # 查找所有等待审批的grade
    # @return [Array[Grade]] 未找到就返回一个空Array
    def find_all_waiting_grades
      find_waiting_grades
    end

    # 根据grade的id查找grade信息
    # @param [String] id _id
    # @return [Hash]
    def find_grade_details(id)
      result = {}
      grade = Grade.where(_id: id).first
      unless grade.nil?
        details = {}
        details[:id] = grade._id.to_s
        details[:title] = grade.title
        details[:name] = User.username_to_s(grade.dingtalk_id)
        details[:status] = grade.status
        details[:description] = grade.description
        details[:log] = grade.grade_logs.map { |log| log.to_s }
        result[:details] = details
      end
      result
    end

    # 查询grade所有可能的状态
    # @return [Array[String]]
    def all_status
      [STATUS_WAITING,
       # STATUS_A_PLUS_PLUS,
       STATUS_A_PLUS,
       STATUS_A,
       STATUS_B,
       STATUS_C,
       # STATUS_D,
       STATUS_CANCELLED,
       STATUS_PUNISH]
    end

    # 修改指定grade的状态
    # @param [String] grade_id
    # @param [String] update_user_id 修改者的id
    # @param [String] status
    # @return [TrueClass/FalseClass]
    def update_status(grade_id, update_user_id, status)
      grade = Grade.where(_id: grade_id).first
      return false if grade.nil?
      old_status = grade.status
      grade.status = status
      result = (grade.status == status) # 这里的result不一定是恒为true，因为status=已经被重载，不是一定会修改成功的
      if result
        grade.save
        log = GradeLog.initialize_update_status(update_user_id, old_status, status)
        grade.grade_logs << log

        # 重新算分
        user = User.find_user_by_dingtalk_id(grade.dingtalk_id)
        user.calc_grade_record unless user.nil?
      end
      result
    end

    # 在指定时间段内查找指定用户最后一个更新的grade
    # @param [String] dingtalk_id 传nil就忽略这个参数
    # @param [Time] from_time 开始时间（包含），传nil就忽略这个参数
    # @param [Time] to_time 结束时间（不包含），传nil就忽略这个参数
    def find_last_update_grade(dingtalk_id, from_time, to_time)
      query = Grade.all
      query = query.where(dingtalk_id: dingtalk_id) unless dingtalk_id.nil?
      query = query.where(:created_at.gte => from_time) unless from_time.nil?
      query = query.where(:created_at.lt => to_time) unless to_time.nil?
      query = query.order_by(updated_at: :desc)
      query.first
    end

    # 在指定时间段内查找指定用户的所有grade
    # @param [String] dingtalk_id 传nil就忽略这个参数
    # @param [Time] from_time 开始时间（包含），传nil就忽略这个参数
    # @param [Time] to_time 结束时间（不包含），传nil就忽略这个参数
    def find_all_grades_by_time(dingtalk_id, from_time, to_time)
      query = Grade.all
      query = query.where(dingtalk_id: dingtalk_id) unless dingtalk_id.nil?
      query = query.where(:created_at.gte => from_time) unless from_time.nil?
      query = query.where(:created_at.lt => to_time) unless to_time.nil?
      query.all.map { |x| x }
    end
  end

  private

  # 根据时间排序grade_logs
  # @param [Array] logs 仅仅是为了满足回调函数的格式，实际不使用这个参数
  def sort_grade_logs_by_time(logs)
    self.grade_logs.sort! { |x, y| x.created_at <=> y.created_at }
  end

  # 算分比率
  # @return [Float]
  def ratio
    result = 0.0
    case status
      when STATUS_A_PLUS_PLUS
        result = 1.5
      when STATUS_A_PLUS
        result = 1.25
      when STATUS_A
        result = 1.0
      when STATUS_B
        # result = 0.75
        result = 0.5
      when STATUS_C
        # result = 0.5
        result = 0.0
      when STATUS_D
        result = 0.0
      when STATUS_PUNISH
        result = -1.0
      else
        result = 0.0
    end
    result
  end

  class << self

    # 复用grades的返回
    # @return [Proc] 返回一个用于返回结果的Proc
    def grade_results_proc()
      Proc.new do |x|
        {
            id: x._id.to_s,
            title: x.title,
            grade: x.grade,
            status: x.status,
            name: User.username_to_s(x.dingtalk_id),
            created_at: Timeable::time_to_s(x.created_at)
        }
      end
    end

    # 查找待审批的grades
    # @param [String] dingtalk_id，不传，或传入nil就是查找全部用户的
    # @return [Array 未找到就返回一个空Array
    def find_waiting_grades(dingtalk_id = nil)
      query = Grade.where(status: STATUS_WAITING)
      query = query.where(dingtalk_id: dingtalk_id) unless dingtalk_id.nil?
      query.order_by(created_at: :asc).map(&grade_results_proc)
    end

    # 查找已审批的grades
    # @param [String] dingtalk_id，用户的dingtalk id
    # @param [String] from_id，上一次查询的最后一个dingtalk id
    # @param [Fixnum] limit，最多查询的个数
    # @return [Array] 未找到就返回一个空Array
    def find_proved_grades(dingtalk_id, from_id = nil, limit = 10)
      query = Grade.where(:status.nin => [STATUS_WAITING])
      query = query.where(dingtalk_id: dingtalk_id)
      query = query.where(:_id.lt => from_id) if from_id
      query = query.order_by(_id: :desc)
      query.limit(limit).map(&grade_results_proc)
    end

    def find_daily_grades(dingtalk_id, from_time, to_time, from_id = nil, limit = 10)
      query = Grade.where(:status.nin => [STATUS_WAITING])
      query = query.where(dingtalk_id: dingtalk_id)
      query = query.where(:_id.lt => from_id) if from_id
      query = query.where(:updated_at.gte => from_time) unless from_time.nil?
      query = query.where(:updated_at.lt => to_time) unless to_time.nil?
      query = query.order_by(_id: :desc)
      query.limit(limit).map(&grade_results_proc)
    end

  end
end