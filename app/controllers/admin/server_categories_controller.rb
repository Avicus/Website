class Admin::ServerCategoriesController < Admin::IndexController
  before_action :set_server_category, only: [:show, :update, :destroy, :add_member, :remove_member]
  before_action :perms_check

  def self.permission_definition

  end

  def index
    @server_categories = ServerCategory.all.order(:name)
  end

  def show
    @editable = editable_fields(@server_category)
  end

  def new
    @server_category = ServerCategory.new
    @editable = editable_fields(@server_category)
    redirect_if_fail(@server_category.can_execute?(current_user, :create), admin_server_categories_url, :action); return if performed?

    render :new
  end

  def create
    @server_category = ServerCategory.new(server_category_params)
    redirect_if_fail(@server_category.can_execute?(current_user, :create), admin_server_categories_url, :action); return if performed?

    if @server_category.save
      redirect_to [:admin, @server_category], notice: 'Server category was successfully created.'
      admin_log(:server_categories, current_user, :create, @server_category.name)
    else
      render :new
    end
  end

  def update
    redirect_if_fail(@server_category.can_execute?(current_user, :update), admin_server_categories_url, :action); return if performed?

    if @server_category.update(server_category_params)
      redirect_to [:admin, @server_category], notice: 'Server category was successfully updated.'
      admin_log(:server_categories, current_user, :update, @server_category.name)
    else
      render :show
    end
  end

  def destroy
    redirect_if_fail(@server_category.can_execute?(current_user, :destroy), admin_server_categories_url, :action); return if performed?

    @server_category.destroy
    admin_log(:server_categories, current_user, :destroy, @server_category.name)
    redirect_to admin_server_categories_url, notice: 'Server category was successfully destroyed.'
  end

  # Members

  def add_member
    redirect_if_fail(@server_category.can_execute?(current_user, :add_member), admin_server_groups_url, :action); return if performed?
    server = Server.where(:name => params[:server]).first
    unless server
      flash[:alert] = 'Server not found'
      redirect_to [:admin, @server_category]
      return
    end
    server.server_category_id = @server_category.id
    server.save
    admin_log(:server_categories, current_user, :add_member, "#{@server_category.name} -> #{server.name}")
    redirect_to [:admin, @server_category]
  end

  def remove_member
    redirect_if_fail(@server_category.can_execute?(current_user, :remove_member), admin_server_groups_url, :action); return if performed?
    server = Server.where(:name => params[:server]).first
    if @server_category.servers.exists?(server.id)
      server.server_category_id = nil
      server.save
      flash[:notice] = 'Server removed'
      admin_log(:server_categories, current_user, :remove_member, "#{@server_category.name} -> #{server.name}")
    else
      flash[:alert] = 'Member was never a part of this category'
    end
    redirect_to [:admin, @server_category]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_server_category
    @server_category = ServerCategory.find(params[:id].blank? ? params[:server_category_id] : params[:id])
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :server_categories, true), '/', :page)
  end

  # Only allow a trusted parameter "white list" through.
  def server_category_params
    result = params.require(:server_category).permit!
    result[:communication_options] = params[:server_category][:communication_options]
    result[:tracking_options] = params[:server_category][:tracking_options]
    result[:infraction_options] = params[:server_category][:infraction_options]
    result
  end
end
