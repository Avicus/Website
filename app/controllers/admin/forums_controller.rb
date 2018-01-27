class Admin::ForumsController < Admin::IndexController
  before_action :set_forum, only: [:edit_forum, :update_forum, :destroy_forum]
  before_action :set_category, only: [:edit_category, :update_category, :destroy_category]
  before_action :perms_check


  def self.permission_definition

  end

  # GET /forums
  def index
    @forums = Forum.all.order('priority DESC')
    @categories = Category.all
  end

  # POST /forums
  def create_forum
    @forum = Forum.new(forum_params)
    redirect_if_fail(@forum.can_execute?(current_user, :create), admin_forums_url, :action); return if performed?

    # Edit all on creation
    @editable = Forum.perm_fields

    if @forum.save
      admin_log(:forums, current_user, :create_forum, @forum.name)
      redirect_to action: :index, notice: 'Forum was successfully created.'
    else
      render action: :index, notice: 'An error occured while creating the forum'
    end
  end

  def edit_forum
    redirect_if_fail(@forum.can_execute?(current_user, :update), admin_forums_url, :action); return if performed?

    @editable = editable_fields(@forum)
  end

  # PATCH/PUT /forums/1
  def update_forum
    redirect_if_fail(@forum.can_execute?(current_user, :update), admin_forums_url, :action); return if performed?

    if @forum.update(forum_params)
      redirect_to action: :index, notice: 'Forum was successfully updated.'
      admin_log(:forums, current_user, :update_forum, @forum.name)
    else
      render action: :edit_forum, notice: 'An error occured while updating the forum'
    end
  end

  # DELETE /forums/1
  def destroy_forum
    redirect_if_fail(@forum.can_execute?(current_user, :destroy), admin_forums_url, :action); return if performed?

    @forum.destroy
    admin_log(:forums, current_user, :destroy_forum, @forum.name)
    redirect_to admin_forums_url, notice: 'Forum was successfully destroyed.'
  end

  # POST /categories
  def create_category
    @category = Category.new(category_params)
    redirect_if_fail(@category.admin_can_execute?(current_user, :create), admin_forums_url, :action); return if performed?

    # Edit all on creation
    @editable = Category.perm_fields

    if @category.save
      redirect_to action: :index, notice: 'Forum was successfully created.'
      admin_log(:forums, current_user, :create_category, @category.name)
    else
      render action: :index, notice: 'An error occured while creating the category'
    end
  end

  def edit_category
    redirect_if_fail(@category.admin_can_execute?(current_user, :update), admin_forums_url, :action); return if performed?

    @forums = Forum.all
    @editable = editable_fields(@category)
  end

  # PATCH/PUT /categories/1
  def update_category
    redirect_if_fail(@category.admin_can_execute?(current_user, :update), admin_forums_url, :action); return if performed?

    if @category.update(category_params)
      redirect_to action: :index, notice: 'Category was successfully updated.'
      admin_log(:forums, current_user, :update_category, @category.name)
    else
      render action: :edit_category, notice: 'An error occured while updating the category'
    end
  end

  # DELETE /categories/1
  def destroy_category
    redirect_if_fail(@category.admin_can_execute?(current_user, :destroy), admin_forums_url, :action); return if performed?

    @category.destroy
    admin_log(:forums, current_user, :destroy_category, @category.name)
    redirect_to admin_forums_url, notice: 'Forum was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_forum
    @forum = Forum.find(params[:id])
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :forums, true), '/', :page)
  end

  # Only allow a trusted parameter "white list" through.
  def forum_params
    params.require(:forum).permit(:name, :priority)
  end

  def category_params
    params.require(:category).permit(:name, :priority, :tags, :desc, :forum_id)
  end
end
