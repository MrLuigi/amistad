shared_examples_for "a friend model" do
  context "when creating friendships" do
    it "invites other users to friends" do
      expect( @john.invite(@jane) ).to be true
      expect( @victoria.invite(@john) ).to be true
    end

    it "approves only friendships requested by other users" do
      expect( @john.invite(@jane) ).to be true
      expect( @jane.approve(@john) ).to be true
      expect( @victoria.invite(@john) ).to be true
      expect( @john.approve(@victoria) ).to be true
    end

    it "doesn't invite an already invited user" do
      expect( @john.invite(@jane) ).to be true
      expect( @john.invite(@jane) ).to be false
      expect( @jane.invite(@john) ).to be false
    end

    it "doesn't invite an already approved user" do
      expect( @john.invite(@jane) ).to be true
      expect( @jane.approve(@john) ).to be true
      expect( @jane.invite(@john) ).to be false
      expect( @john.invite(@jane) ).to be false
    end

    it "doesn't invite an already blocked user" do
      expect( @john.invite(@jane) ).to be true
      expect( @jane.block(@john) ).to be true
      expect( @jane.invite(@john) ).to be false
      expect( @john.invite(@jane) ).to be false
    end

    it "doesn't approve a self requested friendship" do
      expect( @john.invite(@jane) ).to be true
      expect( @john.approve(@jane) ).to be false
      expect( @victoria.invite(@john) ).to be true
      expect( @victoria.approve(@john) ).to be false
    end

    it "doesn't create a friendship with himself" do
      expect( @john.invite(@john) ).to be false
    end

    it "doesn't approve a non-existent friendship" do
      expect( @peter.approve(@john) ).to be false
    end
  end
  # ---------------------------------------------------------------------------


  context "when listing friendships" do
    before(:each) do
      # John would like to share just the calendars with jane:
      expect( @john.invite(@jane, false, false, true) ).to be true
      # (But janes doesn't approve yet)

      # Peter isn't interested in sharing anything
      expect( @peter.invite(@john) ).to be true
      # (But john doesn't approve yet)

      # John would like to share passages & trainings but not the calendars with james:
      expect( @john.invite(@james, true, true, true) ).to be true
      # For James it's ok to share just the trainings and the calendars with john
      expect( @james.approve(@john, false, true, true) ).to be true

      # Mary would like to share just the passages with john:
      expect( @mary.invite(@john, true) ).to be true
      # ...And John approves.
      expect( @john.approve(@mary, true) ).to be true
    end

    it "lists all the friends" do
      expect( @john.friends ).to include( @mary, @james )
    end

    it "doesn't list non-friended users" do
      expect( @lonely.friends ).to be_empty
      expect( @john.friends ).to include( @mary, @james )
      expect( @john.friends ).not_to include( @peter )
      expect( @john.friends ).not_to include( @lonely )
    end
    # -------------------------------------------------------------------------


    it "Friend#sharing_passages() lists just the friends sharing Passages" do
      expect( @mary.friends_sharing_passages ).to include( @john )
      expect( @john.friends_sharing_passages ).to include( @mary )
    end

    it "Friend#is_sharing_passages_with?() returns true both ways for the friends sharing Passages" do
      expect( @john.is_sharing_passages_with?(@mary) ).to be true
      expect( @mary.is_sharing_passages_with?(@john) ).to be true
    end

    it "Friend#is_sharing_passages_with?() returns false both ways for the friends NOT sharing Passages" do
      expect( @john.is_sharing_passages_with?(@james) ).to be false
      expect( @james.is_sharing_passages_with?(@john) ).to be false
      expect( @john.is_sharing_passages_with?(@victoria) ).to be false
      expect( @victoria.is_sharing_passages_with?(@john) ).to be false
    end

    it "Friend#friends_sharing_trainings() lists just the friends sharing Trainings" do
      expect( @james.friends_sharing_trainings ).to include( @john )
      expect( @john.friends_sharing_trainings ).to include( @james )
    end

    it "Friend#is_sharing_trainings_with?() returns true both ways for the friends sharing Trainings" do
      expect( @james.is_sharing_trainings_with?(@john) ).to be true
      expect( @john.is_sharing_trainings_with?(@james) ).to be true
    end

    it "Friend#is_sharing_trainings_with?() returns false both ways for the friends NOT sharing Trainings" do
      expect( @john.is_sharing_trainings_with?(@mary) ).to be false
      expect( @mary.is_sharing_trainings_with?(@john) ).to be false
      expect( @john.is_sharing_trainings_with?(@victoria) ).to be false
      expect( @victoria.is_sharing_trainings_with?(@john) ).to be false
    end

    it "Friend#friends_sharing_calendars() lists just the friends sharing Calendars" do
      expect( @james.friends_sharing_calendars ).to include( @john )
      expect( @john.friends_sharing_calendars ).to include( @james )
    end

    it "Friend#is_sharing_calendars_with?() returns true both ways for the friends sharing Calendars" do
      expect( @james.is_sharing_calendars_with?(@john) ).to be true
      expect( @john.is_sharing_calendars_with?(@james) ).to be true
    end

    it "Friend#is_sharing_calendars_with?() returns false both ways for the friends NOT sharing Calendars" do
      expect( @john.is_sharing_calendars_with?(@mary) ).to be false
      expect( @mary.is_sharing_calendars_with?(@john) ).to be false
      expect( @john.is_sharing_calendars_with?(@victoria) ).to be false
      expect( @victoria.is_sharing_calendars_with?(@john) ).to be false
    end
    # -------------------------------------------------------------------------


    it "Friend#set_share_passages_with() changes the sharing attribute" do
      expect( @john.is_sharing_passages_with?(@mary) ).to be true
      expect( @mary.set_share_passages_with(@john, false) ).to be true
      # [Steve, 20140319] Reload is not necessary:
