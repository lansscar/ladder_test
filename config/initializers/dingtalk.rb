# 用于配置一些与dingtalk相关的内容

# 配置我们自己提供dingtalk api服务的域名
Rails.configuration.dingtalk_domain = ENV['DINGTALK_API_DOMAIN'].present? ? ENV['DINGTALK_API_DOMAIN'] : 'dingtalk.sjtudoit.com'
