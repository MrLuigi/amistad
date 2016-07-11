require File.dirname(__FILE__) + "/activerecord_spec_helper"

describe 'Amistad friendship model' do

  before(:all) do
    reload_environment
    User = Class.new(ActiveRecord::Base)
    activate_amistad(User)
    create_users(User)
  end

  it_behaves_like "the friendship model"
end
