# 绩效日志
class GradeLog

  include Mongoid::Document

  field :action # 动作类型
  field :creator_id # 创建者ID

  field :created_at, type: Time  # 因为embedded的原因，不会触发save，所以mongoid自带的无效，自己处理一个吧

  field :old_status # 旧的状态
  field :new_status # 新的状态

  embedded_in :grade

  ACTION_CREATE = 'create'
  ACTION_UPDATE_STATUS = 'update_status'

  class << self

    # 初始化创建动作
    # @return [GradeLog]
    def initialize_create(id)
      log = GradeLog.new
      log.creator_id = id
      log.action = ACTION_CREATE
      log.created_at = Time.now
      log
    end

    # 初始化修改状态的动作
    # @return [GradeLog]
    def initialize_update_status(id, old_status, new_status)
      log = GradeLog.new
      log.creator_id = id
      log.action = ACTION_UPDATE_STATUS
      log.created_at = Time.now
      log.old_status = old_status
      log.new_status = new_status
      log
    end
  end

  # 重载to_s，dispatcher
  # @return [String]
  def to_s
    raise Exception, 'unknown log action!' if action.empty?
    send("#{action}_to_s")
  end

  private

  # 创建动作对应的to_s
  # @return [String]
  def create_to_s
    username = User.username_to_s(creator_id)
    "#{Timeable::time_to_s(created_at)} #{username} 创建"
  end

  # 修改状态动作对应的to_s
  # @return [String]
  def update_status_to_s
    username = User.username_to_s(creator_id)
    "#{Timeable::time_to_s(created_at)} #{username} 将绩效状态从 #{old_status} 修改为 #{new_status}"
  end
end