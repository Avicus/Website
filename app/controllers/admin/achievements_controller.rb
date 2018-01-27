class Admin::AchievementsController < Admin::IndexController
  before_action :perms_check
  before_action :set_achievement, only: [:show, :update, :destroy, :reward, :revoke]

  def self.permission_definition
  end

  def index
    @achievements = Achievement.all.order(:name).paginate(:per_page => 20, :page => params[:page])
  end

  def new
    @achievement = Achievement.new
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :create), admin_achievements_path, :action); return if performed?

    # Edit all on creation
    @editable = Achievement.perm_fields
  end

  def show
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :update), admin_achievements_path, :action); return if performed?

    @editable = editable_fields(@achievement)
  end

  def create
    @achievement = Achievement.new(achievement_params)
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :create), admin_achievements_path, :action); return if performed?

    if @achievement.save
      admin_log(:achievements, current_user, :create, @achievement.name)
      redirect_to admin_achievement_path(@achievement), notice: 'Achievement was successfully created.'
    else
      @editable = Achievement.perm_fields
      render :new
    end
  end

  def reward
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :reward), admin_achievements_path, :action); return if performed?

    user = User.find_by_name(params[:user])
    redirect_if_fail(!user.nil?, admin_achievement_path(@achievement), 'User not found!'); return if performed?

    AchievementReceiver.create(achievement: @achievement, user: user)
    redirect_to [:admin, @achievement]
  end

  def revoke
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :revoke), admin_achievements_path, :action); return if performed?
    user = User.find_by_id(params[:user])
    redirect_if_fail(!user.nil?, admin_achievement_path(@achievement), 'User not found!'); return if performed?

    found = AchievementReceiver.where(user: user, achievement: @achievement).first
    redirect_if_fail(!found.nil?, admin_achievement_path(@achievement), 'User does not have this achievement!'); return if performed?
    found.destroy

    redirect_to [:admin, @achievement]
  end

  def update
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :update), admin_achievements_path, :action); return if performed?

    if @achievement.update(achievement_params)
      admin_log(:achievements, current_user, :update, @achievement.name)
      redirect_to admin_achievement_path(@achievement), notice: 'Achievement was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    redirect_if_fail(@achievement.can_execute?(current_user, :actions, :destroy), admin_achievements_path, :action); return if performed?

    @achievement.destroy
    admin_log(:achievements, current_user, :destroy, @achievement.name)
    redirect_to admin_achievements_path, notice: 'Achievement was successfully destroyed.'
  end

  private
  def set_achievement
    if params[:id].blank?
      @achievement = Achievement.find(params[:achievement_id])
    else
      @achievement = Achievement.find(params[:id])
    end
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :achievements, true), '/', :page)
  end

  # Only allow a trusted parameter "white list" through.
  def achievement_params
    params.require(:achievement).permit(:name, :slug, :description)
  end
end
