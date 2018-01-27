# User controller actions for user profiles.
module Users::ProfileActions

  def profile
    if params[:user] != @user.name && params[:user].downcase != @user.name.downcase
      redirect_to @user.path
      return
    end

    @usernames = Username.where(:user_id => @user.id).order('created_at DESC')
    if @usernames.size > 1
      @latest = @usernames.first
      if @latest.created_at > Time.now - 3.weeks
        @previous = @usernames[1]
      end
    end

    @cover_art = @user.details.cover_art
    @cover_art = '/assets/profiles/castle.jpg' if @cover_art == nil

    @about = @user.details.about
    @about = @about == nil ? nil : @about.gsub("\n\n", '<br />')

    @punishments = @user.punishments.order('date DESC')

    @recent = Death.where('(user_id = ? AND user_hidden = ?) OR (cause = ? AND cause_hidden = ?)', @user.id, false, @user.id, false).order('created_at DESC').limit(30)
    @recent = @recent.size > 0 ? @recent.each_slice((@recent.size / 2.0).round).to_a : []

    @total_kills = Death.where(:cause => @user.id, :cause_hidden => false).count
    @total_deaths = Death.where(:user_id => @user.id, :user_hidden => false).count

    @total_pvp_deaths = Death.where('user_id = ? AND user_hidden = 0 AND cause != 0', @user.id).count

    @kd = @total_kills.to_d / (@total_deaths == 0 ? 1 : @total_deaths).to_d
    @pvp_kd = @total_kills.to_d / (@total_pvp_deaths == 0 ? 1 : @total_pvp_deaths).to_d

    @credits = Credit.where(:user_id => @user.id).sum(:amount)
    @time = Session.where(:user_id => @user.id).sum(:duration)
    @joins = Session.where(:user_id => @user.id).count

    @xp_season = PrestigeSeason.xp(@user)
    @xp_all = ExperienceTransaction.where(:user_id => @user.id).sum(:amount)
    @level = PrestigeLevel.level(@user)

    @level_highest = PrestigeLevel.where(:user_id => @user.id).order('level DESC').first

    if @user.details.can_view?(current_user, :ips)
      @total = 0
      @sessions = Hash.new
      @user.sessions.each do |session|
        unless @sessions.include?(session.ip)
          @sessions[session.ip] = Hash.new
          @sessions[session.ip][:count] = 0
          @sessions[session.ip][:example] = session.id
          @sessions[session.ip][:last] = session.created_at
        end
        @sessions[session.ip][:count] += 1
        if session.created_at > @sessions[session.ip][:last]
          @sessions[session.ip][:last] = session.created_at
        end
        @total += 1
      end
      @sessions.each do |ip, info|
        info[:percent] = 100 * (info[:count].to_d / @total.to_d)
      end
      @sessions = @sessions.sort_by { |ip, hash| hash[:last] }.reverse
    end

    if @user.details.can_view?(current_user, :reports)
      @reports_by = Report.where(:creator_id => @user.id).order('created_at DESC')
      @reports_for = Report.where(:user_id => @user.id).order('created_at DESC')
    end

    if @user.details.can_view?(current_user, :appeals)
      @appeals = Appeal.where(:user_id => @user.id).order('created_at DESC')
    end

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

    @achievements = AchievementReceiver.where(user: @user).map(&:achievement)

    @objective_data_raw = {}
    Objective.where(user_id: @user.id).each do |o|
      @objective_data_raw[o.objective_id] = 0 if @objective_data_raw[o.objective_id].nil?
      @objective_data_raw[o.objective_id] = @objective_data_raw[o.objective_id] + 1
    end
    @objective_data = {}
    @objective_data_raw.each do |i, a|
      @objective_data[ObjectiveType.find_by_id(i).name.titleize + 's'] = a
    end
  end

  def graphs
    @season_data_raw = {}
    ExperienceTransaction.where(:user_id => @user.id).order('created_at').all.each do |e|
      id = e.season_id
      @season_data_raw[id] = 0 if @season_data_raw[id].nil?
      @season_data_raw[id] = @season_data_raw[id] + e.amount
    end
    @season_data = {}
    @season_data_raw.each do |i, a|
      @season_data[PrestigeSeason.find_by_id(i).name] = a
    end
    @xp_over_time = ExperienceTransaction.where(user_id: @user.id).group_by_month(:created_at).count
    render :layout => false
  end

  def posts
    require 'will_paginate/array'

    viewable = ForumsHelper.viewable_categories(current_user)
    @posts = Revision.where('category_id IN (?)', viewable).where(:user_id => @user.id).where(:original => 1).order('created_at DESC').to_a.flatten.paginate(:page => params[:page], :per_page => 5)
    @posts = @posts.delete_if { |p| p.discussion.nil? }
    render :layout => false
  end
end
