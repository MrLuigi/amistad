shared_examples_for "the friendship model" do
  it "validates the presence of the user's id and the friend's id" do
    friendship = Amistad.friendship_class.new
    expect( friendship.valid? ).to be false
    expect( friendship.errors ).to include(:friendable_id)
    expect( friendship.errors ).to include(:friend_id)
    expect( friendship.errors.size ).to eq( 2 )
  end

  context "when creating friendship" do
    before do
      @jane.invite(@david)
      @friendship = Amistad.friendship_class.first
    end

    it "is pending" do
      expect( @friendship.pending? ).to be true
    end

    it "isn't approved" do
      expect( @friendship.approved? ).to be false
    end

    it "is active" do
      expect( @friendship.active? ).to be true
    end

    it "isn't blocked" do
      expect( @friendship.blocked? ).to be false
    end

    it "is available for blocking only by invited user" do
      expect( @friendship.can_block?(@david) ).to be true
      expect( @friendship.can_block?(@jane) ).to be false
    end

    it "isn't available for unblocking" do
      expect( @friendship.can_unblock?(@jane) ).to be false
      expect( @friendship.can_unblock?(@david) ).to be false
    end
  end

  context "when approving friendship" do
    before do
      @jane.invite(@david)
      @david.approve(@jane)
      @friendship = Amistad.friendship_class.first
    end

    it "is approved" do
      expect( @friendship.approved? ).to be true
    end

    it "isn't pending" do
      expect( @friendship.pending? ).to be false
    end

    it "is active" do
      expect( @friendship.active? ).to be true
    end

    it "isn't blocked" do
      expect( @friendship.blocked? ).to be false
    end

    it "doesn't allow any sharing by default" do
      expect( @friendship.shares_passages ).to be false
      expect( @friendship.shares_trainings ).to be false
      expect( @friendship.shares_calendars ).to be false
    end

    it "is available for blocking by both users" do
      expect( @friendship.can_block?(@jane) ).to be true
      expect( @friendship.can_block?(@david) ).to be true
    end

    it "isn't available for unblocking" do
      expect( @friendship.can_unblock?(@jane) ).to be false
      expect( @friendship.can_unblock?(@david) ).to be false
    end
  end

  context "when blocking friendship" do
    before do
      @jane.invite(@david)
      @david.block(@jane)
      @friendship = Amistad.friendship_class.first
    end

    it "isn't approved" do
      expect( @friendship.approved? ).to be false
    end

    it "is pending" do
      expect( @friendship.pending? ).to be true
    end

    it "isn't active" do
      expect( @friendship.active? ).to be false
    end

    it "is blocked" do
      expect( @friendship.blocked? ).to be true
    end

    it "isn't available for blocking" do
      expect( @friendship.can_block?(@jane) ).to be false
      expect( @friendship.can_block?(@david) ).to be false
    end

    it "is available for unblocking only by the user who blocked it" do
      expect( @friendship.can_unblock?(@david) ).to be true
      expect( @friendship.can_unblock?(@jane) ).to be false
    end
  end
end