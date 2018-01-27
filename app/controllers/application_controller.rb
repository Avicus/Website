class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :dev_check, :setup, :set_announcement
  before_action :check_bans, :except => [:support, :rules, :terms, :home]
  before_action :notify_appealable

  helper_method [:logged_in?, :current_user]

  require 'net/http'
  require 'digest/md5'
  require_dependency 'logging'
  require_dependency 'cacher'
  require_dependency 'dummy_user'
  include ApplicationHelper

  def self.permission_definition
    {
        :global_options => {
            :text => 'Global Permissions',
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :actions => {:view => [:dev_site, :development_sha_links, :peek, :full_stacks],
                                               #:features => []
                                  }
                              }]
    }
  end

  def peek_enabled?
    !request.original_url.include?('api') && (current_user.nil? ? false : current_user.has_permission?(:application_controllers, :view, :peek, true) || Rails.env != 'production')
  end

  def authenticate_blazer!
    unless logged_in? && current_user.id == 329244
      redirect_to('/')
    end
  end

  def set_announcement
    if Avicus::Application.for_users?
      announcements = Announcement.where(:enabled => true, :web => true)
      tm = Tournament.where('open_at > (?) OR (open_at < (?) AND close_at > (?))', Time.now, Time.now, Time.now).order(:open_at).first
      unless tm.nil?
        body = nil
        if tm.open_at > Time.now && tm.open_at - Time.now < 1.week
          body = "<strong>Tournament Alert:</strong><br>Registration for <a href='/tournaments/#{tm.slug}'>#{tm.name}</a> opens in #{time_ago(tm.open_at)}!"
        elsif tm.close_at > Time.now
          body = "<strong>Tournament Alert:</strong><br>Registration for <a href='/tournaments/#{tm.slug}'>#{tm.name}</a> closes in #{time_ago(tm.close_at)}!"
        end
        @announcement = Announcement.new(web: true, enabled: true, body: body)
      end
      unless announcements.empty?
        @announcement = announcements.shuffle.first
      end
    end
  end

  def logged_in?
    current_user.is_a?(User)
  end

  def current_user
    user_id = cookies.signed[:user_id]
    user = nil
    if user_id.presence
      user = User.find_by_id(user_id)
    end

    user || DummyUser.new
  end

  def clear_current_user
    cookies.delete(:user_id)
  end

  def notify_appealable
    if Avicus::Application.for_users?
      @banned = false
      if logged_in?
        if get_cache("appealable.#{current_user.id}")
          @banned = get_cache("appealable.#{current_user.id}")
          return
        end

        Punishment.where(appealed: false, user: current_user).where('type = ? OR (type = ? AND expires > ?)', 'ban', 'tempban', Time.now).each do |punish|
          @banned = true

          appeal = Appeal.find_by_punishment_id(punish.id)
          @banned = appeal.nil?

          break if @banned
        end

        set_cache "appealable.#{current_user.id}", @banned, 15.minutes
      end
    end
  end

  def set_current_user(user, remember_me)
    if remember_me
      cookies.signed[:user_id] = {:value => user.id, :expires => Time.now + 7.days}
    else
      cookies.signed[:user_id] = {:value => user.id}
    end
  end

  def fetch_announcement
    announcements = Announcement.where(web: true, enabled: true)
    unless announcements.empty?
      @announcement = announcements.sample
    end
  end

  def dev_check
    if Avicus::Application.for_users?
      if Rails.env == 'development' && !logged_in? && params[:controller] != 'sessions' && $avicus['require-login']
        flash[:error] = 'Please login.'
        redirect_to new_session_path
      end
    end
  end

  def setup
    if Avicus::Application.for_users?
      timezone = ActiveSupport::TimeZone[-cookies[:time_zone].to_i/60]
      Time.use_zone(timezone) do
        p Time.zone.now
      end
      Time.zone = timezone

      if $avicus['offline-forums'] && request.env['PATH_INFO'].include?('forums')
        render 'shared/maint'
        return
      end
    end
  end

  def redirect_login
    unless logged_in?
      flash[:error] = 'You must be logged in to access that page.'
      redirect_to '/'
      return true
    end
    false
  end

  def redirect_if_fail(pass, to, message)
    unless pass
      if message.is_a?(Symbol)
        case message
          when :page
            message = 'You do not have permission to access this page.'
          when :action
            message = 'You do not have permission to perform this operation.'
          when :login
            message = 'You must be logged in to access this page.'
        end
      end
      flash[:error] = message
      redirect_to to
    end
  end

  def check_bans
    if Avicus::Application.for_users?
      ban = get_web_ban
      if ban
        @punishment = ban
        render 'shared/banned'
      end
    end
  end

  def get_web_ban
    if logged_in?
      current_user.punishments.where('type = ? OR type = ?', 'web_ban', 'web_tempban').each do |punishment|
        if punishment.appealed?
          next
        end

        expires = punishment.expires

        if !expires || (expires && expires > Time.now)
          return punishment
        end
      end
    end

    nil
  end

  def check_tourney_bans
    if logged_in?
      current_user.punishments.where("type = 'tournament_ban'").each do |i|
        if i.appealed == 1
          next
        end
        @punishment = i
      end

      if @punishment != nil
        render 'shared/banned_tourney'
      end
    end
  end

  rescue_from Exception, with: lambda { |exception| render_error 500, exception }
  rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, with: lambda { |exception| render_error 404, exception }

  def render_error(status, exception)
    @id = (0...8).map { (65 + rand(26)).chr }.join
    @exception = exception
    log('------- ' + @id + ' -------') if exception != nil
    log(exception) if exception != nil
    exception.backtrace.each do |b|
      log(b)
    end if exception != nil
    log('------- ' + @id + ' -------') if exception != nil
    self.response_body = nil
    render "shared/#{status.to_s}"
  end

  def render_404
    render '/shared/404'
  end
end
