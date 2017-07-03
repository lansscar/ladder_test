require 'spec_helper'
require 'rails_helper'
require_relative '../config/environment'

describe 'to_s correct' do

  it 'time bigger than base' do
    t = Time.now + 35.seconds
    expect(Timeable::time_to_s(t)).to eql(t.localtime.strftime('%F %R:%S'))
  end

  it 'between 1 minute' do
    t = Time.now - 35.seconds
    expect(Timeable::time_to_s(t)).to eql('35秒前')
  end

  it 'between 1 hour' do

    t = Time.now - 35.minutes
    expect(Timeable::time_to_s(t)).to eql('35分钟前')
  end

  it 'today' do

    t = Time.now - 2.hours
    expect(Timeable::time_to_s(t)).to match(/今天/)
  end

  it 'yesterday' do

    t = Time.now - 24.hours
    expect(Timeable::time_to_s(t)).to match(/昨天/)
  end

  it 'day before yesterday' do

    t = Time.now - 48.hours
    expect(Timeable::time_to_s(t)).to match(/前天/)
  end

  it 'default' do

    t = Time.now - 35.days
    expect(Timeable::time_to_s(t)).to eql(t.localtime.strftime('%F %R:%S'))
  end
end