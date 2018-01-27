require 'discordrb'

$bot = Discordrb::Commands::CommandBot.new token: $avicus['discord']['token'], client_id: 168123456789123456, prefix: '!'

$config = {}

def connect
  $bot.run(true)

  $config = {
      main_guild: $bot.servers[$avicus['discord']['main-guild'].to_i]
  }

  do_events
  # Loggers
  $bot.include! MessageLogger

  # Commands
  $bot.include! StaffCommand
end

def cleanup
  puts 'stopping'
  $bot.stop
  sleep(2)
  exit
end

def do_events
  $bot.message(with_text: 'Ping!') do |event|
    event.respond 'Ruby on raiiilllssss'
  end
end