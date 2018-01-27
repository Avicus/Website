require 'rufus-scheduler'

schedule = Rufus::Scheduler.singleton

unless defined?(Rails::Console) || Rails.env == 'development' || ENV['daemon']
  # Expired memberships
  schedule.every '3m' do
    expire = Membership.where('expires_at < ?', Time.now)
    if expire.count > 0
      log("Deleting expired memberships: #{expire.to_json}")
      expire.destroy_all
    end
  end

  # Reload Maps
  schedule.every '30m' do
    require 'xml/parsing_utils.rb'
    puts 'Parsing/Cacheing Maps...'
    puts $categorized_maps
    $maps = all_maps
    $categorized_maps = categorize_maps($maps.values)
  end

  # # Archive posts
  # schedule.every '3m' do
  #   archive = Post.discussions.where(:archived => false).where('last_reply_at < ?', Time.now - 1.month)
  #   if archive.count > 0
  #     log("Archiving old posts: #{archive.to_json}")
  #     archive.update_all(:archived => true)
  #   end
  # end
end

Avicus::Application.config.after_initialize do
  if Avicus::Application.for_users?
    require 'xml/parsing_utils.rb'
    puts 'Parsing/Cacheing Maps...'
    $maps = all_maps
    $categorized_maps = categorize_maps($maps.values)
  end
end