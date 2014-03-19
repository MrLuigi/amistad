shared_examples_for "a friend model" do
  context "when creating friendships" do
    it "should invite other users to friends" do
      @john.invite(@jane).should be_true
      @victoria.invite(@john).should be_true
    end

    it "should approve only friendships requested by other users" do
      @john.invite(@jane).should be_true
      @jane.approve(@john).should be_true
      @victoria.invite(@john).should be_true
      @john.approve(@victoria).should be_true
    end

    it "should not invite an already invited user" do
      @john.invite(@jane).should be_true
      @john.invite(@jane).should be_false
      @jane.invite(@john).should be_false
    end

    it "should not invite an already approved user" do
      @john.invite(@jane).should be_true
      @jane.approve(@john).should be_true
      @jane.invite(@john).should be_false
      @john.invite(@jane).should be_false
    end

    it "should not invite an already blocked user" do
      @john.invite(@jane).should be_true
      @jane.block(@john).should be_true
      @jane.invite(@john).should be_false
      @john.invite(@jane).should be_false
    end

    it "should not approve a self requested friendship" do
      @john.invite(@jane).should be_true
      @john.approve(@jane).should be_false
      @victoria.invite(@john).should be_true
      @victoria.approve(@john).should be_false
    end

    it "should not create a friendship with himself" do
      @john.invite(@john).should be_false
    end

    it "should not approve a non-existent friendship" do
      @peter.approve(@john).should be_false
    end
  end
  # ---------------------------------------------------------------------------


  context "when listing friendships" do
    before(:each) do
      # John would like to share just the calendars with jane:
      @john.invite(@jane, false, false, true).should be_true
      # (But janes doesn't approve yet)

      # Peter isn't interested in sharing anything
      @peter.invite(@john).should be_true
      # (But john doesn't approve yet)

      # John would like to share passages & trainings but not the calendars with james:
      @john.invite(@james, true, true, true).should be_true
      # For James it's ok to share just the trainings and the calendars with john
      @james.approve(@john, false, true, true).should be_true

      # Mary would like to share just the passages with john:
      @mary.invite(@john, true).should be_true
      # ...And John approves.
      @john.approve(@mary, true).should be_true
    end

    it "should list all the friends" do
      @john.friends.should =~ [@mary, @james]
    end

    it "should not list non-friended users" do
      @victoria.friends.should be_empty
      @john.friends.should =~ [@mary, @james]
      @john.friends.should_not include(@peter)
      @john.friends.should_not include(@victoria)
    end
    # -------------------------------------------------------------------------


    it "Friend#sharing_passages() should list just the friends sharing Passages" do
      @mary.friends_sharing_passages.should =~ [@john]
      @john.friends_sharing_passages.should =~ [@mary]
    end

    it "Friend#is_sharing_passages_with?() should return true both ways for the friends sharing Passages" do
      expect( @john.is_sharing_passages_with?(@mary) ).to be_true
      expect( @mary.is_sharing_passages_with?(@john) ).to be_true
    end

    it "Friend#is_sharing_passages_with?() should return false both ways for the friends NOT sharing Passages" do
      expect( @john.is_sharing_passages_with?(@james) ).to be_false
      expect( @james.is_sharing_passages_with?(@john) ).to be_false
      expect( @john.is_sharing_passages_with?(@victoria) ).to be_false
      expect( @victoria.is_sharing_passages_with?(@john) ).to be_false
    end

    it "Friend#friends_sharing_trainings() should list just the friends sharing Trainings" do
      @james.friends_sharing_trainings.should =~ [@john]
      @john.friends_sharing_trainings.should =~ [@james]
    end

    it "Friend#is_sharing_trainings_with?() should return true both ways for the friends sharing Trainings" do
      expect( @james.is_sharing_trainings_with?(@john) ).to be_true
      expect( @john.is_sharing_trainings_with?(@james) ).to be_true
    end

    it "Friend#is_sharing_trainings_with?() should return false both ways for the friends NOT sharing Trainings" do
      expect( @john.is_sharing_trainings_with?(@mary) ).to be_false
      expect( @mary.is_sharing_trainings_with?(@john) ).to be_false
      expect( @john.is_sharing_trainings_with?(@victoria) ).to be_false
      expect( @victoria.is_sharing_trainings_with?(@john) ).to be_false
    end

    it "Friend#friends_sharing_calendars() should list just the friends sharing Calendars" do
      @james.friends_sharing_calendars.should =~ [@john]
      @john.friends_sharing_calendars.should =~ [@james]
    end

    it "Friend#is_sharing_calendars_with?() should return true both ways for the friends sharing Calendars" do
      expect( @james.is_sharing_calendars_with?(@john) ).to be_true
      expect( @john.is_sharing_calendars_with?(@james) ).to be_true
    end

    it "Friend#is_sharing_calendars_with?() should return false both ways for the friends NOT sharing Calendars" do
      expect( @john.is_sharing_calendars_with?(@mary) ).to be_false
      expect( @mary.is_sharing_calendars_with?(@john) ).to be_false
      expect( @john.is_sharing_calendars_with?(@victoria) ).to be_false
      expect( @victoria.is_sharing_calendars_with?(@john) ).to be_false
    end
    # -------------------------------------------------------------------------


    it "Friend#set_share_passages_with() should change the sharing attribute" do
      expect( @john.is_sharing_passages_with?(@mary) ).to be_true
      expect( @mary.set_share_passages_with(@john, false) ).to be_true
      # [Steve, 20140319] Reload is not necessary:
