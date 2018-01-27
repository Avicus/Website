class Admin::IndexController < ApplicationController

  before_action :admin

  def self.permission_definition
    {
        :global_options => {
            :text => 'Admin Panel - Index',
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :actions => {
                                      :view => [
                                          :index, :ranks, :forums, :stats, :achievements, :logs, :ips, :announcements, :servers, :server_groups, :server_categories
                                      ]
                                  }
                              }]
    }
  end

  def index
    @panels = [
        # Web
        {:name => 'Ranks', :desc => 'Manage in game and web ranks.'},
        {:name => 'Forums', :desc => 'Manage forums and categories.'},
        # Minecraft
        {:name => 'Stats', :desc => 'View various server statistics.'},
        {:name => 'Achievements', :desc => 'Manage achievements which players must earn.'},
        # Internals
        {:name => 'Announcements', :desc => 'Manage various messages that are displayed to users.'},
        {:name => 'Servers', :desc => 'Manage the servers.'},
        {:name => 'Server Groups', :desc => 'Manage groups of servers (for menus).'},
        {:name => 'Server Categories', :desc => 'Manage categories of servers (for internal use).'}
    ]

    @panels.delete_if { |c| !current_user.has_permission?('admin:index_controllers', :view, c[:name].downcase.tr(' ', '_'), true) }
  end

  def ip
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :ips, true), '/', :page); return if performed?

    @session = Session.find(params[:id])

    matches = Session.where(:ip => @session.ip)

    @sessions = Hash.new

    matches.each do |match|
      info = @sessions[match.user]
      if info == nil
        info = Hash.new
        info[:count] = 0
        info[:last] = match.created_at
        # Bans
        banned = Punishment.where(appealed: false, user: match.user, type: 'ban').count > 0
        banned = banned || Punishment.where(appealed: false, user: match.user, type: 'tempban').where('expires > (?)', Time.now).count > 0
        info[:banned] = banned
      end

      info[:count] += 1
      if match.created_at > info[:last]
        info[:last] = match.created_at
      end

      @sessions[match.user] = info
    end

    @sessions = @sessions.sort_by { |user, info| info[:last] }.reverse

    @punish_types = {
        'Mute' => :mute,
        'Warn' => :warn,
        'Kick' => :kick,
        'Permanent Ban' => :ban,
        'Temporary Ban' => :tempban,
        'Website Ban' => :web_ban,
        'Temporary Website Ban' => :web_tempban,
        'Tournament Ban' => :tournament_ban,
        'Discord Warn' => :discord_warn,
        'Discord Kick' => :discord_kick,
        'Temporary Discord Ban' => :discord_tempban,
        'Discord Ban' => :discord_ban
    }

    @punish_types.delete_if { |t, i| !Punishment.can_issue?(current_user, i) }

    @ip_ban = IpBan.where(ip: @session.ip).last
  end

  def punish
    if params[:punishment][:is_ip] == 'true'
      ip_ban(params)
      return
    end

    redirect_if_fail(Punishment.can_mass_punish?(current_user), request.referer, :action); return if performed?
    redirect_if_fail(Punishment.can_issue?(current_user, params[:punishment][:type]), request.referer, 'You may not issue punnishments of this type.'); return if performed?

    redirect_if_fail(!params[:punish].nil?, request.referer, 'You must provide at least one user to punish.'); return if performed?
    redirect_if_fail(!params[:punishment][:reason].blank?, request.referer, 'You must provide a reason.'); return if performed?

    expires = DateTime.strptime(params[:punishment][:expires], '%m/%d/%Y %H:%M') unless params[:punishment][:expires].blank?
    expires = nil if params[:punishment][:expires].blank?

    unless params[:punishment][:staff] == ''
      staff = User.where(:username => params[:punishment][:staff]).first.id
      unless staff
        flash[:alert] = 'User specified in staff field not found'
        redirect_to request.referer
        return
      end
    end

    redirect_if_fail(Punishment.can_issue_as?(current_user, staff), @punishment, 'You may not issue punishments as this user.'); return if performed?

    users = []
    params[:punish].each do |user, val|
      users << user
    end unless params[:punish].nil?

    punish_users(staff, params[:punishment][:reason], params[:punishment][:type], expires, users)

    admin_log(:general, current_user, :mass_punish, "Staff: #{staff.nil? ? 'Console' : staff.username} Reason: #{params[:punishment][:reason]} Type: #{params[:punishment][:type]} Users: #{users.map { |a| a.to_s }.join(' - ')}")

    flash[:notice] = 'Successfully performed mass punish.'
    redirect_to request.referer
  end

  private

  def ip_ban(params)
    res = IpBan.where(ip: params[:punishment][:ip]).first
    if res.nil?
      redirect_if_fail(IpBan.can_execute?(current_user, :create), request.referer, :action); return if performed?
      redirect_if_fail(!params[:ip_ban][:reason].blank?, request.referer, 'You must provide a reason.'); return if performed?
      redirect_if_fail(!params[:ip_ban][:ip].blank?, request.referer, 'IP cannot be blank.'); return if performed?

      unless params[:ip_ban][:staff] == ''
        staff = User.where(:username => params[:ip_ban][:staff]).first.id
        unless staff
          flash[:alert] = 'User not found'
          redirect_to request.referer
          return
        end
      end

      users = []
      params[:exclude].each do |user, val|
        users << user
      end unless params[:exclude].nil?

      IpBan.create(staff_id: staff,
                   reason: params[:ip_ban][:reason],
                   enabled: true,
                   ip: params[:ip_ban][:ip],
                   excluded_users: users
      )
      flash[:notice] = 'Successfully created IP ban.'
      redirect_to request.referer
      admin_log(:general, current_user, :create_ip_ban, "Staff: #{staff.nil? ? 'Console' : staff.to_s} Reason: #{params[:ip_ban][:reason]} Exlused Users: #{users.map { |a| a.to_s }.join(' - ')}")
    else
      redirect_if_fail(IpBan.can_execute?(current_user, :update), request.referer, :action); return if performed?
      res.reason = params[:ip_ban][:reason] unless params[:ip_ban][:reason].blank?
      res.enabled = !params[:ip_ban][:enabled].blank?

      users = []
      params[:exclude].each do |user, val|
        users << user
      end unless params[:exclude].nil?
      res.excluded_users = users

      res.save
      flash[:notice] = 'Successfully updated IP ban.'
      redirect_to request.referer
      admin_log(:general, current_user, :update_ip_ban, "Staff: #{staff.nil? ? 'Console' : staff.to_s} Reason: #{params[:ip_ban][:reason]} Exlused Users: #{users.map { |a| a.to_s }.join(' - ')}")
    end
  end

  def admin
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :index, true), '/', :page)
  end

end
