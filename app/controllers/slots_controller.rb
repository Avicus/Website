class SlotsController < ApplicationController

  before_action :ensure_logged_in, :except => :index
  before_action :parse_dates, :only => [:server_count, :create]
  before_action :ensure_leader, :only => [:create, :cancel]

  def self.permission_definition
    {
        :global_options => {
            options: [:USER_VALUE],
            def_option: 0
        },
        :permissions_sets => [{
                                  :values => [:reservation_limit, :reservation_time, :max_servers]
                              }]
    }
  end

  def index
    @servers = Server.where("name LIKE '%scrim%'").all
    @slots = ReservedSlot.where('start_at >= (?) AND end_at <= (?)', Date.today - 1.day, Date.today + 1.week)
    @slot = ReservedSlot.new
    maxTime = current_user.get_permission(:slots_controllers, :values, :reservation_time).to_i
    times = []
    start = 30
    100.times do |t|
      break if start > maxTime
      times << start
      start+=30
    end
    @times = {}
    times.each do |t|
      @times[Time.at(t*60).utc.strftime('%H:%M')] = t
    end
  end

  def server_count
    unless @possible.nil?
      @donate = @servers.size > 0 && @possible <= 0
    end
    render :layout => false
  end

  def view
    @reservation = ReservedSlot.find_by_id(params[:id])
  end

  def cancel
    res = ReservedSlot.find(params[:id])

    res.team.members.each do |member|
      Alert.dismiss(member.user, "Res:#{res.id}")
    end

    res.destroy
    flash[:notice] = 'You have cancelled your scrimmage server reservation.'
    redirect_to '/scrims'
  end

  def create
    if @fullWeek
      flash[:error] = 'You have reached your maximum allowance of reservations per week. Please wait to the start of next week or visit the shop to purchase a rank.'
      redirect_to :back
      return
    end

    if @possible.nil?
      flash[:error] = 'Please specify a valid start date.'
      redirect_to :back
      return
    end

    if @possible <= 0
      flash[:error] = 'There are no servers avalible for the specified time range.'
      redirect_to :back
      return
    end

    if current_user.team.members.size < 0
      flash[:error] = 'Your team must have at least 4 members to reserve a server.'
      redirect_to :back
      return
    end

    i = 0

    ReservedSlot.where(:team_id => current_user.team.id).each do |rs|
      if @date.to_i - rs.start_at.to_i < 12.hours
        i += 1
      end
    end

    if i >= 3444
      flash[:error] = 'Teams can only have three reservations every 12 hours.'
      redirect_to :back
      return
    end

    if Time.now.utc.to_i > @date.to_i
      flash[:error] = "#{Time.now.utc} #{@date.in_time_zone(Time.zone)} Reservations cannot be reserved for the past."
      redirect_to :back
      return
    end

    if @date > Time.now.utc + 7.days
      flash[:error] = 'You cannot reserve a server more than a week in advance.'
      redirect_to :back
      return
    end

    res = ReservedSlot.new
    res.start_at = @date
    res.end_at = @endDate
    res.team_id = current_user.team.id
    res.server = @servers[0]
    res.save!

    current_user.team.members.each do |member|
      Alert.alert(member.user, "Res:#{res.id}", 'Your team is scheduled for a scrimmage!', "/scrims/#{res.id}")
    end

    flash[:notice] = 'You have successfully reserved a scrimmage server!'
    redirect_to "/scrims/#{res.id}"
  end

  private

  def parse_dates
    unless params[:date].nil? || params[:length].nil?
      weekStart = Date.today - 1.day
      weekEnd = weekStart + 6.days
      reserved = ReservedSlot.where(reservee: current_user).where('start_at > (?) AND end_at < (?)', weekStart, weekEnd).size
      @fullWeek = current_user.get_permission(:slots_controllers, :values, :reservation_limit).to_i < reserved
      unless @fullWeek
        @servers = Server.where("name LIKE '%scrim%'").map(&:name)
        @max = current_user.get_permission(:slots_controllers, :values, :max_servers)
        @max = 0 if @max.nil?
        begin
          @date = DateTime.strptime(params[:date], '%m/%d/%Y %H:%M %Z').utc
        rescue
          # bad date
          return
        end
        @endDate = @date + params[:length].to_i.minutes

        ReservedSlot.where('(?) < end_at AND (?) > start_at', @date, @endDate).each do |s|
          break if @servers.size <= 0
          @servers.delete(s.server)
        end unless @servers.size <= 0

        @possible = [@servers.size, @max.to_i].min
      end
    end
  end

  def ensure_leader
    unless !current_user.team.nil? && current_user.team.get_role(current_user) == 'leader'
      flash[:error] = 'You must be a leader of a team to do thi.'
      redirect_to :back
      return
    end
  end

  def ensure_logged_in
    unless logged_in?
      flash[:error] = 'You must login to create server reservations.'
      redirect_to '/login'
    end
  end

end
