class AlertsController < ApplicationController

  before_action :redirect_login

  def self.permission_definition
  end

  def index
    if params[:clear] && params[:user_id].to_i == current_user.id
      current_user.alerts.delete_all
      flash[:notice] = 'All alerts have been cleared.'
    end

    @alerts = current_user.alerts.order('created_at DESC').paginate(:page => params[:page], :per_page => 15)
  end

  def delete
    current_user.alerts.where(:id => params[:id]).delete_all
    flash[:notice] = 'You have dismissed an alert.'
    redirect_to alerts_url
  end
end
