class Forums::IndexController < ApplicationController

  before_action :global_vars

  def self.permission_definition

  end

  helper 'forums'

  def index
    handle_legacy

    exclude = Category.where(:exclude_from_recent => true).map(&:id).push(-1)
    viewable = ForumsHelper.viewable_categories(current_user)

    @discussions = Discussion.where('category_id NOT IN (?)', exclude)
    @discussions = @discussions.where('category_id IN (?)', viewable)
    @discussions = @discussions.select(:id, :user_id, :stickied, :archived, :category_id, :created_at, :updated_at, :uuid, :views)

    @discussions = @discussions.order('updated_at DESC').paginate(:page => params[:page], :per_page => 25)
  end

  def mark_all_read
    category_id = params[:category_id]
    discussion_id = params[:discussion_id]

    category = Category.find_by_id(category_id) unless category_id.nil?
    discussion = Discussion.find_by_id(discussion_id) unless discussion_id.nil?

    category = nil unless discussion.nil?

    redirect_to :back if category.nil? && !category_id.nil?; return if performed?
    redirect_to :back if discussion.nil? && !discussion_id.nil?; return if performed?

    notice = ''
    if !discussion.nil?
      discussion.mark_as_read! for: current_user
      discussion.replies.mark_as_read! :all, for: current_user
      notice = 'Marked all replies to this topic as read.'
    elsif category.nil?
      Discussion.mark_as_read! :all, for: current_user
      Reply.mark_as_read! :all, for: current_user
      notice = 'Marked all discussions as read.'
    else
      all = Discussion.where(category_id: category.id)
      all.each do |discussion|
        discussion.mark_as_read! for: current_user
        discussion.replies.mark_as_read! :all, for: current_user
      end
      notice = 'Marked all discussions in this topic as read.'
    end
    flash.now[:notice] = notice
    redirect_to :back
  end

  def my_subscriptions
    redirect_if_fail(logged_in?, forums_path, :login); return if performed?

    subs = [0] + current_user.subscriptions

    @discussions = Discussion.select(:id, :user_id, :stickied, :archived, :category_id, :created_at, :updated_at, :uuid, :views).where('id IN (?)', subs)
    @discussions = @discussions.order('updated_at DESC').paginate(:page => params[:page], :per_page => 25)
  end

  def my_discussions
    redirect_if_fail(logged_in?, forums_path, :login); return if performed?

    @discussions = Discussion.select(:id, :user_id, :stickied, :archived, :category_id, :created_at, :updated_at, :uuid, :views).where(:user_id => current_user.id)
    @discussions = @discussions.order('updated_at DESC').paginate(:page => params[:page], :per_page => 25)
  end

  def search
    @discussions = Discussion.select(:id, :user_id, :stickied, :archived, :category_id, :created_at, :updated_at, :uuid, :views)
    viewable = ForumsHelper.viewable_categories(current_user)
    @discussions = @discussions.where('category_id IN (?)', viewable)
    @discussions = @discussions.where(category_id: params[:category_id]) unless params[:category_id].nil?
    @discussions = @discussions.where(:user_id => current_user.id) unless params[:disc].nil?
    @discussions = @discussions.where('id IN (?)', current_user.subscriptions) unless params[:subs].nil?

    unless params[:author].blank?
      author = User.select(:id).find_by_username(params[:author])
      if author
        @discussions = @discussions.where(:user_id => author.id)
      else
        @discussions = @discussions.where(:user_id => 0)
      end
    end

    unless params[:query].blank?
      if params[:query].size >= 3
        revisions = Revision.select(:discussion_id).where(:active => 1).where('MATCH (title,body) AGAINST (? IN BOOLEAN MODE)', params[:query])
        ids = revisions.map { |r| r.discussion_id }

        @discussions = @discussions.where('id IN (?)', ids)
      else
        flash[:error] = 'Search must be at least 3 characters.'
      end
    end

    @discussions = @discussions.order('updated_at DESC').paginate(:page => params[:page], :per_page => 25)
    render :index
  end

  private

  def handle_legacy
    redirect_to Category.find_by_id(params[:topic_id]) if params[:topic_id].present?
  end

  def global_vars
    @categories = Category.select(:id, :name, :desc).all.order('priority DESC')
    @forums = Forum.select(:id, :name).all
  end

end
