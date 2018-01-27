class AnnounceUtils
  def self.send_message(content, type)
    $redis.publish('announce', {
        type: type.to_s.upcase,
        from_legacy: true,
        message: content
    }.to_json)
  end

  def join_server(server, text)
    $redis.publish('announce', {
        type: 'JOIN',
        server_id: server.id,
        from_legacy: true,
        message: text
    }.to_json)
  end
end