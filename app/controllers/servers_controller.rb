class ServersController < ApplicationController
  skip_before_action(:check_bans)

  def self.permission_definition
  end

  def index
    @servers = Server.all
  end
end
