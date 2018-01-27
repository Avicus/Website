# Logs message updates to a history channel.
module MessageLogger
  extend Discordrb::EventContainer

  @where = $config[:main_guild].channels.select { |chan| chan.id == $avicus['discord']['channels']['history'].to_i }[0]

  message_cache = {}

  def self.message_to_text(msg)
    msg.user.name + ' in #' + msg.channel.name + ': ' + msg.content
  end

  message do |event|
    message_cache[event.message.id] = message_to_text event.message
  end

  message_edit do |event|
    old = message_cache[event.message.id]
    next if old.nil?
    DiscordUtils.send_rich_message @where, 'Message Update', old + ' >> ' + event.message.content, 239925
    message_cache[event.message.id] = message_to_text event.message
  end

  message_delete do |event|
    old = message_cache[event.id]
    next if old.nil?
    DiscordUtils.send_rich_message @where, 'Message Delete', old, 'a30e0e'
    message_cache[event.id] = nil
  end

end