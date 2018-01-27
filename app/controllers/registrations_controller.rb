class RegistrationsController < ApplicationController
  before_action :load_parent
  before_action :set_registration, only: [:toggle, :accept, :uninvite, :invite, :show, :destroy]
  before_action :checks, :except => [:accept, :alone]

  def self.permission_definition
  end

  def index
    render_404
  end

  def toggle
    redirect_if_fail(@tournament.can_execute?(current_user, :toggle_registrations), @tournament, 'You do not have permission to edit tournaments.'); return if performed?

    @registration.status = @registration.status == 1 ? 0 : 1
    @registration.save

    flash[:notice] = 'Registration status modified.'
    redirect_to @tournament
  end

  def accept
    unless @registration.members(false).include?(current_user)
      redirect_to @tournament
      return
    end

    data = @registration.json
    data.each do |item|
      if item[0].to_i == current_user.id
        data.delete(item)
      end
    end
    data += [[current_user.id, 1]]

    @registration.user_data = data.to_json
    @registration.save

    flash[:notice] = 'You have accepted the registration request.'
    redirect_to @tournament
  end

  def invite
    user = User.find_by_id(params[:user])

    redirect_if_fail(@registration.team.can_execute?(current_user, :invite), :action, :back); return if performed?

    if @registration.members(false).size >= @tournament.max
      flash[:error] = 'You have added the maximum number of players to your roster.'
      redirect_to :back
      return
    end

    data = @registration.json
    data += [[user.id, 0]]
    @registration.user_data = data.to_json
    @registration.save

    user.alert "R-Invite:#{@registration.id}", 'You have been invited to participate in a tournament. Click to accept the invite.', tournament_registration_accept_path(@tournament, @registration)

    redirect_to :back
  end

  def alone
    redirect_login
    redirect_if_fail(@tournament.allow_loners, @tournament, 'You must be on a team to play in this tournament'); return if performed?

    @registration = @tournament.global_registration
    data = @registration.json
    data += [[current_user.id, 1]]
    @registration.user_data = data.to_json
    @registration.save

    redirect_to [@tournament, @registration], notice: 'Welcome to the tournament!'
  end

  def uninvite
    user = User.find_by_id(params[:user])

    unless @registration.members(false).include?(user)
      redirect_to :back
      return
    end

    data = @registration.json
    data.each do |item|
      if item[0].to_i == user.id
        data.delete(item)
      end
    end

    user.dismiss_alert "R-Invite:#{@registration.id}"

    @registration.user_data = data.to_json
    @registration.save

    redirect_to :back
  end

  def show
  end

  def new
    redirect_login
    @registration = @tournament.registrations.new

    previous = @tournament.registrations.find_by_team_id(current_user.team.id)
    if previous != nil
      redirect_to tournament_registration_path(@tournament, previous)
      return
    end
  end

  def edit
    render_404
  end

  def create
    redirect_login

    previous = @tournament.registrations.find_by_team_id(current_user.team.id)
    if previous != nil
      redirect_to tournament_registration_path(@tournament, previous)
      return
    end

    @registration = @tournament.registrations.new
    @registration.user_data = '[]'
    @registration.team_id = current_user.team.id
    @registration.status = 0

    if @registration.save
      redirect_to [@tournament, @registration], notice: 'Registration was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    render_404
  end

  def destroy
    redirect_login

    @registration.destroy
    redirect_to @tournament, notice: 'Registration was successfully deleted.'
  end

  private
  def load_parent
    @tournament = Tournament.find_by_slug(params[:tournament_id])
  end

  def checks
    if !logged_in?
      redirect_to @tournament
      return
    end

    unless @tournament.can_execute?(current_user, :bypass_times)
      if Time.now < @tournament.open_at || Time.now > @tournament.close_at
        redirect_to @tournament
        return
      end
    end
  end

  def set_registration
    @registration = @tournament.registrations.find(params[:id] || params[:registration_id])
  end
end
