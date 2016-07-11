#require 'squeel'

module Amistad
  module ActiveRecordFriendModel
    extend ActiveSupport::Concern

    included do
      #####################################################################################
      # friendships
      #####################################################################################
      has_many  :friendships,
        class_name: "Amistad::Friendships::#{ Amistad.friendship_model }",
        foreign_key: "friendable_id"

      has_many  :pending_invited,
        through: :friendships,
        source: :friend,
        conditions: { :'friendships.pending' => true, :'friendships.blocker_id' => nil }

      has_many  :invited,
        through: :friendships,
        source: :friend,
        conditions: { :'friendships.pending' => false, :'friendships.blocker_id' => nil }

      #####################################################################################
      # inverse friendships
      #####################################################################################
      has_many  :inverse_friendships,
        class_name: "Amistad::Friendships::#{ Amistad.friendship_model }",
        foreign_key: "friend_id"

      has_many  :pending_invited_by,
        through: :inverse_friendships,
        source: :friendable,
        conditions: { :'friendships.pending' => true, :'friendships.blocker_id' => nil }

      has_many  :invited_by,
        through: :inverse_friendships,
        source: :friendable,
        conditions: { :'friendships.pending' => false, :'friendships.blocker_id' => nil }

      #####################################################################################
      # blocked friendships
      #####################################################################################
      has_many  :blocked_friendships,
        class_name: "Amistad::Friendships::#{ Amistad.friendship_model }",
        foreign_key: "blocker_id"

      has_many  :blockades,
        through: :blocked_friendships,
        source: :friend,
        conditions: "friend_id <> blocker_id"

      has_many  :blockades_by,
        through: :blocked_friendships,
        source: :friendable,
        conditions: "friendable_id <> blocker_id"
    end
    # -------------------------------------------------------------------------


    # Suggest a user to become a friend. If the operation succeeds, the method returns true, else false.
    #
    # The "requestee" friendable can also set the requested sharing attributes which
    # will then either be confirmed (set to true) or denied (set to false) during the approval process.
    #
    def invite(user, shares_passages = false, shares_trainings = false, shares_calendars = false)
      return false if user == self || find_any_friendship_with(user)
      new_invitation = Amistad.friendship_class.new do |f|
        f.friendable = self
        f.friend = user
        f.shares_passages  = shares_passages
        f.shares_trainings = shares_trainings
        f.shares_calendars = shares_calendars
      end
