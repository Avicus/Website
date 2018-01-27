# User controller actions that handle all aspects of friendship.
module Users::FriendActions
  def friends
    @friends = @user.friends.dup.to_a

    @online = 0
    @online_by_server = Hash.new
    @friends.each do |u|
      sesh = Session.where(:user_id => u.id).order('created_at DESC').first
      next if sesh.nil? || !sesh.is_active?
      @online += 1
      @online_by_server[sesh.server.name] = [] if @online_by_server[sesh.server.name].nil?
      @online_by_server[sesh.server.name] << u
      @friends.delete(u)
    end

    if logged_in? && @user.id == current_user.id
      @pendingSent = User.where(:id => Friend.select(:friend_id).where(:user_id => @user.id, :accepted => 0).map(&:friend_id))
      @pendingRecieved = User.where(:id => Friend.select(:user_id).where(:friend_id => @user.id, :accepted => 0).map(&:user_id))
    end
  end

  def friend
    if !logged_in? || current_user.id != params[:u].to_i
      redirect_to '/'
    end
  end

  def add_friend
    Friend.create(:user_id => current_user.id, :friend_id => @user.id, :accepted => 0)

    @user.alert "Friend:#{current_user.id}:#{@user.id}", "#{current_user.name} has requested to be your friend.", current_user.path

    redirect_to @user.path
  end

  def cancel_friend
    Friend.where(:user_id => current_user.id, :friend_id => @user.id, :accepted => 0).destroy_all

    @user.dismiss_alert "Friend:#{current_user.id}:#{@user.id}"

    redirect_to @user.path
  end

  def remove_friend
    Friend.where(:user_id => current_user.id, :friend_id => @user.id, :accepted => 1).destroy_all
    Friend.where(:user_id => @user.id, :friend_id => current_user.id, :accepted => 1).destroy_all

    redirect_to @user.path
  end

  def accept_friend
    friend = Friend.where(:user_id => @user.id, :friend_id => current_user.id, :accepted => 0).first
    friend.accepted = 1
    friend.save

    friend = Friend.create(:user_id => current_user.id, :friend_id => @user.id, :accepted => 1)

    @user.alert "NewFriend:#{friend.id}", "#{current_user.name} has accepted your friend request!", current_user.path

    redirect_to @user.path
  end
end
