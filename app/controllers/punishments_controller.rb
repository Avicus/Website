class PunishmentsController < ApplicationController

  before_action :set_punishment, only: [:show, :edit, :update, :destroy]

  skip_before_action(:check_bans)

  def self.permission_definition
  end

  def index
    if params[:user]
      user = User.find_by_username(params[:user])
      unless user
        flash[:error] = 'User specified in punishment filter not found'
        redirect_to punishments_url
        return
      end
      @punishments = Punishment.where(:user_id => user)
    end

    if params[:staff]
      staff = User.find_by_username(params[:staff])
      unless staff
        flash[:error] = 'Staff specified in punishment filter not found'
        redirect_to punishments_url
        return
      end
      @punishments = Punishment.where(:staff_id => staff)
    end

    if @punishments == nil
      @punishments = Punishment.paginate(:page => params[:page], :per_page => 25).order('date DESC')
    else
      @punishments = @punishments.paginate(:page => params[:page], :per_page => 25).order('date DESC')
    end
  end

  def show
    redirect_if_fail(@punishment.can_execute?(current_user, :view), punishments_path, :page); return if performed?

    @user = @punishment.user
    @staff = @punishment.staff
  end

  def edit
    redirect_if_fail(@punishment.can_execute?(current_user, :update), punishments_path, :action); return if performed?

    @punish_types = {
        'Mute' => :mute,
        'Warn' => :warn,
        'Kick' => :kick,
        'Permanent Ban' => :ban,
        'Temporary Ban' => :tempban,
        'Website Ban' => :web_ban,
        'Temporary Website Ban' => :web_tempban,
        'Tournament Ban' => :tournament_ban,
        'Discord Warn' => :discord_warn,
        'Discord Kick' => :discord_kick,
        'Temporary Discord Ban' => :discord_tempban,
        'Discord Ban' => :discord_ban
    }

    @punish_types.delete_if { |t, i| !Punishment.can_issue?(current_user, i) }

    @editable = editable_fields(@punishment)
  end

  def update
    redirect_if_fail(@punishment.can_execute?(current_user, :update), punishments_path, :action); return if performed?
    redirect_if_fail(@punishment.can_issue?(current_user, params[:punishment][:type]), @punishment, 'You may not issue punnishments of this type.'); return if performed?

    @punishment.expires = DateTime.strptime(params[:punishment][:expires], '%m/%d/%Y %H:%M') unless params[:punishment][:expires].blank?
    @punishment.expires = nil if params[:punishment][:expires].blank?

    if !params[:punishment][:staff].nil? && !params[:punishment][:staff].empty?
      staff = User.where(:username => params[:punishment][:staff]).first
    end

    staff = @punishment.staff unless Punishment.can_issue_as_others?(current_user)

    unless staff
      flash[:alert] = 'User specified in staff field not found'
      redirect_to @punishment
      return
    end

    user = User.where(:username => params[:punishment][:user]).first
    unless user
      flash[:alert] = 'User specified in user field not found'
      redirect_to @punishment
      return
    end

    redirect_if_fail(@punishment.can_issue_as?(current_user, staff), @punnishment, 'You may not issue punnishments as this user.'); return if performed?

    @punishment.user = user
    @punishment.staff = staff

    if @punishment.update(allowed_params)
      redirect_to @punishment, notice: 'Punishment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    redirect_if_fail(@punishment.can_execute?(current_user, :delete), punishments_path, :action); return if performed?

    @punishment.destroy
    redirect_to punishments_url, notice: 'Punishment was successfully deleted.'
  end

  def punish
    redirect_if_fail(Punishment.can_create?(current_user), request.referer, :action); return if performed?
    redirect_if_fail(Punishment.can_issue?(current_user, params[:punishment][:type]), request.referer, 'You may not issue punishments of this type.'); return if performed?

    redirect_if_fail(!params[:punish].nil?, request.referer, 'You must provide at least one user to punish.'); return if performed?
    redirect_if_fail(!params[:punishment][:reason].blank?, request.referer, 'You must provide a reason.'); return if performed?

    expires = DateTime.strptime(params[:punishment][:expires], '%m/%d/%Y %H:%M') unless params[:punishment][:expires].blank?
    expires = nil if params[:punishment][:expires].blank? | "#{params[:punishment][:type]}".eql?('warn') | "#{params[:punishment][:type]}".eql?('kick')

    unless params[:punishment][:staff] == ''
      staff = User.where(:username => params[:punishment][:staff]).first.id
      unless staff
        flash[:alert] = 'User specified in staff field not found'
        redirect_to request.referer
        return
      end
    end

    redirect_if_fail(Punishment.can_issue_as?(current_user, staff), request.referer, 'You may not issue punishments as this user.'); return if performed?

    users = []
    params[:punish].each do |user, val|
      users << user
    end unless params[:punish].nil?

    punish_users(staff, params[:punishment][:reason], params[:punishment][:type], expires, users)

    flash[:notice] = "Successfully #{users.size > 1 ? 'mass ' : ''}punished."
    redirect_to request.referer
  end


  private

  def punish_users(punisher, reason, type, expires, user_ids = [])
    inserts = []
    now = Time.now.to_s(:db)
    user_ids.each do |user|
      inserts.push "('#{now}', '#{reason}' #{punisher.nil? ? '' : ", '#{punisher}'"}, '#{type}', #{user} #{expires.nil? ? '' : ", '#{expires.to_s(:db)}'"})"
    end
    sql = "INSERT INTO `punishments` (`date`, `reason` #{punisher.nil? ? '' : ', `staff_id`'}, `type`, `user_id`#{expires.nil? ? '' : ', `expires`'}) VALUES #{inserts.join(', ')}"
    Punishment.connection.execute sql
  end

  def set_punishment
    @punishment = Punishment.find_by_id(params[:id])

    if @punishment.nil?
      render_404
      return
    end
  end

  def allowed_params
    params.require(:punishment).permit(:type, :reason, :date, :appealed)
  end

end
