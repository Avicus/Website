class Forums::DiscussionsController < Forums::IndexController
  protect_from_forgery

  before_action :set_discussion, only: [:show, :reply, :edit, :update, :revisions, :subscribe]
  before_action :perms_check, only: [:show, :reply, :edit, :update, :revisions, :subscribe]

  def preview
    render :text => params[:body]
  end

  def show
    if logged_in?
      impressionist(@discussion)
    end

    @page = params[:page].presence ? params[:page].to_i : 1

    @all = @discussion.public_replies current_user

    @sanctioned = @all.to_a.select { |r| r.revision.sanctioned? }

    @replies = @all.paginate(:page => params[:page], :per_page => 20).order('created_at')

    if params[:reply]
      search = Reply.find(params[:reply])
      index = @all.index search
      if index == nil
        flash[:error] = 'Unable to find linked reply.'
        redirect_to @discussion
        return
      end
      page = (index / @replies.per_page) + 1
      redirect_to "/forums/discussions/#{@discussion.uuid}?page=#{page}#reply#{search.id}"
      return
    end

    if logged_in?
      @discussion.mark_as_read! :for => current_user
      @all.each do |reply|
        reply.mark_as_read! :for => current_user
        if reply.id > @replies.last.id
          break
        end
      end
    end
  end

  def revisions
    redirect_if_fail(@discussion.can_view_revisions?(current_user), forums_path, 'You do not have permissions to view revisions.'); return if performed?
  end

  def new
    @category = Category.where(id: params['cat_id']).first

    if @category.nil?
      flash[:error] = 'Invalid category id specified.'
      redirect_to '/forums'
      return
    end

    redirect_if_fail(@category.can_execute?(current_user, :create), forums_path, 'You do not have permission to create topics in this category.'); return if performed?

    @discussion = Discussion.new(category_id: @category.id)
    @revision = Revision.new

    @options = ForumsHelper.options_for_select(current_user)
  end

  def edit
    redirect_if_fail(@discussion.can_execute_state?(current_user, :edit), forums_path, 'You do not have permission to create edit this topic.'); return if performed?

    @revision = Revision.new
  end

  def reply
    redirect_if_fail(@discussion.can_reply?(current_user), @discussion, 'You do not have permission to reply to this topic.'); return if performed?

    @reply = Reply.new
    @revision = Revision.new
  end

  def create
    @category = Category.find_by_id(params[:revision][:category_id])
    redirect_if_fail(@category.can_execute?(current_user, :create), forums_path, 'You do not have permission to create topics in this category.'); return if performed?

    if @redirected
      return
    end

    wait = get_cache "post-cooldown.#{current_user.id}", false

    revision = Revision.new(revision_params)
    revision.user_id = current_user.id
    revision.active = 1
    revision.original = 1

    @discussion = Discussion.new
    @discussion.user_id = current_user.id
    @discussion.category_id = revision.category_id
    @discussion.stickied = revision.stickied
    @discussion.archived = revision.archived

    if revision.body.scan(/{tag=(.*?)}/).size > 100
      flash[:error] = 'You may not tag more than 100 users!'
      @revision = revision
      @options = ForumsHelper.options_for_select(current_user)
      @category = revision.category
      render action: 'new'
      return
    end

    toreplace = {}
    toalert = []
    revision.body.scan(/{tag=(.*?)}/).first(100).each do |t|
      user = User.find_by_username(t.first)
      unless user.nil?
        toreplace[:"{tag=#{user.name}}"] = "{tag=#{user.uuid}}"
        toalert = toalert | [user]
      end
    end

    finalbody = revision.body
    toreplace.each do |key, value|
      finalbody.gsub!("#{key}", "#{value}")
    end
    revision.body = finalbody

    if wait == false && revision.save
      @discussion.uuid = SecureRandom.hex[0..8]
      @discussion.save!

      revision.discussion_id = @discussion.id
      revision.save

      set_cache "post-cooldown.#{current_user.id}", true, @category.can_override_time?(current_user) ? 10.seconds : 2.minutes

      toalert.each do |a|
        Alert.alert(a, "PostTag:#{@discussion.id}", "You have been tagged by #{@discussion.author.username}", @discussion.link) if @discussion.can_see_tag_alerts?(a, @category)
      end

      redirect_to @discussion, notice: 'Discussion was successfully created.'
    else
      if wait
        flash[:error] = 'Please wait between creating new posts.'
      end
      @revision = revision
      @options = ForumsHelper.options_for_select(current_user)
      @category = revision.category
      render action: 'new'
    end
  end

  def update
    redirect_if_fail(@discussion.can_execute_state?(current_user, :edit), forums_path, 'You do not have permission to create edit this topic.'); return if performed?

    @category = Category.find_by_id(params[:revision][:category_id])

    previous = @discussion.revision
    revision = Revision.new(revision_params)

    if previous.archived != revision.archived && !@discussion.can_execute?(current_user, @discussion.user, :archive)
      revision.archived = previous.archived
    end

    if previous.stickied != revision.stickied && !@discussion.can_execute?(current_user, @discussion.user, :sticky)
      revision.stickied = previous.stickied
    end

    if previous.locked != revision.locked && !@discussion.can_execute?(current_user, @discussion.user, :lock)
      revision.locked = previous.locked
    end

    redirect_if_fail(@category.can_execute?(current_user, :create), forums_path, 'You do not have permission to create topics in this category.'); return if performed?

    revision.user_id = current_user.id
    revision.discussion_id = @discussion.id
    revision.active = 1

    @discussion.category_id = revision.category_id
    @discussion.stickied = revision.stickied
    @discussion.archived = revision.archived

    if revision.body.scan(/{tag=(.*?)}/).size > 100
      flash[:error] = 'You may not tag more than 100 users!'
      @revision = revision
      render :action => 'edit'
      return
    end

    toreplace = {}
    toalert = []
    revision.body.scan(/{tag=(.*?)}/).each do |t|
      user = User.find_by_username(t.first)
      unless user.nil?
        toreplace[:"{tag=#{user.name}}"] = "{tag=#{user.uuid}}"
        toalert = toalert | [user] if @discussion.can_see_tag_alerts?(user, @category)
      end
    end

    previous.body.scan(/{tag=(.*?)}/).first(100).each do |t|
      user = User.find_by_username(t.first)
      unless user.nil?
        toalert - [user]
      end
    end

    finalbody = revision.body
    toreplace.each do |key, value|
      finalbody.gsub!("#{key}", "#{value}")
    end
    revision.body = finalbody

    if revision.save
      Discussion.record_timestamps = false
      @discussion.save
      Discussion.record_timestamps = true

      previous.active = 0
      previous.save

      toalert.each do |a|
        Alert.alert(a, "PostTag:#{@discussion.id}", "You have been tagged by #{@discussion.author.username}", @discussion.link)
      end

      redirect_to @discussion, notice: 'Discussion was successfully updated'
    else
      @revision = revision
      render :action => 'edit'
    end
  end

  def subscribe
    redirect_if_fail(@discussion.can_execute_state?(current_user, :view), forums_path, 'You do not have permission to create edit this topic.'); return if performed?

    if @redirected
      return
    end

    if logged_in? == false || params[:user_id].to_i != current_user.id
      flash[:error] = 'An error occurred when processing your request.'
      redirect_to :back
      return
    end

    subscribed = current_user.subscriptions.include? @discussion.id

    if subscribed
      flash[:notice] = 'You have unsubscribed from this discussion.'
      Subscription.where(:user_id => current_user.id).where(:discussion_id => @discussion.id).delete_all
    else
      flash[:notice] = 'You have subscribed to this discussion.'
      sub = Subscription.new(:user_id => current_user.id, :discussion_id => @discussion.id)
      sub.save
    end

    redirect_to :back
  end

  def perms_check
    redirect_if_fail(@category.can_execute?(current_user, :view), forums_path, 'You do not have permission to view topics in this category.'); return if performed?
    redirect_if_fail(@discussion.can_execute_state?(current_user, :view), forums_path, 'You do not have permission to view this topic.'); return if performed? unless @discussion.nil?
  end

  def set_discussion
    @discussion = Discussion.find_by_uuid(params[:id])

    if @discussion.blank?
      render_404
      return
    end

    @category = @discussion.category

    @options = ForumsHelper.options_for_select(current_user)
  end

  def revision_params
    params.require(:revision).permit(:title, :body, :category_id, :archived, :stickied, :locked, :tag)
  end

end
