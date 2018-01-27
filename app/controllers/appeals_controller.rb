class AppealsController < ApplicationController
  before_action :set_appeal, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  def self.permission_definition
  end

  def appeal
    @punishments = Punishment.where(user: @user, appealed: 0).order('id DESC') unless @user.is_a?(DummyUser)
  end

  # GET /appeals
  def index
    @appeals = Appeal.all
    if params[:open].present? && params[:open] == '1'
      @appeals = @appeals.where(:open => 1).where(:escalated => nil)
    end
    if params[:escalated].present? && params[:escalated] == '1'
      @appeals = @appeals.where(:escalated => 1).where(:open => 1)
    end
    @appeals = @appeals.order('updated_at DESC').paginate(:page => params[:page], :per_page => 15)
  end

  # GET /appeals/1
  def show
    redirect_if_fail(@appeal.can_execute?(@user, :view), '/', :page); return if performed?

    @comments = @appeal.actions
    @comment = Action.new

    if params[:alert].present? && @appeal.can_execute?(current_user, :ping_staff)
      pinged = User.where(:username => params[:alert]).first

      redirect_if_fail(!pinged.nil?, @appeal, 'Unknown player name submitted.'); return if performed?
      redirect_if_fail(@appeal.can_execute?(pinged, :ping_staff), @appeal, 'The player you introduced is not staff and therefore can\'t be pinged'); return if performed?

      Alert.alert(pinged, "AppealPing:#{SecureRandom.hex}", "#{@user.username} has pinged you in #{@appeal.actions.first.user.username}'s appeal", appeal_path(@appeal))
      redirect_to @appeal, notice: "Successfully pinged #{pinged.username}"
    end
  end

  # GET /appeals/new
  def new
    @punishment = Punishment.find_by_id(params[:punishment_id])
    redirect_if_fail(!@punishment.nil?, '/', 'Punishment specified was not found.'); return if performed?

    redirect_if_fail(Appeal.where(:punishment => @punishment).first.nil?, '/', 'An appeal has already been submitted for the specified punishment.'); return if performed?

    @can_appeal = true
    @can_appeal = false if logged_in? && current_user != @punishment.user
    unless logged_in?
      session = Session.where(user: @punishment.user).last
      @can_appeal = false if session.nil? || session.ip != request.ip
    end

    redirect_if_fail(@can_appeal, '/', 'You are not authorized to appeal this punishment. If this is indeed you, you may email #{ORG::EMAIL}'); return if performed?

    @appeal = Appeal.new(punishment: @punishment)
    @comment = Action.new(appeal: @appeal)

    redirect_if_fail(Appeal.can_execute?(@user, @punishment, :view), '/', :page); return if performed?
  end

  # POST /appeals
  def create
    @punishment = Punishment.find_by_id(params[:punishment_id])
    redirect_if_fail(!@punishment.nil?, '/', 'Punishment specified was not found.'); return if performed?

    redirect_if_fail(Appeal.where(:punishment => @punishment).first.nil?, '/', 'An appeal has already been submitted for the specified punishment.'); return if performed?

    @can_appeal = true
    @can_appeal = false if logged_in? && current_user != @punishment.user
    unless logged_in?
      session = Session.where(user: @punishment.user).last
      @can_appeal = false if session.nil? || session.ip != request.ip
    end

    redirect_if_fail(@can_appeal, '/', 'You are not authorized to appeal this punishment. If this is indeed you, you may email #{ORG::EMAIL}'); return if performed?

    return redirect_to :back, :alert => 'Reason cannot be blank' if params[:text].blank?

    @appeal = Appeal.new(punishment: @punishment, open: true, user: @punishment.user)
    @appeal.save
    @comment = Action.new(
        appeal: @appeal,
        text: params[:text],
        user: @user,
        action: :open
    )

    if @comment.save
      @comment.update_appeal_state(@user)
      redirect_to @appeal, notice: 'Appeal was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /appeals/1
  def update
    redirect_if_fail(@appeal.can_execute?(@user, :view), '/', :page); return if performed?
    redirect_if_fail(@appeal.can_execute?(@user, params[:action_val].gsub(' ', '_').to_sym), @appeal, :action); return if performed?

    @comment = Action.new(
        appeal: @appeal,
        text: params[:text],
        user: @user,
        action: params[:action_val].gsub(' ', '_')
    )
    if @comment.save
      @comment.update_appeal_state(@user)
      redirect_to @appeal, notice: 'Action was successfully performed.'
    else
      redirect_to @appeal, notice: 'There was an error when submitting your action.'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_appeal
    @appeal = Appeal.find_by_id(params[:id])

    if @appeal.nil?
      render_404
      return
    end
  end

  def set_user
    @user = current_user
    unless logged_in?
      session = Session.find_by_ip(request.ip)
      @user = session.user unless session.nil?
    end
  end

  # Only allow a trusted parameter "white list" through.
  def appeal_params
    params.require(:appeal).permit(:open, :locked, :text, :action_val)
  end
end
