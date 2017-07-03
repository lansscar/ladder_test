class Group

  include Mongoid::Document

  field :name # 组的名称

  index({name: 1}, {unique: true}) # 基于name的unique索引

  has_and_belongs_to_many :users

  GROUP_USERS_CACHE_KEY_PREFIX = 'Group::GROUP_USERS_CACHE_KEY_'

  # 所有的小组名称
  SJTU_CORE_GRADUATE = '交大核心研究生'

  # 构造
  # @param [String] group_name  小组名称
  def initialize(group_name)
    super()
    self.name = group_name
  end

  class << self

    # 查找交大核心研究生的信息
    # @return [Array[Hash{name:, score:}]]
    def find_sjtu_core_graduates_info
      find_group_users_info(SJTU_CORE_GRADUATE)
    end

    # 查找小组用户信息
    # @param [String] group_name 小组名称
    # @return [Array[Hash{name:, score:}]]
    def find_group_users_info(group_name)
      find_group_users_with_cache(group_name).map do |user|
        {name: user.name, score: user.score.round(2)}
      end
    end

    # 插入单个用户
    # @param [String] group_name 小组名称
    # @param [User] user 单个用户
    def insert_user(group_name, user)
      group = Group.where(:name => group_name).first
      group.users << user unless group.nil?
      find_group_users_with_cache(group_name, true) # 强制刷新
    end

    # 直接查找组内所有用户，不使用缓存
    # @param [String] group_name 小组名称
    # @return [Array[User]] 不会返回nil
    def find_group_users_directly(group_name)
      result = []
      group = Group.where(:name => group_name).first
      result = group.users unless group.nil?
      result.map do |user|
        user
      end
    end

    # 使用缓存查找组内所有用户
    # @param [String] group_name 小组名称
    # @param [TrueClass/FalseClass] 默认false，如果需要强制刷新就传true
    # @return [Array[User]] 不会返回nil
    def find_group_users_with_cache(group_name, force = false)
      Rails.cache.fetch(GROUP_USERS_CACHE_KEY_PREFIX + group_name, expires_in: 1.days, force: force) do
        find_group_users_directly(group_name)
      end
    end
  end
end