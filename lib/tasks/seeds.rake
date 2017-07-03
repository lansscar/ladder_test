task :group_seeds => 'db:mongoid:create_indexes' do

  # 添加交大核心研究生
  sjtu_core_group = Group.where(:name => Group::SJTU_CORE_GRADUATE).first
  if sjtu_core_group.nil?
    sjtu_core_group = Group.new(Group::SJTU_CORE_GRADUATE)
    sjtu_core_group.save
  end
  sjtu_core_gradustes = ['朱雨婷', '曹宇', '李蕊', '谢成', '许海光', '王维', '傅波', '殷丽丽', '姚越越', '王楚妍', '吴冠钰']
  sjtu_core_gradustes.each do |name|
    user = User.where(:name => name).first
    sjtu_core_group.users << user unless user.nil?
  end
end