class Log < ActiveRecord::Base
  belongs_to :user

  def is_command?
    command == 1
  end

  def user_link
    if user == nil
      return 'Console'
    end
    ActionController::Base.helpers.link_to user.username, user.path
  end
end
