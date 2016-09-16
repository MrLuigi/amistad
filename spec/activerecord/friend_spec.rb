require File.dirname(__FILE__) + "/activerecord_spec_helper"

describe "The friend model" do
  before(:all) do
    reload_environment
    User = Class.new(ActiveRecord::Base)

    # [Steve, 20160916] No need to protect from mass-assignment each attribute since this is the default for Rails 4+
#    ActiveSupport.on_load(:active_record) do
#      attr_accessible(nil)
#    end
  end

  it_behaves_like "friend with parameterized models" do
    let(:friend_model_param) { User }
  end
end
