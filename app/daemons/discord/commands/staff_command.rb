module StaffCommand
  extend Discordrb::Commands::CommandContainer

  command :staff, description: 'List the online staff' do |event|
    to_ping = []
    event.server.roles.each do |r|
      next unless r.name.include? 'Mod'
      r.members.each do |u|
        to_ping << u if u.status == :online
      end
    end
    message = 'Online Staff: '
    to_ping.each do |p|
      message = message + "#{p.mention} "
    end
    message
  end
end