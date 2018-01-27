class Admin::AnnouncementsController < Admin::IndexController

  before_action :set_announcement, only: [:edit, :copy, :update, :destroy]
  before_action :perms_check

  def self.permission_definition
  end

  def index
    @announcements = Announcement.all.order(:enabled, :motd, :motd_format, :popup, :lobby, :tips, :web)
  end

  def new
    @announcement = Announcement.new
    redirect_if_fail(@announcement.can_execute?(current_user, :actions, :create), admin_announcements_url, :action); return if performed?

    # Edit all on creation
    @editable = Announcement.perm_fields
  end

  def copy
    redirect_if_fail(@announcement.can_execute?(current_user, :actions, :create), admin_announcements_url, :action); return if performed?

    @announcement = @announcement.dup
    @announcement.enabled = false

    # Edit all on creation
    @editable = Announcement.perm_fields

    render :new
  end

  def edit
    redirect_if_fail(@announcement.can_execute?(current_user, :actions, :update), admin_announcements_url, :action); return if performed?

    @editable = editable_fields(@announcement)
  end

  def create
    @announcement = Announcement.new(announcement_params)
    redirect_if_fail(@announcement.can_execute?(current_user, :actions, :create), admin_announcements_url, :action); return if performed?

    if @announcement.save
      admin_log(:announcements, current_user, :create, @announcement.body)
      redirect_to admin_announcements_path, notice: 'Announcement was successfully created.'
    else
      @editable = Announcement.perm_fields
      render :new
    end
  end

  def update
    redirect_if_fail(@announcement.can_execute?(current_user, :actions, :update), admin_announcements_url, :action); return if performed?

    if @announcement.update(announcement_params)
      admin_log(:announcements, current_user, :update, @announcement.body)
      redirect_to admin_announcements_path, notice: 'Announcement was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    redirect_if_fail(@announcement.can_execute?(current_user, :actions, :destroy), admin_announcements_url, :action); return if performed?

    @announcement.destroy
    admin_log(:announcements, current_user, :destroy, @announcement.body)
    redirect_to admin_announcements_url, notice: 'Announcement was successfully destroyed.'
  end

  private
  def set_announcement
    @announcement = Announcement.find(params[:id] || params[:announcement_id])
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :announcements, true), '/', :page)
  end

  def announcement_params
    params.require(:announcement).permit(:body, :enabled, :motd, :motd_format, :popup, :lobby, :tips, :web, :permission)
  end
end
