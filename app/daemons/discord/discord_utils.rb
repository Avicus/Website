class DiscordUtils
  def self.send_rich_message(where, title, message, color)
    where.send_embed do |embed|
      embed.title = title
      embed.description = message
      embed.color = color
    end
  end
end