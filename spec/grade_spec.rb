require 'spec_helper'
require 'rails_helper'
require_relative '../config/environment'

describe 'grade create log' do

  User.delete_all
  u = User.new('name', 'dingtalk_id')
  u.save
  Grade.delete_all
  g = Grade.new('dingtalk_id', 'title', 10, 'description')
  g.save

  it 'log correct' do
    log = g.grade_logs[0].to_s
    expect(log).to match(/name/)
    expect(log).to match(/创建/)
  end

  it 'log asc' do
    log = GradeLog.initialize_create('dingtalk_id')
    log.created_at -= 5.days
    g.grade_logs << log
    g.save

    log = GradeLog.initialize_create('dingtalk_id')
    g.grade_logs << log
    g.save

    logs = g.grade_logs
    expect(logs[0].created_at).to be <= logs[1].created_at
    expect(logs[1].created_at).to be <= logs[2].created_at
  end
end

describe 'find_waiting_by_dingtalk_id' do

  it 'correct when grades found' do
    Grade.delete_all

    aaa = Grade.new('test_id', 'aaa', 10, 'aaa'); aaa.save
    bbb = Grade.new('test_id', 'bbb', 10, 'bbb'); bbb.save; bbb.created_at -= 1.days
    ccc = Grade.new('test_id', 'ccc', 10, 'ccc'); ccc.save; ccc.created_at += 1.days

    ddd = Grade.new('test_id', 'ddd', 10, 'ddd'); ddd.status = Grade.const_get(:STATUS_B); ddd.save
    aaa = Grade.new('test_id123', 'aaa', 10, 'aaa'); aaa.save

    results = Grade.find_waiting_by_dingtalk_id('test_id')

    expect(results.length).to eql 3
    expect(results[0].created_at).to be >= results[1].created_at
    expect(results[1].created_at).to be >= results[2].created_at
  end

  it 'correct when find nothing' do
    Grade.delete_all
    results = Grade.find_waiting_by_dingtalk_id('test_id')
    expect(results.length).to eql 0
  end
end

describe 'custom status setter' do

  it 'correct' do

    g = Grade.new('test_id', 'aaa', 10, 'aaa')
    g.status = 'A++'
    g.save
    expect(g.status).to eql('A++')
    g.status = 'B++'
    g.save
    expect(g.status).not_to eql('B++')
  end
end

describe 'find_last_update_grade' do

  it 'correct' do

    Grade.delete_all

    target = Grade.new('test_id', 'aaa', 10, 'aaa')
    target.save

    ccc = Grade.new('test_id', 'aaa', 10, 'aaa')
    ccc.save

    sleep(2)
    target.grade = 11
    target.save

    ddd = Grade.new('test', 'aaa', 10, 'aaa')
    ddd.save

    aaa = Grade.new('test_id', 'aaa', 10, 'aaa')
    aaa.save
    aaa.created_at -= 1.months
    aaa.save

    bbb = Grade.new('test_id', 'aaa', 10, 'aaa')
    bbb.save
    bbb.created_at += 1.months
    bbb.save

    now = Time.now
    next_month = Timeable::next_month(now.year, now.month)
    result = Grade.find_last_update_grade('test_id', Time.local(now.year, now.month),
                                          Time.local(next_month[:year], next_month[:month]))
    expect(result._id).to eql(target._id)
  end
end