module Amistad
  module FriendModel
    def self.included(receiver)
      if receiver.ancestors.map(&:to_s).include?("ActiveRecord::Base")
        receiver.class_exec do
          include Amistad::ActiveRecordFriendModel
        end
      else
        raise "Amistad 'version5' only supports ActiveRecord"
      end
    end
  end
end
