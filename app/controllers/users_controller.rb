class UsersController < ApplicationController
  include ActionView::Helpers::DateHelper

  include Users::ProfileActions
  include Users::FriendActions
  include Users::RegistrationActions
  include Users::DetailActions

  def self.permission_definition
  end

  before_action :load_user, :except => [:register, :registration_start, :registration_status, :registration_success, :search, :discord_auth]
  before_action :friend, :only => [:add_friend, :cancel_friend, :remove_friend, :accept_friend]

  skip_before_action :check_bans, :only => :discord_auth

  def self.permission_definition
  end

  def generate_api_token
    redirect_login; return if performed?

    token = SecureRandom.urlsafe_base64(30)
    current_user.update(api_key: token)

    flash[:notice] = 'API token generated!'
    redirect_to edit_user_path
  end

  def discord_auth
    @success = false
    redirect_login; return if performed?

    token = params[:token]

    @success = !(token.nil? || token.empty?)

    redirect_if_fail(@success, root_path, 'Invalid token specified!'); return if performed?

    token = token.gsub(' ', '+')

    id = $redis.get('discord-reg-a.' + token).to_i

    unless User.where(discord_id: id).empty?
      flash[:error] = 'That discord user is already linked to someone else!'
      redirect_to root_path
      return
    end

    current_user.update(discord_id: id)

    $redis.set('discord-reg-v.' + token, current_user.id)
    $redis.del('discord-reg-a.' + token)
    flash[:notice] = 'Successfully registered with discord. Please allow up to a minute for the registration to proccess.'
    redirect_to root_path
  end

  def search
    list = User.select('username').where('username LIKE ?', "#{params[:query].gsub('_', '\_')}%").limit(5)
    array = list.map { |u| u.username }
    if params[:query].downcase.start_with?('c')
      array.push('Console')
    end
    render :json => array.to_s
  end

  def load_user
    if params[:user]
      names = Username.where(:username => params[:user]).order('created_at DESC').limit(1)

      if names.size == 0
        render_error 404, nil
        return
      end

      @user = User.find_by_id(names.first.user_id)
    else
      render_error 404, nil
    end
  end

  def status
    @last_online = @user.created_at

    @online = false
    latest = Session.where(:user_id => @user.id).order('created_at DESC').limit(1)
    if latest.size > 0
      if latest.first.is_active?
        @online = true
        @server = latest.first.server
      else
        @last_online = latest.first.updated_at
        if @last_online
          @last_server = latest.first.server
        end
      end
    end

    render :layout => false
  end
end
