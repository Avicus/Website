require 'rufus-scheduler'

schedule = Rufus::Scheduler.singleton

puts 'Tip Announcer'

TIPS = Announcement.where(tips: true).all
PREFIX_TEXTS = %w(Tip §kwoo News)

# Task that will send tips to in game users.
schedule.every('3m') do
  tip = TIPS.sample
  text = PREFIX_TEXTS.sample
  prefix = '§5[§6' + text + '§5] '
  message = tip.body.gsub('&', '§')
  AnnounceUtils.send_message(prefix + message, :no_prefix)
end