#      [@mary, @john].map(&:reload)
      expect( @mary.friends_sharing_passages ).to eq []
      expect( @john.is_sharing_passages_with?(@mary) ).to be false
    end

    it "Friend#set_share_trainings_with() changes the sharing attribute" do
      expect( @john.is_sharing_trainings_with?(@mary) ).to be false
      expect( @mary.set_share_trainings_with(@john) ).to be true
      # [Steve, 20140319] Reload is not necessary:
#      [@mary, @john].map(&:reload)
      expect( @mary.friends_sharing_trainings ).to include( @john )
      expect( @john.is_sharing_trainings_with?(@mary) ).to be true
    end

    it "Friend#set_share_calendar_with() changes the sharing attribute" do
      expect( @john.is_sharing_calendars_with?(@mary) ).to be false
      expect( @mary.set_share_calendar_with(@john) ).to be true
      # [Steve, 20140319] Reload is not necessary:
#      [@mary, @john].map(&:reload)
      expect( @mary.friends_sharing_calendars ).to include( @john )
      expect( @john.is_sharing_calendars_with?(@mary) ).to be true
    end
    # -------------------------------------------------------------------------


    it "lists the friends who invited him" do
      expect( @john.invited_by.to_a ).to eq [@mary]
    end

    it "lists the friends who were invited by him" do
      expect( @john.invited.to_a ).to eq [@james]
    end

    xit "lists the pending friends who invited him" do
      expect( @john.pending_invited_by.to_a ).to eq [@peter]
    end

    xit "lists the pending friends who were invited by him" do
      expect( @john.pending_invited.to_a ).to eq [@jane]
    end

    xit "lists the friends he has in common with another user" do
      expect( @james.common_friends_with(@mary) ).to eq [@john]
    end

    xit "doesn't list the friends he does not have in common" do
      expect( @john.common_friends_with(@mary).size ).to eq(0)
      expect( @john.common_friends_with(@mary) ).not_to include(@james)
      expect( @john.common_friends_with(@peter).size ).to eq(0)
      expect( @john.common_friends_with(@peter) ).not_to include(@jane)
    end

    xit "checks if a user is a friend" do
      expect( @john.friend_with?(@mary) ).to be true
      expect( @mary.friend_with?(@john) ).to be true
      expect( @john.friend_with?(@james) ).to be true
      expect( @james.friend_with?(@john) ).to be true
    end

    xit "checks if a user is not a friend" do
      expect( @john.friend_with?(@jane) ).to be false
      expect( @jane.friend_with?(@john) ).to be false
      expect( @john.friend_with?(@peter) ).to be false
      expect( @peter.friend_with?(@john) ).to be false
    end

    xit "checks if a user has any connections with another user" do
      expect( @john.connected_with?(@jane) ).to be true
      expect( @jane.connected_with?(@john) ).to be true
      expect( @john.connected_with?(@peter) ).to be true
      expect( @peter.connected_with?(@john) ).to be true
    end

    xit "checks if a user does not have any connections with another user" do
      expect( @victoria.connected_with?(@john) ).to be false
      expect( @john.connected_with?(@victoria) ).to be false
    end

    xit "checks if a user was invited by another" do
      expect( @jane.invited_by?(@john) ).to be true
      expect( @james.invited_by?(@john) ).to be true
    end

    xit "checks if a user was not invited by another" do
      expect( @john.invited_by?(@jane) ).to be false
      expect( @victoria.invited_by?(@john) ).to be false
    end

    xit "checks if a user has invited another user" do
      expect( @john.invited?(@jane) ).to be true
      expect( @john.invited?(@james) ).to be true
    end

    xit "checks if a user did not invite another user" do
      expect( @jane.invited?(@john) ).to be false
      expect( @james.invited?(@john) ).to be false
      expect( @john.invited?(@victoria) ).to be false
      expect( @victoria.invited?(@john) ).to be false
    end
  end


  context "when removing friendships" do
    before(:each) do
      expect( @jane.invite(@james) ).to be true
      expect( @james.approve(@jane) ).to be true
      expect( @james.invite(@victoria) ).to be true
      expect( @victoria.approve(@james) ).to be true
      expect( @victoria.invite(@mary) ).to be true
      expect( @mary.approve(@victoria) ).to be true
      expect( @victoria.invite(@john) ).to be true
      expect( @john.approve(@victoria) ).to be true
      expect( @peter.invite(@victoria) ).to be true
      expect( @victoria.invite(@elisabeth) ).to be true
    end

    xit "removes the friends invited by him" do
      expect( @victoria.friends.size ).to eq( 3 )
      expect( @victoria.friends ).to include(@mary)
      expect( @victoria.invited ).to include(@mary)
      expect( @mary.friends.size ).to eq( 1 )
      expect( @mary.friends ).to include(@victoria)
      expect( @mary.invited_by ).to include(@victoria)

      expect( @victoria.remove_friendship(@mary) ).to be true
      expect( @victoria.friends.size ).to eq( 2 )
      expect( @victoria.friends ).not_to include(@mary)
      expect( @victoria.invited ).not_to include(@mary)
      expect( @mary.friends.size ).to eq( 0 )
      expect( @mary.friends ).not_to include(@victoria)
      expect( @mary.invited_by ).not_to include(@victoria)
    end

    xit "removes the friends who invited him" do
      expect( @victoria.friends.size ).to eq( 3 )
      expect( @victoria.friends ).to include(@james)
      expect( @victoria.invited_by ).to include(@james)
      expect( @james.friends.size ).to eq( 2 )
      expect( @james.friends ).to include(@victoria)
      expect( @james.invited ).to include(@victoria)

      expect( @victoria.remove_friendship(@james) ).to be true
      expect( @victoria.friends.size ).to eq( 2 )
      expect( @victoria.friends ).not_to include(@james)
      expect( @victoria.invited_by ).not_to include(@james)
      expect( @james.friends.size ).to eq( 1 )
      expect( @james.friends ).not_to include(@victoria)
      expect( @james.invited ).not_to include(@victoria)
    end

    xit "removes the pending friends invited by him" do
      expect( @victoria.pending_invited.size ).to eq( 1 )
      expect( @victoria.pending_invited ).to include(@elisabeth)
      expect( @elisabeth.pending_invited_by.size ).to eq( 1 )
      expect( @elisabeth.pending_invited_by ).to include(@victoria)
      expect( @victoria.remove_friendship(@elisabeth) ).to be true
      [@victoria, @elisabeth].map(&:reload)
      expect( @victoria.pending_invited.size ).to eq( 0 )
      expect( @victoria.pending_invited ).not_to include(@elisabeth)
      expect( @elisabeth.pending_invited_by.size ).to eq( 0 )
      expect( @elisabeth.pending_invited_by ).not_to include(@victoria)
    end

    xit "removes the pending friends who invited him" do
      expect( @victoria.pending_invited_by.size ).to eq( 1 )
      expect( @victoria.pending_invited_by ).to include(@peter)
      expect( @peter.pending_invited.size ).to eq( 1 )
      expect( @peter.pending_invited ).to include(@victoria)
      expect( @victoria.remove_friendship(@peter) ).to be true
      [@victoria, @peter].map(&:reload)
      expect( @victoria.pending_invited_by.size ).to eq( 0 )
      expect( @victoria.pending_invited_by ).not_to include(@peter)
      expect( @peter.pending_invited.size ).to eq( 0 )
      expect( @peter.pending_invited ).not_to include(@victoria)
    end
  end

  context "when blocking friendships" do
    before(:each) do
      expect( @john.invite(@james) ).to be true
      expect( @james.approve(@john) ).to be true
      expect( @james.block(@john) ).to be true
      expect( @mary.invite(@victoria) ).to be true
      expect( @victoria.approve(@mary) ).to be true
      expect( @victoria.block(@mary) ).to be true
      expect( @victoria.invite(@david) ).to be true
      expect( @david.block(@victoria) ).to be true
      expect( @john.invite(@david) ).to be true
      expect( @david.block(@john) ).to be true
      expect( @peter.invite(@elisabeth) ).to be true
      expect( @elisabeth.block(@peter) ).to be true
      expect( @jane.invite(@john) ).to be true
      expect( @jane.invite(@james) ).to be true
      expect( @james.approve(@jane) ).to be true
      expect( @victoria.invite(@jane) ).to be true
      expect( @victoria.invite(@james) ).to be true
      expect( @james.approve(@victoria) ).to be true
    end

    xit "allows to block author of the invitation by invited user" do
      expect( @john.block(@jane) ).to be true
      expect( @jane.block(@victoria) ).to be true
    end

    xit "doesn't allow to block invited user by invitation author" do
      expect( @jane.block(@john) ).to be false
      expect( @victoria.block(@jane) ).to be false
    end

    xit "allows to block approved users on both sides" do
      expect( @james.block(@jane) ).to be true
      expect( @victoria.block(@james) ).to be true
    end

    xit "doesn't allow to block not connected user" do
      expect( @david.block(@peter) ).to be false
      expect( @peter.block(@david) ).to be false
    end

    xit "doesn't allow to block already blocked user" do
      expect( @john.block(@jane) ).to be true
      expect( @john.block(@jane) ).to be false
      expect( @james.block(@jane) ).to be true
      expect( @james.block(@jane) ).to be false
    end

    xit "lists the blocked users" do
      expect( @jane.blocked ).to be_empty
      expect( @peter.blocked ).to be_empty
      expect( @james.blocked == [@john] ).to be true
      expect( @victoria.blocked == [@mary] ).to be true
      expect( @david.blocked ).to include( @john, @victoria )
    end

    xit "doesn't list blocked users in friends" do
      expect( @james.friends ).to include( @jane, @victoria )
      @james.blocked.each do |user|
        expect( @james.friends ).not_to include(user)
        expect( user.friends ).not_to include(@james)
      end
    end

    xit "doesn't list blocked users in invited" do
      expect( @victoria.invited == [@james] ).to be true
      @victoria.blocked.each do |user|
        expect( @victoria.invited ).not_to include(user)
        expect( user.invited_by ).not_to include(@victoria)
      end
    end

    xit "doesn't list blocked users in invited pending by" do
      expect( @david.pending_invited_by ).to be_empty
      @david.blocked.each do |user|
        expect( @david.pending_invited_by ).not_to include(user)
        expect( user.pending_invited ).not_to include(@david)
      end
    end

    xit "checks if a user is blocked" do
      expect( @james.blocked?(@john) ).to be true
      expect( @victoria.blocked?(@mary) ).to be true
      expect( @david.blocked?(@john) ).to be true
      expect( @david.blocked?(@victoria) ).to be true
    end
  end

  context "when unblocking friendships" do
    before(:each) do
      expect( @john.invite(@james) ).to be true
      expect( @james.approve(@john) ).to be true
      expect( @john.block(@james) ).to be true
      expect( @john.unblock(@james) ).to be true
      expect( @mary.invite(@victoria) ).to be true
      expect( @victoria.approve(@mary) ).to be true
      expect( @victoria.block(@mary) ).to be true
      expect( @victoria.unblock(@mary) ).to be true
      expect( @victoria.invite(@david) ).to be true
      expect( @david.block(@victoria) ).to be true
      expect( @david.unblock(@victoria) ).to be true
      expect( @john.invite(@david) ).to be true
      expect( @david.block(@john) ).to be true
      expect( @peter.invite(@elisabeth) ).to be true
      expect( @elisabeth.block(@peter) ).to be true
      expect( @jane.invite(@john) ).to be true
      expect( @jane.invite(@james) ).to be true
      expect( @james.approve(@jane) ).to be true
      expect( @victoria.invite(@jane) ).to be true
      expect( @victoria.invite(@james) ).to be true
      expect( @james.approve(@victoria) ).to be true
    end

    xit "allows to unblock prevoiusly blocked user" do
      expect( @david.unblock(@john) ).to be true
      expect( @elisabeth.unblock(@peter) ).to be true
    end

    xit "doesn't allow to unblock not prevoiusly blocked user" do
      expect( @john.unblock(@jane) ).to be false
      expect( @james.unblock(@jane) ).to be false
      expect( @victoria.unblock(@jane) ).to be false
      expect( @james.unblock(@victoria) ).to be false
    end

    xit "doesn't allow to unblock blocked user by himself" do
      expect( @john.unblock(@david) ).to be false
      expect( @peter.unblock(@elisabeth) ).to be false
    end

    xit "lists unblocked users in friends" do
      expect( @john.friends == [@james] ).to be true
      expect( @mary.friends == [@victoria] ).to be true
      expect( @victoria.friends ).to include( @mary, @james )
      expect( @james.friends ).to include( @john, @jane, @victoria )
    end

    xit "lists unblocked users in invited" do
      expect( @john.invited == [@james] ).to be true
      expect( @mary.invited ).to == [@victoria]
    end

    xit "lists unblocked users in invited by" do
      expect( @victoria.invited_by == [@mary] ).to be true
      expect( @james.invited_by ).to include( @john, @jane, @victoria )
    end

    xit "lists unblocked users in pending invited" do
      expect( @victoria.pending_invited ).to include( @jane, @david )
    end

    xit "lists unblocked users in pending invited by" do
      expect( @david.pending_invited_by ).to eq [@victoria]
    end
  end

  context "when counting friendships and blocks" do
    before do
      expect( @john.invite(@james) ).to be true
      expect( @james.approve(@john) ).to be true

      expect( @john.invite(@victoria) ).to be true
      expect( @victoria.approve(@john) ).to be true

      expect( @elisabeth.invite(@john) ).to be true
      expect( @john.approve(@elisabeth) ).to be true

      expect( @victoria.invite(@david) ).to be true
      expect( @david.block(@victoria) ).to be true

      expect( @mary.invite(@victoria) ).to be true
      expect( @victoria.block(@mary) ).to be true
    end

    xit "returns the correct count for total_friends" do
      expect( @john.total_friends == 3 ).to be true
      expect( @elisabeth.total_friends == 1 ).to be true
      expect( @james.total_friends == 1 ).to be true
      expect( @victoria.total_friends == 1 ).to be true
    end

    xit "returns the correct count for total_blocked" do
      expect( @david.total_blocked == 1 ).to be true
      expect( @victoria.total_blocked == 1 ).to be true
    end
  end
end
