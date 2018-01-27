require 'rufus-scheduler'

schedule = Rufus::Scheduler.singleton

puts 'Reservation Tasks Loaded'

# Task that starts/stops scrim servers based on reservations.
schedule.every('1m') do
  Server.where("name LIKE '%scrim%'").each do |server|
    action = ReservedSlot.where(server: server.name).where('start_at <= (?) && end_at >= (?)', Time.now, Time.now).empty? ? 'stop' : 'start'
    shouldAct = (action == 'start' && !server.online?) || action == 'stop'
    $redis.publish('server-actions', {server: server.name, action: action}.to_json) if shouldAct
  end
end
