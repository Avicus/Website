class LivestreamController < ApplicationController

  skip_before_action(:check_bans)

  def self.permission_definition
  end

  def index
    channels = Livestream.all
    @online = channels.where('id IN (?)', get_cache('twitch.online-ids'))
    @offline = (channels-@online) | (@online-channels)
  end

  def create
    redirect_if_fail(Livestream.can_execute?(current_user, :create), '/live', :action); return if performed?

    @livestream = Livestream.new(livestream_params)

    @livestream.save
    redirect_to '/live'
  end

  def destroy
    redirect_if_fail(Livestream.can_execute?(current_user, :destroy), '/live', :action); return if performed?

    @livestream = Livestream.find_by_id(params[:id])

    @livestream.destroy
    redirect_to '/live', notice: 'Stream was successfully deleted.'
  end

  private

  def livestream_params
    params.require(:livestream).permit(:channel)
  end
end
