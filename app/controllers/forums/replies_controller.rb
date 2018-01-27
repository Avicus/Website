class Forums::RepliesController < Forums::IndexController

  before_action :set_reply, only: [:show, :edit, :update, :revisions]

  def show
    redirect_if_fail(@reply.can_view?(current_user), @discussion, 'You do not have permission to view this reply.'); return if performed?
  end

  def revisions
    redirect_if_fail(@reply.can_view?(current_user), @discussion, 'You do not have permission to view this reply.'); return if performed?
    redirect_if_fail(@reply.can_view_revisions?(current_user), forums_path, 'You do not have permissions to view revisions.'); return if performed?
  end

  def new
    @reply = Reply.new
    @revision = Revision.new

    if params[:reply_id].presence
      @original = Reply.find(params[:reply_id])
      @discussion = @original.discussion
      @category = @discussion.category
      redirect_if_fail(@discussion.can_reply?(current_user), @discussion, 'You do not have permission to reply to topics in this category.'); return if performed?
    else
      flash[:error] = 'Invalid reply id specified.'
      redirect_to '/'
    end
  end

  def preview
    render :text => html_safe(params[:body])
  end

  def edit
    redirect_if_fail(@reply.can_edit?(current_user), forums_path, 'You do not have permission to edit this reply.'); return if performed?
    if @redirected
      return
    end

    @revision = Revision.new
  end

  # POST /replies
  def create
    @discussion = Discussion.find(params[:discussion_id])
    @category = @discussion.category

    redirect_if_fail(@discussion.can_reply?(current_user), @discussion, 'You do not have permission to reply to topics in this category.'); return if performed?

    wait = get_cache "reply-cooldown.#{current_user.id}", false

    @reply = Reply.new
    @reply.discussion_id = params[:discussion_id]
    @reply.user_id = current_user.id

    @discussion = Discussion.find(params[:discussion_id])

    if @redirected
      return
    end

    revision = Revision.new(revision_params)
    revision.title = 'reply'
    revision.user_id = current_user.id
    revision.discussion_id = @reply.discussion_id
    revision.category_id = @discussion.category_id
    revision.original = 1
    revision.active = 1

    if params[:reply_id].presence
      @reply.reply_id = params[:reply_id]
    end

    if wait
      flash[:error] = 'Please wait between creating new posts.'
      redirect_to @discussion
      return
    end

    if revision.body.scan(/{tag=(.*?)}/).size > 100
      flash[:error] = 'You may not tag more than 100 users!'
      redirect_to @discussion
      return
    end

    set_cache "reply-cooldown.#{current_user.id}", true, @category.can_override_time?(current_user) ? 10.seconds : 60.seconds

    toreplace = {}
    toalert = []
    revision.body.scan(/{tag=(.*?)}/).each do |t|
      user = User.find_by_username(t.first)
      unless user.nil?
        toreplace[:"{tag=#{user.name}}"] = "{tag=#{user.uuid}}"
        toalert = toalert | [user] if @reply.can_see_tag_alerts?(user, @category)
      end
    end

    finalbody = revision.body
    toreplace.each do |key, value|
      finalbody.gsub!("#{key}", "#{value}")
    end
    revision.body = finalbody

    if revision.save
      @reply.save
      revision.reply_id = @reply.id
      revision.save

      d = @reply.discussion.revision
      d.touch

      @reply.discussion.touch

      @reply.discussion.user.alert("Reply:#{@reply.id}", "#{@reply.user.name} has replied to your post.", "#{@reply.link}") unless @reply.discussion.user == @reply.user || !@reply.can_view?(@reply.discussion.user)

      if @reply.reply.presence
        @reply.reply.user.alert("Reply:#{@reply.id}", "#{@reply.user.name} has replied to your post.", "#{@reply.link}") if @reply.can_view?(@reply.reply.user)
      end

      toalert.each do |a|
        Alert.alert(a, "PostTagReply:#{@reply.id}", "You have been tagged in a reply by #{@reply.author.username}", @reply.link)
      end

      redirect_to @reply.link, notice: 'Reply was successfully created.'
    else
      @discussion = @reply.discussion
      @revision = revision
      render action: 'new'
    end
  end

  # PATCH/PUT /replies/1
  def update
    redirect_if_fail(@reply.can_edit?(current_user), @discussion, 'You do not have permission to edit this reply.'); return if performed?

    previous = @reply.revision

    revision = Revision.new(revision_params)
    revision.title = 'reply'
    revision.user_id = current_user.id
    revision.category_id = @discussion.category_id
    revision.reply_id = @reply.id
    revision.discussion_id = @discussion.id
    revision.active = 1

    if revision.body.scan(/{tag=(.*?)}/).size > 100
      flash[:error] = 'You may not tag more than 100 users!'
      @revision = revision
      render action: 'edit'
      return
    end

    toreplace = {}
    toalert = []
    revision.body.scan(/{tag=(.*?)}/).each do |t|
      user = User.find_by_username(t.first)
      unless user.nil?
        toreplace[:"{tag=#{user.name}}"] = "{tag=#{user.uuid}}"
        toalert = toalert | [user] if @reply.can_see_tag_alerts?(user, @category)
      end
    end

    previous.body.scan(/{tag=(.*?)}/).each do |t|
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

      toalert.each do |a|
        Alert.alert(a, "PostTagReply:#{@reply.id}", "You have been tagged in a reply by #{@reply.author.username}", @reply.link)
      end

      redirect_to @reply.link, notice: 'Reply was successfully updated'
      previous.active = 0
      previous.save
    else
      @revision = revision
      render action: 'edit'
    end
  end

  def set_reply
    @reply = Reply.find(params[:id])
    @discussion = @reply.discussion
    @category = @discussion.category
  end

  def revision_params
    params[:revision].delete :archived? unless @reply.can_archive?(current_user)
    params.require(:revision).permit(:body, :category_id, :archived, :sanctioned)
  end

end
