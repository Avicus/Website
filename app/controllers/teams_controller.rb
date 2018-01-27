class TeamsController < ApplicationController
  before_action :set_team, except: [:index, :new, :create]
  before_action :check_tourney_bans

  before_action :ensure_logged_in, only: [:new, :update, :create, :update, :destroy, :invite, :cancel_invite, :leave]

  def self.permission_definition
  end

  before_action :is_member, only: [:create, :new]

  def index
    all = Team.all
    all = all.sort_by { |t| t.members.size }.reverse! unless all.first.nil?

    require 'will_paginate/array'
    @teams = all.paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @objectives = Objective.where('user_id IN (?)', @team.members.map(&:user_id)).size
    @kills = Death.where('cause IN (?) AND cause_hidden = 0', @team.members.map(&:user_id)).count
    @deaths = Death.where('user_id IN (?) AND user_hidden = 0', @team.members.map(&:user_id)).count
    @kd = @kills.to_d / (@deaths == 0 ? 1 : @deaths).to_d
    @online = Session.where('user_id IN (?)', @team.members.map(&:user_id)).sum(:duration)
  end

  def new
    @team = Team.new

    redirect_if_fail(@team.can_execute_global?(current_user, :create), tournaments_path, :action); return if performed?

    # Edit all on creation
    @editable = Team.perm_fields
  end

  def edit
    redirect_if_fail(@team.can_execute?(current_user, :actions, :update), tournaments_path, :action); return if performed?
    @editable = editable_fields(@team)
  end

  def create
    @team = Team.new(team_params)

    redirect_if_fail(@team.can_execute_global?(current_user, :create), tournaments_path, :action); return if performed?

    @editable = Team.perm_fields

    @team.updated_at = Time.now
    # save_image(@team, params[:emblem])

    if @team.save
      @team.tag = @team.tag.upcase
      @team.save

      member = TeamMember.new
      member.user_id = current_user.id
      member.role = 'leader'
      member.accepted = 1
      member.accepted_at = Time.now
      member.team_id = @team.id
      member.save

      redirect_to @team, notice: 'Team was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /teams/1
  def update
    redirect_if_fail(@team.can_execute?(current_user, :actions, :update), tournaments_path, :action); return if performed?
    params[:team].keys.each do |field|
      return redirect_to @team, :alert => "You do not have permission to edit the '#{field.to_s}' value of this team." unless @team.can_edit?(current_user, field.to_s)
    end

    @team.updated_at = Time.now
    # save_image(@team, params[:emblem])

    if @team.update(team_params)
      @team.tag = @team.tag.upcase
      @team.save
      redirect_to @team, notice: 'Team was successfully updated.'
    else
      @editable = editable_fields(@team)
      render action: 'edit'
    end
  end

  def save_image(team, data)
    require 'base64'
    image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

    File.open("#{Rails.root}/public/emblems/#{team.tag}.#{team.updated_at.to_i}.png", 'wb') do |f|
      f.write image_data
    end
  end

  # DELETE /teams/1
  def destroy
    redirect_if_fail(@team.can_execute?(current_user, :actions, :delete), @team, 'You do not have permission to disband this team.'); return if performed?
    @team.members.delete_all
    @team.invites.each do |invite|
      invite.destroy
      Alert.dismiss(invite.user, "Invite:#{invite.id}")
    end
    @team.destroy
    redirect_to teams_url, notice: 'You have disbanded your team.'
  end

  def invite
    redirect_if_fail(@team.can_execute?(current_user, :actions, :invite), @team, 'You do not have permission to invite players to this team.'); return if performed?
    id = params[:user_id]
    user = User.find_by_id(id)
    if params[:query].presence
      user = User.find_by_username(params[:query])
    end
    if user == nil
      flash[:error] = 'That user does not exist.'
      redirect_to @team.path + '#inviteTab'
      return
    end

    redirect_if_fail(user.has_permission?(:teams, :global, :join, true), @team, 'This player does not have permission to participate in this tournament.'); return if performed?

    members = @team.members.where(:user_id => user.id).size + @team.invites.where(:user_id => user.id).size

    if members > 0
      flash[:error] = 'That user is already invited or is on your team!'
      redirect_to @team.path + '#inviteTab'
      return
    end

    #prevent inviting if on team
    #members = TeamMember.where(:user_id => user.id).where(:accepted => 1).size

    #if members > 0
    #  flash[:error] = "That user is already on a team."
    #  redirect_to @team.path + "#inviteTab"
    #  return
    #end

    if @team.members.size + @team.invites.size >= 30
      flash[:error] = 'You cannot have more than 30 members on your team.'
      redirect_to @team.path + '#membersTab'
      return
    end

    member = TeamMember.new
    member.user_id = user.id
    member.role = 'member'
    member.accepted = 0
    member.team_id = @team.id
    member.save

    Alert.alert(user, "Invite:#{member.id}", "You have been invited to the team, #{@team.title}!", "/teams/#{@team.id}")

    flash[:notice] = "You have invited #{member.user.name} to your team."
    redirect_to @team.path + '#inviteTab'
  end

  def cancel_invite
    redirect_if_fail(@team.can_execute?(current_user, :actions, :invite), @team, 'You do not have permission to cancel an invitation to this team.'); return if performed?
    member = @team.invites.where(:id => params[:member_id]).where(:accepted => 0).first
    if member != nil
      Alert.dismiss(member.user, "Invite:#{member.id}")
      member.destroy
      flash[:notice] = "You have cancelled #{member.user.name}'s invite to your team."
    end
    redirect_to @team.path + '#inviteTab'
  end

  def leave
    leaders = @team.members.where(:role => 'leader')
    if @team.get_role(current_user) == 'leader' && leaders.size == 1
      flash[:error] = 'You are the only leader of this team and cannot leave.'
      redirect_to @team.path
      return
    end

    @team.members.where(:role => 'leader').each do |member|
      if member.user == current_user
        next
      end
      Alert.alert(member.user, "Leave:#{@team.members.where(:user_id => current_user.id).first.id}", "#{current_user.name} has left your team!", "/teams/#{@team.id}#membersTab")
    end

    @team.members.where(:user_id => current_user.id).delete_all
    flash[:notice] = 'You have left your team.'
    redirect_to @team.path
  end

  def kick
    redirect_if_fail(@team.can_execute?(current_user, :actions, :kick), @team, 'You do not have permission to kick players from this team.'); return if performed?
    member = @team.members.where(:id => params[:member_id]).first

    if member.user.id == current_user.id
      flash[:error] = 'You cannot kick yourself from your team.'
      redirect_to member.team.path + '#membersTab'
      return
    end

    member.destroy
    Alert.alert(member.user, "Kick:#{member.id}", 'You have been kicked from your team.', "/teams/#{@team.id}#membersTab")
    flash[:notice] = "You have kicked #{member.user.name} from your team."
    redirect_to member.team.path + '#membersTab'
  end

  def set_role
    redirect_if_fail(@team.can_execute?(current_user, :actions, :set_role), @team, 'You do not have permission to set roles for members of this team.'); return if performed?
    member = @team.members.where(:id => params[:member_id]).first
    if member.user.id == current_user.id
      flash[:error] = 'You cannot demote yourself.'
      redirect_to member.team.path + '#membersTab'
      return
    end
    member.update(:role => params[:role])

    flash[:notice] = "You have set #{member.user.name}'s role to #{member.role.capitalize}."
    redirect_to member.team.path + '#membersTab'
    Alert.alert(member.user, "Role:#{member.id}", 'Your team role has been updated.', @team.path + '#membersTab')
  end

  def set_accepted
    redirect_if_fail(current_user.has_permission?(:teams, :global, :join, true), @team, 'You do not have permission to participate in this tournament.'); return if performed?

    members = TeamMember.where(:user_id => current_user.id).where(:accepted => 1).size

    if members > 0
      flash[:error] = 'You are already on a team!'
      redirect_to :back
      return
    end

    member = @team.invites.where(:user_id => current_user.id).first

    if member == nil
      flash[:error] = 'You were not invited to that team.'
      redirect_to :back
      return
    end

    @team.members.where(:role => 'leader').each do |m|
      Alert.alert(m.user, "AcceptInvite:#{member.id}", "#{current_user.name} has accepted your team invite.", "#{@team.path}#membersTab")
    end

    member.accepted = 1
    member.accepted_at = Time.now
    member.save
    flash[:notice] = 'You have joined a team!'
    redirect_to @team.path + '#membersTab'
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def team_params
    params.require(:team).permit(:title, :tag, :tagline, :about)
  end

  def ensure_logged_in
    unless logged_in?
      flash[:error] = 'You must log in to create and administer teams.'
      redirect_to @team == nil ? '/login' : @team.path
    end
  end

  def is_member
    if current_user.team != nil
      flash[:error] = 'You are already a member of a team.'
      redirect_to current_user.team.path
    end
  end
end
