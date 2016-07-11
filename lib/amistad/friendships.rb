module Amistad
  module Friendships
    if Object.const_defined? :ActiveRecord
      const_set Amistad.friendship_model, Class.new(ActiveRecord::Base)
      const_get(Amistad.friendship_model.to_sym).class_exec do
        include Amistad::FriendshipModel
        self.table_name = 'friendships'
      end
    else
      raise "Amistad 'version5' only supports ActiveRecord"
    end
  end
end
