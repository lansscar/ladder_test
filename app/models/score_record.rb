class ScoreRecord

  include Mongoid::Document

  field :year, type: Integer # 年份
  field :month, type: Integer # 月份
  field :updated_at, type: Time # 最后更新时间，因为不触发save，不能使用自带的Timestamps，只能自己处理
  field :score, type: Float # 最终得分
  field :base_score, type: Float # 基本分

  embedded_in :user

  # 构造
  def initialize(year, month, score, base_score)
    super()
    self.year = year
    self.month = month
    self.score = score
    self.base_score = base_score
    self.updated_at = Time.now
  end

  # 自定义setter
  # @param [Float] value
  def score=(value)
    self[:score] = value
    self.updated_at = Time.now
  end

  # 自定义setter
  # @param [Float] value
  def base_score=(value)
    self[:base_score] = value
    self.updated_at = Time.now
  end
end