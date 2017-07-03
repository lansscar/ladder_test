require 'spec_helper'
require 'rails_helper'
require_relative '../config/environment'

# describe 'grade create log' do
#
#   it 'to_s' do
#     User.delete_all
#     user = User.new('aaa', '123')
#     user.save
#     log = GradeLog.initialize_create(user.dingtalk_id)
#     log.save
#     output = log.to_s
#     expect(output).to match(/aaa/)
#     expect(output).to match(/创建/)
#     log = GradeLog.initialize_create('321')
#     log.save
#     output = log.to_s
#     expect(output).to match(/未知用户/)
#     expect(output).to match(/创建/)
#   end
# end