#      [@mary, @john].map(&:reload)
      @mary.friends_sharing_passages.should =~ []
      expect( @john.is_sharing_passages_with?(@mary) ).to be_false
    end

    it "Friend#set_share_trainings_with() should change the sharing attribute" do
      expect( @john.is_sharing_trainings_with?(@mary) ).to be_false
      expect( @mary.set_share_trainings_with(@john) ).to be_true
      # [Steve, 20140319] Reload is not necessary:
#      [@mary, @john].map(&:reload)
      @mary.friends_sharing_trainings.should =~ [@john]
      expect( @john.is_sharing_trainings_with?(@mary) ).to be_true
    end

    it "Friend#set_share_calendar_with() should change the sharing attribute" do
      expect( @john.is_sharing_calendars_with?(@mary) ).to be_false
      expect( @mary.set_share_calendar_with(@john) ).to be_true
      # [Steve, 20140319] Reload is not necessary:
#      [@mary, @john].map(&:reload)
      @mary.friends_sharing_calendars.should =~ [@john]
      expect( @john.is_sharing_calendars_with?(@mary) ).to be_true
    end
    # -------------------------------------------------------------------------


    it "should list the friends who invited him" do
      @john.invited_by.should == [@mary]
    end

    it "should list the friends who were invited by him" do
      @john.invited.should == [@james]
    end

    it "should list the pending friends who invited him" do
      @john.pending_invited_by.should == [@peter]
    end

    it "should list the pending friends who were invited by him" do
      @john.pending_invited.should == [@jane]
    end

    it "should list the friends he has in common with another user" do
      @james.common_friends_with(@mary).should == [@john]
    end

    it "should not list the friends he does not have in common" do
      expect( @john.common_friends_with(@mary) ).to have(0).items
      @john.common_friends_with(@mary).should_not include(@james)
      expect( @john.common_friends_with(@peter) ).to have(0).items
      @john.common_friends_with(@peter).should_not include(@jane)
    end

    it "should check if a user is a friend" do
      @john.friend_with?(@mary).should be_true
      @mary.friend_with?(@john).should be_true
      @john.friend_with?(@james).should be_true
      @james.friend_with?(@john).should be_true
    end

    it "should check if a user is not a friend" do
      @john.friend_with?(@jane).should be_false
      @jane.friend_with?(@john).should be_false
      @john.friend_with?(@peter).should be_false
      @peter.friend_with?(@john).should be_false
    end

    it "should check if a user has any connections with another user" do
      @john.connected_with?(@jane).should be_true
      @jane.connected_with?(@john).should be_true
      @john.connected_with?(@peter).should be_true
      @peter.connected_with?(@john).should be_true
    end

    it "should check if a user does not have any connections with another user" do
      @victoria.connected_with?(@john).should be_false
      @john.connected_with?(@victoria).should be_false
    end

    it "should check if a user was invited by another" do
      @jane.invited_by?(@john).should be_true
      @james.invited_by?(@john).should be_true
    end

    it "should check if a user was not invited by another" do
      @john.invited_by?(@jane).should be_false
      @victoria.invited_by?(@john).should be_false
    end

    it "should check if a user has invited another user" do
      @john.invited?(@jane).should be_true
      @john.invited?(@james).should be_true
    end

    it "should check if a user did not invite another user" do
      @jane.invited?(@john).should be_false
      @james.invited?(@john).should be_false
      @john.invited?(@victoria).should be_false
      @victoria.invited?(@john).should be_false
    end
  end

  context "when removing friendships" do
    before(:each) do
      @jane.invite(@james).should be_true
      @james.approve(@jane).should be_true
      @james.invite(@victoria).should be_true
      @victoria.approve(@james).should be_true
      @victoria.invite(@mary).should be_true
      @mary.approve(@victoria).should be_true
      @victoria.invite(@john).should be_true
      @john.approve(@victoria).should be_true
      @peter.invite(@victoria).should be_true
      @victoria.invite(@elisabeth).should be_true
    end

    it "should remove the friends invited by him" do
      expect( @victoria.friends ).to have(3).items
      @victoria.friends.should include(@mary)
      @victoria.invited.should include(@mary)
      expect( @mary.friends ).to have(1).items
      @mary.friends.should include(@victoria)
      @mary.invited_by.should include(@victoria)

      @victoria.remove_friendship(@mary).should be_true
      expect( @victoria.friends ).to have(2).items
      @victoria.friends.should_not include(@mary)
      @victoria.invited.should_not include(@mary)
      expect( @mary.friends ).to have(0).items
      @mary.friends.should_not include(@victoria)
      @mary.invited_by.should_not include(@victoria)
    end

    it "should remove the friends who invited him" do
      expect( @victoria.friends ).to have(3).items
      @victoria.friends.should include(@james)
      @victoria.invited_by.should include(@james)
      expect( @james.friends ).to have(2).items
      @james.friends.should include(@victoria)
      @james.invited.should include(@victoria)

      @victoria.remove_friendship(@james).should be_true
      expect( @victoria.friends ).to have(2).items
      @victoria.friends.should_not include(@james)
      @victoria.invited_by.should_not include(@james)
      expect( @james.friends ).to have(1).items
      @james.friends.should_not include(@victoria)
      @james.invited.should_not include(@victoria)
    end

    it "should remove the pending friends invited by him" do
      expect( @victoria.pending_invited ).to have(1).items
      @victoria.pending_invited.should include(@elisabeth)
      expect( @elisabeth.pending_invited_by ).to have(1).items
      @elisabeth.pending_invited_by.should include(@victoria)
      @victoria.remove_friendship(@elisabeth).should be_true
      [@victoria, @elisabeth].map(&:reload)
      expect( @victoria.pending_invited ).to have(0).items
      @victoria.pending_invited.should_not include(@elisabeth)
      expect( @elisabeth.pending_invited_by ).to have(0).items
      @elisabeth.pending_invited_by.should_not include(@victoria)
    end

    it "should remove the pending friends who invited him" do
      expect( @victoria.pending_invited_by ).to have(1).items
      @victoria.pending_invited_by.should include(@peter)
      expect( @peter.pending_invited ).to have(1).items
      @peter.pending_invited.should include(@victoria)
      @victoria.remove_friendship(@peter).should be_true
      [@victoria, @peter].map(&:reload)
      expect( @victoria.pending_invited_by ).to have(0).items
      @victoria.pending_invited_by.should_not include(@peter)
      expect( @peter.pending_invited ).to have(0).items
      @peter.pending_invited.should_not include(@victoria)
    end
  end

  context "when blocking friendships" do
    before(:each) do
      @john.invite(@james).should be_true
      @james.approve(@john).should be_true
      @james.block(@john).should be_true
      @mary.invite(@victoria).should be_true
      @victoria.approve(@mary).should be_true
      @victoria.block(@mary).should be_true
      @victoria.invite(@david).should be_true
      @david.block(@victoria).should be_true
      @john.invite(@david).should be_true
      @david.block(@john).should be_true
      @peter.invite(@elisabeth).should be_true
      @elisabeth.block(@peter).should be_true
      @jane.invite(@john).should be_true
      @jane.invite(@james).should be_true
      @james.approve(@jane).should be_true
      @victoria.invite(@jane).should be_true
      @victoria.invite(@james).should be_true
      @james.approve(@victoria).should be_true
    end

    it "should allow to block author of the invitation by invited user" do
      @john.block(@jane).should be_true
      @jane.block(@victoria).should be_true
    end

    it "should not allow to block invited user by invitation author" do
      @jane.block(@john).should be_false
      @victoria.block(@jane).should be_false
    end

    it "should allow to block approved users on both sides" do
      @james.block(@jane).should be_true
      @victoria.block(@james).should be_true
    end

    it "should not allow to block not connected user" do
      @david.block(@peter).should be_false
      @peter.block(@david).should be_false
    end

    it "should not allow to block already blocked user" do
      @john.block(@jane).should be_true
      @john.block(@jane).should be_false
      @james.block(@jane).should be_true
      @james.block(@jane).should be_false
    end

    it "should list the blocked users" do
      @jane.blocked.should be_empty
      @peter.blocked.should be_empty
      expect( @james.blocked == [@john] ).to be_true
      expect( @victoria.blocked == [@mary] ).to be_true
      @david.blocked.should =~ [@john, @victoria]
    end

    it "should not list blocked users in friends" do
      @james.friends.should =~ [@jane, @victoria]
      @james.blocked.each do |user|
        @james.friends.should_not include(user)
        user.friends.should_not include(@james)
      end
    end

    it "should not list blocked users in invited" do
      expect( @victoria.invited == [@james] ).to be_true
      @victoria.blocked.each do |user|
        @victoria.invited.should_not include(user)
        user.invited_by.should_not include(@victoria)
      end
    end

    it "should not list blocked users in invited pending by" do
      @david.pending_invited_by.should be_empty
      @david.blocked.each do |user|
        @david.pending_invited_by.should_not include(user)
        user.pending_invited.should_not include(@david)
      end
    end

    it "should check if a user is blocked" do
      @james.blocked?(@john).should be_true
      @victoria.blocked?(@mary).should be_true
      @david.blocked?(@john).should be_true
      @david.blocked?(@victoria).should be_true
    end
  end

  context "when unblocking friendships" do
    before(:each) do
      @john.invite(@james).should be_true
      @james.approve(@john).should be_true
      @john.block(@james).should be_true
      @john.unblock(@james).should be_true
      @mary.invite(@victoria).should be_true
      @victoria.approve(@mary).should be_true
      @victoria.block(@mary).should be_true
      @victoria.unblock(@mary).should be_true
      @victoria.invite(@david).should be_true
      @david.block(@victoria).should be_true
      @david.unblock(@victoria).should be_true
      @john.invite(@david).should be_true
      @david.block(@john).should be_true
      @peter.invite(@elisabeth).should be_true
      @elisabeth.block(@peter).should be_true
      @jane.invite(@john).should be_true
      @jane.invite(@james).should be_true
      @james.approve(@jane).should be_true
      @victoria.invite(@jane).should be_true
      @victoria.invite(@james).should be_true
      @james.approve(@victoria).should be_true
    end

    it "should allow to unblock prevoiusly blocked user" do
      @david.unblock(@john).should be_true
      @elisabeth.unblock(@peter).should be_true
    end

    it "should not allow to unblock not prevoiusly blocked user" do
      @john.unblock(@jane).should be_false
      @james.unblock(@jane).should be_false
      @victoria.unblock(@jane).should be_false
      @james.unblock(@victoria).should be_false
    end

    it "should not allow to unblock blocked user by himself" do
      @john.unblock(@david).should be_false
      @peter.unblock(@elisabeth).should be_false
    end

    it "should list unblocked users in friends" do
      expect( @john.friends == [@james] ).to be_true
      expect( @mary.friends == [@victoria] ).to be_true
      @victoria.friends.should =~ [@mary, @james]
      @james.friends.should =~ [@john, @jane, @victoria]
    end

    it "should list unblocked users in invited" do
      expect( @john.invited == [@james] ).to be_true
      @mary.invited.should == [@victoria]
    end

    it "should list unblocked users in invited by" do
      expect( @victoria.invited_by == [@mary] ).to be_true
      @james.invited_by.should =~ [@john, @jane, @victoria]
    end

    it "should list unblocked users in pending invited" do
      @victoria.pending_invited.should =~ [@jane, @david]
    end

    it "should list unblocked users in pending invited by" do
      @david.pending_invited_by.should == [@victoria]
    end
  end

  context "when counting friendships and blocks" do
    before do
      @john.invite(@james).should be_true
      @james.approve(@john).should be_true

      @john.invite(@victoria).should be_true
      @victoria.approve(@john).should be_true

      @elisabeth.invite(@john).should be_true
      @john.approve(@elisabeth).should be_true

      @victoria.invite(@david).should be_true
      @david.block(@victoria).should be_true

      @mary.invite(@victoria).should be_true
      @victoria.block(@mary).should be_true
    end

    it "should return the correct count for total_friends" do
      expect( @john.total_friends == 3 ).to be_true
      expect( @elisabeth.total_friends == 1 ).to be_true
      expect( @james.total_friends == 1 ).to be_true
      expect( @victoria.total_friends == 1 ).to be_true
    end

    it "should return the correct count for total_blocked" do
      expect( @david.total_blocked == 1 ).to be_true
      expect( @victoria.total_blocked == 1 ).to be_true
    end
  end
end
