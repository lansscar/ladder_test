module Timeable

  class << self

    # 根据相对时间格式化时间
    # @param [Time] time  需要格式化的时间
    # @param [Time] time  基准时间
    # @return [String] 格式化后的结果
    def time_to_s(time, base = Time.now.localtime)
      time = time.localtime
      time_s = time.strftime('%F %R:%S')

      # 处理大于基准时间和小于1小时的情况
      delta = base - time
      if delta < 0
        return time_s
      elsif delta < 1.minutes
        return "#{delta.to_i}秒前"
      elsif delta < 1.hours
        return "#{(delta / 60).to_i}分钟前"
      end

      # 处理3天内的情况
      delta = time - base.to_date.to_time
      if delta >= 0 && delta < 1.days
        return "今天 #{time.strftime('%R:%S')}"
      elsif delta >= -1.days && delta < 0
        return "昨天 #{time.strftime('%R:%S')}"
      elsif delta >= -2.days && delta < -1.days
        return "前天 #{time.strftime('%R:%S')}"
      end

      # 默认情况
      time_s
    end

    # 计算当月的时间区间
    # @param [Fixnum] year
    # @param [Fixnum] month
    # @return [{left: , right: }]
    def get_month_interval(year, month)
      left = Time.local(year, month)
      next_month = next_month(year, month)
      right = Time.local(next_month[:year], next_month[:month])
      {left: left, right: right}
    end

    # 计算下个月的时间信息
    # @param [Fixnum] year
    # @param [Fixnum] month
    # @return [{year: , month: }]
    def next_month(year, month)
      month += 1
      if month > 12
        year += 1
        month = 1
      end
      {year: year, month: month}
    end

    # 计算上个月的时间信息
    # @param [Fixnum] year
    # @param [Fixnum] month
    # @return [{year: , month: }]
    def prev_month(year, month)
      month -= 1
      if month < 1
        year -= 1
        month = 12
      end
      {year: year, month: month}
    end
  end
end