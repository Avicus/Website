class PlayController < ApplicationController
  skip_before_action(:check_bans)

  def self.permission_definition
  end

  def index
    @player_count = get_player_count
    @servers = Server.all.select { |server| server.online? && !server.permissible }.sort { |a, b| b.player_count - a.player_count }
  end

  def game
  end

  def server
    server = Server.find_by_id(params[:server_id])

    if server
      render :partial => 'server', :locals => {:server => server}
    else
      render :text => '', :status => 404
    end
  end

  def players
    render :json => {players: get_player_count}
  end

  def get_player_count
    Server.all.select { |server| server.online? && !server.permissible }.map(&:real_player_count).sum
  end
end
