require 'rufus-scheduler'

schedule = Rufus::Scheduler.singleton

puts 'Twitch Status Updater Loaded'

def check_status
  return if $avicus['twitch'].nil?
  client_id = $avicus['twitch']['client-id']
  t = Twitch.new(client_id: client_id)
  online = false
  onlineIds = []
  Livestream.all.each do |stream|
    begin
      isOnline = !t.stream(stream.channel)[:body]['stream'].nil?
      if isOnline && t.stream(stream.channel)[:body]['stream']['game'] == 'Minecraft'
        online = true
        onlineIds << stream.id
      end
    rescue
      puts 'Failed to get status for ' + stream.channel
    end
  end

  set_cache 'twitch.online', online, 10.minutes
  set_cache 'twitch.online-ids', onlineIds, 10.minutes
end

# Schedule that updates the application-wide live status based on if any of the streams are currently live.
schedule.every('2m') do
  check_status
end

schedule.every('8m') do
  if get_cache 'twitch.online'
    first = '§cWe have a streamer §l§cLIVE §con Twitch!'
    link = '§b Check it out at §6§nhttps://#{ORG::DOMAIN}/live'
    AnnounceUtils.send_message(first + link, :message)
  end
end

Avicus::Application.config.after_initialize do
  check_status
end
