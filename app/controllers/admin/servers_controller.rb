class Admin::ServersController < Admin::IndexController
  before_action :set_server, only: [:show, :start_log, :read_log, :execute_command, :update, :destroy, :deploy]
  before_action :perms_check

  def self.permission_definition
  end

  def index
    @servers = Server.all.order(:name)
  end

  def show
    @editable = editable_fields(@server)
  end

  def new
    @server = Server.new
    # Edit all on creation
    @editable = Server.perm_fields
  end

  def create
    @server = Server.new(server_params)
    @editable = Server.perm_fields

    if @server.save
      admin_log(:servers, current_user, :create, @server.name)
      redirect_to [:admin, @server], notice: 'Server was successfully created.'
    else
      render :new
    end
  end

  def update
    @editable = editable_fields(@server)
    if @server.update(server_params)
      admin_log(:servers, current_user, :update, @server.name)
      redirect_to [:admin, @server], notice: 'Server was successfully updated.'
    else
      render :show
    end
  end

  def destroy
    @server.destroy
    admin_log(:servers, current_user, :destroy, @server.name)
    redirect_to admin_servers_url, notice: 'Server was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_server
    @server = Server.find(params[:id] || params[:server_id])
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :servers, true), '/', :page)
  end

  # Only allow a trusted parameter "white list" through.
  def server_params
    params.require(:server).permit(:name, :port, :auto_deploy, :path, :screen_session, :branch_list, :permissible)
  end
end
