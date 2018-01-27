class Forums::CategoriesController < Forums::IndexController

  def show
    @category = Category.where(id: params[:id]).first

    redirect_if_fail(@category.can_execute?(current_user, :view), forums_path, 'You do not have permission to view this category.'); return if performed?

    @discussions = Discussion.where(category_id: @category.id)
    unless params[:tag].blank?
      revisions = Revision.select(:discussion_id).where(tag: params[:tag])
      ids = revisions.map { |r| r.discussion_id }
      @discussions = @discussions.where('id IN (?)', ids)
    end
    @discussions = @discussions.order('stickied DESC,updated_at DESC').paginate(:page => params[:page], :per_page => 25)
  end

  def mass_moderate
    @category = Category.where(id: params[:category_id]).first

    redirect_if_fail(@category.can_execute?(current_user, :view), forums_path, 'You do not have permission to view this category.'); return if performed?

    redirect_if_fail(@category.can_mass_moderate?(current_user), forums_path, :action); return if performed?

    success = false

    params[:act_on].each do |dis, val|
      discussion = Discussion.find_by_id(dis)
      next if discussion.nil?
      previous = discussion.revision
      revision = discussion.revision.dup
      revision.user = current_user
      locked = params[:locked].blank? ? revision.locked : params[:locked]
      archived = params[:archived].blank? ? revision.archived : params[:archived]

      if archived != revision.archived && discussion.can_execute?(current_user, discussion.user, :archive)
        revision.archived = archived
      end

      if locked != revision.locked && discussion.can_execute?(current_user, discussion.user, :lock)
        revision.locked = locked
      end

      discussion.archived = revision.archived

      if revision.save
        Discussion.record_timestamps = false
        discussion.save
        Discussion.record_timestamps = true

        previous.active = 0
        previous.save
        success = true
      else
        success = false
        redirect_to :back, error: 'Discussions were not updated'
      end
    end

    if success
      redirect_to category_path(@category), notice: 'Discussions were successfully updated'
      return
    end
  end


end
