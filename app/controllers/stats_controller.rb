class StatsController < ApplicationController
  PER_PAGE = 30

  skip_before_action(:check_bans)

  def self.permission_definition
  end

  def index
    @entries = LeaderboardEntry.all
    page = params[:page]

    # Period
    case params[:period]
      when 'monthly'
        period = 1
      when 'overall'
        period = 2
      else
        period = 0
    end
    @entries = @entries.where(:period => period)


    # Sort order
    sort = params[:sort]
    @sort_options = %w(kills deaths kd_ratio wools monuments time_online)
    unless @sort_options.include?(sort)
      sort = @sort_options[0]
    end
    @entries = @entries.order("#{sort} DESC")


    # Username query
    query = params[:query]
    if query.presence
      @user = User.find_by_name(query)

      if @user
        ranked = @entries.select('*', '@curr := @curr + 1 AS rank').joins('JOIN (SELECT @curr := 0) c')
        query = LeaderboardEntry.select('*').from(ranked, :ranked).where('ranked.user_id' => @user.id).order('user_id DESC')

        if query.empty?
          flash[:error] = 'Player not found in the context of your search.'
        else
          index = query.first.attributes['rank']
          page = index / PER_PAGE + 1
        end
      else
        flash[:error] = 'No user matched query.'
      end

      # Don't include 'query' in pagination links
      params.delete('query')
    end

    # Paginate
    @entries = @entries.paginate(:page => page, :per_page => PER_PAGE)
  end

  require 'will_paginate/array'

  def experience
    @current = PrestigeSeason.current_season
    @entries = ExperienceLeaderboardEntry.all
    page = params[:page]

    # Period
    case params[:period]
      when 'monthly'
        period = 1
      when 'overall'
        period = 2
      else
        period = 0
    end
    @entries = @entries.where(:period => period)


    # Sort order
    sort = params[:sort]
    @sort_options = %w(xp_total prestige_level level xp_nebula xp_koth xp_ctf xp_tdm xp_elimination xp_sw xp_walls xp_arcade)
    unless @sort_options.include?(sort)
      sort = @sort_options[0]
    end
    @entries = @entries.order("#{sort} DESC")

    # Username query
    query = params[:query]
    if query.presence
      @user = User.find_by_name(query)

      if @user
        ranked = @entries.select('*', '@curr := @curr + 1 AS rank').joins('JOIN (SELECT @curr := 0) c')
        query = LeaderboardEntry.select('*').from(ranked, :ranked).where('ranked.user_id' => @user.id).order('user_id DESC')

        if query.empty?
          flash[:error] = 'Player not found in the context of your search.'
        else
          index = query.first.attributes['rank']
          page = index / PER_PAGE + 1
        end
      else
        flash[:error] = 'No user matched query.'
      end

      # Don't include 'query' in pagination links
      params.delete('query')
    end

    # Paginate
    @entries = @entries.paginate(:page => page, :per_page => PER_PAGE)
  end
end
