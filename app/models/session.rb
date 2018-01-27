class Session < ActiveRecord::Base
  belongs_to :user
  belongs_to :server

  include GraphQL::QLModel

  graphql_finders(:user_id, :ip, :server_id, :is_active, :graceful)

  graphql_type description: 'A span of time a user spent on a server.',
               fields: {
                   user_id: 'ID of the user that was on the server.',
                   duration: 'How long (in seconds) that the session lasted.',
                   ip: 'IP of the user during the session',
                   server_id: 'ID of the server that the session happened on.',
                   is_active: 'If the session is still ongoing.',
                   graceful: 'If the session ended without a crash.'
               }, create: true, update: true

  # Get the user-friendly version of the IP tied to this session with the last 2 sections obscured for security.
  def obscured_ip
    parts = ip.split("\.")
    parts = parts.first(parts.size - 2)
    parts.join('.') + '.xxx.xxx'
  end

  # Check if the session is currently active.
  def is_active?
    now = Time.now
    now > created_at && now < updated_at
  end
end
