require 'spec_helper'
require_relative '../config/environment'
require 'rails_helper'

require 'dingtalk'

describe 'users' do

  let(:server) { Dingtalk::Server.new(Dingtalk.corpid, Dingtalk.corpsecret) }

  it 'query all users' do
    all_users = server.query_all_users
    expect(all_users).not_to be nil
  end
end

# describe 'jsapi_ticket', :type => :request do
#
#   let(:server) { Dingtalk::Server.new(Dingtalk.corpid, Dingtalk.corpsecret) }
#
#   it 'can not query ticket without csrf session' do
#     post '/admin/ticket'
#     expect(response.code).to eql('422')
#   end
#
#   it 'can query ticket bypass csrf' do
#     allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)
#     post '/admin/ticket'
#     expect(JSON.parse(response.body)['ticket']).not_to be nil
#   end
#
#   it 'different tickets when store disabled' do
#     Rails.cache = ActiveSupport::Cache.lookup_store(:null_store)
#     allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)
#
#     post '/admin/ticket'
#     ticket_one = JSON.parse(response.body)['ticket']
#
#     post '/admin/ticket'
#     ticket_two = JSON.parse(response.body)['ticket']
#
#     expect(ticket_one).not_to eql(ticket_two)
#   end
#
#   it 'same ticket when store enabled' do
#     Rails.cache = ActiveSupport::Cache.lookup_store(:memory_store)
#     allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)
#
#     post '/admin/ticket'
#     ticket_one = JSON.parse(response.body)['ticket']
#
#     post '/admin/ticket'
#     ticket_two = JSON.parse(response.body)['ticket']
#
#     expect(ticket_one).to eql(ticket_two)
#   end
# end

describe 'jsapi_config', :type => :request do

  let(:server) { Dingtalk::Server.new(Dingtalk.corpid, Dingtalk.corpsecret) }

  it 'can not query jsapi config without csrf session' do
    post '/admin/jsapiconfig'
    expect(response.code).to eql('422')
  end

  it 'can query jsapi config bypass csrf' do
    allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)
    post '/admin/jsapiconfig', {url: 'http://xxx.yyy.zzz'}
    expect(JSON.parse(response.body)['config']).not_to be nil
  end
end