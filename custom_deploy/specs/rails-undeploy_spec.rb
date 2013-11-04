require 'minitest/spec'

describe_recipe 'custom_deploy::rails-undeploy' do
  include MiniTest::Chef::Resources
  include MiniTest::Chef::Assertions

end
