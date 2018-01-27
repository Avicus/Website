class PagesController < ApplicationController

  helper_method :get_commits

  def self.permission_definition

  end

  def home_api
    render :layout => false
  end

  def confirm
    uuid = params[:uuid]

    if get_cache("email.#{current_user.id}") != uuid
      raise 'wrong user'
    end

    details = current_user.details
    details.email_status = 1
    details.save

    flash[:notice] = 'You have successfully verified your email.'
    redirect_to root_url
  rescue
    redirect_to '/'
  end

  def development
    require 'will_paginate/array'
    @repos = Avicus::Application.config.repos.dup

    @repos.delete_if { |name, repo| !is_in_cache("repo.#{repo[:name]}-#{repo[:branch].blank? ? 'master' : repo[:branch]}") }

    @repo = params[:repo] ? params[:repo] : @repos.first[0]

    unless @repos.include?(@repo)
      redirect_to '/revisions'
      return
    end

    @name = @repo
    @repo = @repos[@repo]
    @commits = get_commits(@repo[:name], @repo[:branch]).paginate(:page => params[:page], :per_page => 15)
  end

  def get_commits(repo, branch = 'master')
    branch = 'master' if branch.blank?

    if get_cache("repo.#{repo}-#{branch}")
      return get_cache("repo.#{repo}-#{branch}")
    end

    return []
  end

  def staff

  end
end