# DEBUG
#      puts "\r\n#{new_invitation.inspect}"
      new_invitation.save
    end
    # -------------------------------------------------------------------------


    # Approve a friendship invitation. If the operation succeeds, the method returns true, else false.
    #
    # The friend approving a friendship request can only set sharing attributes
    # to true if the "requestee" friendable asked for it, setting them previously
    # with an invite request.
    # Otherwise, set the sharing attributes using their dedicated setter methods.
    # (#set_share_passages_with, #set_share_trainings_with, #set_share_calendar_with)
    #
    def approve(user, shares_passages = false, shares_trainings = false, shares_calendars = false)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil? || invited?(user)
      # To confirm an attribute to true it must be previously set to true during
      # the invite request: (to avoid lax-setting of sharing attributes during the approval process)
      friendship.shares_passages  = friendship.shares_passages  && shares_passages
      friendship.shares_trainings = friendship.shares_trainings && shares_trainings
      friendship.shares_calendars = friendship.shares_calendars && shares_calendars
      friendship.pending = false
      friendship.save
    end
    # -------------------------------------------------------------------------


    # deletes a friendship
    def remove_friendship(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.destroy
      self.reload && user.reload if friendship.destroyed?
    end


    # Override to check for specific Friend-identity equivalence among
    # different classes that are both including the Friend model.
    # Only <tt>:id</tt> and <tt>:name</tt> are checked for equivalence.
    def ==(other_friend)
      return false unless other_friend.respond_to?(:id) && other_friend.respond_to?(:name)
      (self.id == other_friend.id) && (self.name == other_friend.name)
    end
    # -------------------------------------------------------------------------


    # Returns the list of approved friends.
    #
    # Set <tt>filter_passage_share</tt>, <tt>filter_training_share</tt> and <tt>filter_calendar_share</tt>
    # to either +true+ or +false+ (instead of +nil+ = 'do not care') to retrieve only friendship having
    # the specified sharing attribute values.
    #
    def friends( filter_passage_share = nil, filter_training_share = nil, filter_calendar_share = nil )
      friendship_model = Amistad::Friendships.const_get( :"#{Amistad.friendship_model}" )

      where_condition_array = prepare_where_condition_for_shareables(
        "friendable_id = ? AND pending = ? AND blocker_id IS NULL",
        filter_passage_share,
        filter_training_share,
        filter_calendar_share
      )
      approved_friendships = friendship_model.where( where_condition_array )
# DEBUG
#      puts "\r\n- approved_friendships...: #{ approved_friendships.map{ |row| row.id }.inspect }"
#      puts "  for friend_id..............: #{ approved_friendships.map{ |row| row.friend_id }.inspect }"
#      puts "  for friendable_id..........: #{ approved_friendships.map{ |row| row.friendable_id }.inspect }"

      where_condition_array = prepare_where_condition_for_shareables(
        "friend_id = ? AND pending = ? AND blocker_id IS NULL",
        filter_passage_share,
        filter_training_share,
        filter_calendar_share
      )
      approved_inverse_friendships = friendship_model.where( where_condition_array )
# DEBUG
#      puts "- approved_inverse_friendships...: #{ approved_inverse_friendships.map{ |row| row.id }.inspect }"
#      puts "  for friend_id..................: #{ approved_inverse_friendships.map{ |row| row.friend_id }.inspect }"
#      puts "  for friendable_id..............: #{ approved_inverse_friendships.map{ |row| row.friendable_id }.inspect }"

      allowed_ids = approved_friendships.select( :friend_id ).map{ |row| row.friend_id }
      allowed_ids += approved_inverse_friendships.select( :friendable_id ).map{ |row| row.friendable_id }
# DEBUG
#      puts "- Allowed IDS: #{ allowed_ids }"
      if allowed_ids.size > 0
        self.class.where( ["id IN (?)", allowed_ids] )
      else # We must return an empty ActiveRecord::Relation:
        self.class.where( "id = -1" )
      end
    end
    # -------------------------------------------------------------------------


    # Returns the list of approved friends which are also sharing their "Passages"
    def friends_sharing_passages
      friends( true )
    end

    # Returns the list of approved friends which are also sharing their "Trainings"
    def friends_sharing_trainings
      friends( nil, true )
    end

    # Returns the list of approved friends which are also sharing their "Calendars"
    def friends_sharing_calendars
      friends( nil, nil, true )
    end
    # -------------------------------------------------------------------------


    # total # of invited and invited_by without association loading
    def total_friends
      self.invited(false).count + self.invited_by(false).count
    end

    # blocks a friendship
    def block(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil? || !friendship.can_block?(self)
      friendship.update_attribute(:blocker, self)
    end

    # unblocks a friendship
    def unblock(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil? || !friendship.can_unblock?(self)
      friendship.update_attribute(:blocker, nil)
    end
    # -------------------------------------------------------------------------


    # Toggles sharing of "Passages" for a certain user friend
    def set_share_passages_with( user, is_enabled = true )
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.update_attribute(:shares_passages, is_enabled)
    end

    # Toggles sharing of "Trainings" for a certain user friend
    def set_share_trainings_with( user, is_enabled = true )
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.update_attribute(:shares_trainings, is_enabled)
    end

    # Toggles sharing of "Calendars" for a certain user friend
    def set_share_calendar_with( user, is_enabled = true )
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.update_attribute(:shares_calendars, is_enabled)
    end
    # -------------------------------------------------------------------------


    # returns the list of blocked friends
    def blocked
      self.reload
      self.blockades + self.blockades_by
    end

    # total # of blockades and blockedes_by without association loading
    def total_blocked
      self.blockades(false).count + self.blockades_by(false).count
    end

    # checks if a user is blocked
    def blocked?(user)
      blocked.include?(user)
    end


    # checks if a user is a friend
    def friend_with?(user)
      friends.include?(user)
    end
    # -------------------------------------------------------------------------


    # Checks if this instance is allowing a user to access its "Passages" or vice-versa.
    # Works both ways (for friend/"acceptee" and friendable/"requestee").
    # Returns true or false.
    def is_sharing_passages_with?(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.shares_passages && (
        (friendship.friend_id == user.id) || (friendship.friendable_id == user.id)
      )
    end

    # Checks if this instance is allowing a user to access its "Trainings" or vice-versa.
    # Works both ways (for friend/"acceptee" and friendable/"requestee").
    # Returns true or false.
    def is_sharing_trainings_with?(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.shares_trainings && (
        (friendship.friend_id == user.id) || (friendship.friendable_id == user.id)
      )
    end

    # Checks if this instance is allowing a user to access its "Calendars" or vice-versa.
    # Works both ways (for friend/"acceptee" and friendable/"requestee").
    # Returns true or false.
    def is_sharing_calendars_with?(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.shares_calendars && (
        (friendship.friend_id == user.id) || (friendship.friendable_id == user.id)
      )
    end
    # -------------------------------------------------------------------------


    # checks if a current user is connected to given user
    def connected_with?(user)
      find_any_friendship_with(user).present?
    end

    # checks if a current user received invitation from given user
    def invited_by?(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.friendable_id == user.id
    end

    # checks if a current user invited given user
    def invited?(user)
      friendship = find_any_friendship_with(user)
      return false if friendship.nil?
      friendship.friend_id == user.id
    end

    # return the list of the ones among its friends which are also friend with the given user
    def common_friends_with(user)
      self.friends & user.friends
    end

    # returns friendship with given user or nil
    def find_any_friendship_with(user)
      friendship = Amistad.friendship_class.where(
        friendable_id: self.id, friend_id: user.id
      ).first
      if friendship.nil?
        friendship = Amistad.friendship_class.where(
          friendable_id: user.id,
          friend_id: self.id
        ).first
      end
      friendship
    end


    private


    # Returns an ActiveRecord array of conditions, for custom shareables.
    def prepare_where_condition_for_shareables( where_text, filter_passage_share = nil, filter_training_share = nil, filter_calendar_share = nil )
      where_values = [ self.id, false ]
      unless filter_passage_share.nil?
        where_text   << " AND shares_passages = ?"
        where_values << filter_passage_share
      end
      unless filter_training_share.nil?
        where_text   << " AND shares_trainings = ?"
        where_values << filter_training_share
      end
      unless filter_calendar_share.nil?
        where_text   << " AND shares_calendars = ?"
        where_values << filter_calendar_share
      end
      [ where_text ] + where_values
    end
  end
end
