class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :friendable_id
      t.integer :friend_id
      t.integer :blocker_id
      t.boolean :pending, :default => true
                                                    # Goggles-specific actions:
      t.boolean :shares_passages,  :default => false, :null => false
      t.boolean :shares_trainings, :default => false, :null => false
      t.boolean :shares_calendars, :default => false, :null => false
    end

    add_index :friendships, [:friendable_id, :friend_id], :unique => true
  end

  def self.down
    drop_table :friendships
  end
end
