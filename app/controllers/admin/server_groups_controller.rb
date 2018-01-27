class Admin::ServerGroupsController < Admin::IndexController
  before_action :set_server_group, only: [:show, :update, :destroy, :add_member, :remove_member]
  before_action :perms_check

  def self.permission_definition

  end

  def index
    @server_groups = ServerGroup.all.order(:name)
  end

  def show
    @editable = editable_fields(@server_group)
  end

  def new
    @server_group = ServerGroup.new
    @editable = editable_fields(@server_group)
    redirect_if_fail(@server_group.can_execute?(current_user, :create), admin_server_groups_url, :action); return if performed?

    render :new
  end

  def create
    @server_group = ServerGroup.new(server_group_params)
    redirect_if_fail(@server_group.can_execute?(current_user, :create), admin_server_groups_url, :action); return if performed?

    if @server_group.save
      admin_log(:server_groups, current_user, :create, @server_group.name)
      redirect_to [:admin, @server_group], notice: 'Server group was successfully created.'
    else
      render :new
    end
  end

  def update
    redirect_if_fail(@server_group.can_execute?(current_user, :update), admin_server_groups_url, :action); return if performed?

    @server_group.data = params[:server_group][:data] unless params[:server_group][:data].nil? || params[:server_group][:data] == {}

    if @server_group.update(server_group_params)
      admin_log(:server_groups, current_user, :update, @server_group.name)
      redirect_to [:admin, @server_group], notice: 'Server group was successfully updated.'
    else
      render :show
    end
  end

  def destroy
    redirect_if_fail(@server_group.can_execute?(current_user, :destroy), admin_server_groups_url, :action); return if performed?

    @server_group.destroy
    admin_log(:server_groups, current_user, :destroy, @server_group.name)
    redirect_to admin_server_groups_url, notice: 'Server group was successfully destroyed.'
  end

  # Members

  def add_member
    redirect_if_fail(@server_group.can_execute?(current_user, :add_member), admin_server_groups_url, :action); return if performed?
    server = Server.where(:name => params[:server]).first
    unless server
      flash[:alert] = 'Server not found'
      redirect_to [:admin, @server_group]
      return
    end
    unless @server_group.servers.exists?(server.id)
      server.server_group_id = @server_group.id
      server.save
      admin_log(:server_groups, current_user, :add_member, "#{@server_group.name} -> #{server.name}")
    end
    redirect_to [:admin, @server_group]
  end

  def remove_member
    redirect_if_fail(@server_group.can_execute?(current_user, :remove_member), admin_server_groups_url, :action); return if performed?
    server = Server.where(:name => params[:server]).first
    if @server_group.servers.exists?(server.id)
      server.server_group_id = nil
      server.save
      flash[:notice] = 'Member removed'
      admin_log(:server_groups, current_user, :remove_member, "#{@server_group.name} -> #{server.name}")
    else
      flash[:alert] = 'Member was never a part of this group'
    end
    redirect_to [:admin, @server_group]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_server_group
    if params[:id].blank?
      @server_group = ServerGroup.find(params[:server_group_id])
    else
      @server_group = ServerGroup.find(params[:id])
    end
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :server_groups, true), '/', :page)
  end

  # Only allow a trusted parameter "white list" through.
  def server_group_params
    params.require(:server_group).permit(:name, :slug, :description, :icon)
  end
end
