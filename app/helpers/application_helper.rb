module ApplicationHelper
  include Cachable
  User # keep this :)
  Rank
  UserDetail

  # Get a list of online users based on the time they last loaded a page.
  def online_users
    times = $avicus['online'] ? $avicus['online'] : {}
    times[current_user.id] = Time.now if logged_in?

    users = []
    times.each do |id, time|
      if Time.now - time > 5.minutes
        times.delete(id)
        next
      end
      users << User.select(:id, :uuid, :username).find_by_id(id)
    end
    users.sort_by! { |user| user.cached(:highest_priority_rank).priority }.reverse!

    $avicus['online'] = times

    users
  end

  # Convert a boolean to an icon.
  def boolean_to_symbol(val, hide_if_false = false)
    css = val ? 'fa-check-square-o' : 'fa-times'
    css = '' if !val && hide_if_false
    "<i class='#{css}'></i>".html_safe
  end

  # Get an avatar sized image for a user.
  def avatar_tag(user, size=32, **kwargs)
    image_tag(avatar_url(user, size), **kwargs)
  end

  # Get the link to a users avatar with an optional size.
  def avatar_url(user, size=32)
    if user.cached(:details).avatar == 'Gravatar' && user.cached(:details).email_status == 1
      md5 = Digest::MD5.hexdigest(user.cached(:details).email)
      URI.encode "https://www.gravatar.com/avatar/#{md5}?s=#{size}&default=mm"
    else
      "https://crafatar.com/avatars/#{user.uuid}?helm&size=#{size}"
    end
  end

  # Get an image with an href to a user.
  def link_avatar_to_user(user, size=32, **kwargs)
    link_to(user_path(user), :style => 'text-decoration: none') do
      avatar_tag(user, size, :class => 'img-rounded', **kwargs)
    end
  end

  # Get a link to a user profile with the correct link color.
  def link_to_user(user, **args, &block)
    color = nil
    user.cached(:ranks).sort_by { |rank| rank.cached(:priority) }.reverse.each do |rank|
      html = rank.cached(:html_color)
      if html.present? && html != 'none'
        color = html
        break
      end
    end
    style = color.present? ? "color: #{color}" : 'color: #038DD2'

    if block
      link_to(user_path(user), :style => style, **args, &block)
    else
      link_to(user.name, user_path(user), :style => style, **args, &block)
    end
  end

  # Convert a string to HTML safe string removing an content which could be used for malicious activities.
  def html_safe(input)
    if input != nil
      input = Sanitize.fragment(input,
                                :elements =>
                                    %w(table tr td th thead tbody div code blockquote span a button img table tr th td tbody thead h1 h2 h3 h4 h5 br hr p small bold strong em i b u center strike li ol ul),

                                :attributes => {
                                    :all =>
                                        %w(style src class rel alt title href)
                                },

                                :css => {
                                    :properties =>
                                        %w(width max-width min-width height max-height min-height text-align text-decoration border border-left border-right border-top border-bottom margin margin-left margin-right margin-top margin-bottom padding padding-left padding-right padding-top padding-bottom background background-image background-position background-attachment background-size background-repeat background-color display color font-weight font-family),
                                    :protocols => %w(http https //)
                                }
      )
    end

    input
  end

  # Convert a time to an _ago formatted human string.
  def time_ago(before)
    time_between(before, Time.now)
  end

  # Convert a duration between two times to a human friendly string.
  def time_between(before, after)
    return seconds_to_time(time_to_seconds(before, after))
  end

  # Convert a duration between two times to a clock format.
  def time_between_clock(before, after)
    time = (after- before).seconds
    Time.at(time).utc.strftime('%H:%M:%S')
  end

  # Convert a duration between two times to a number of seconds.
  def time_to_seconds(before, after)
    return 0 if before == nil || after == nil
    (after.to_datetime - before.to_datetime) * 24 * 60 * 60
  end

  # Get a human friendly string based on a time in the current timezone.
  def time_in_words(time, detail = false, twolines = false)
    if twolines
      return time.in_time_zone(Time.zone).strftime('%B %e, %Y') + '<br />' + time.in_time_zone(Time.zone).strftime('%l:%M %p')
    else
      return time.in_time_zone(Time.zone).strftime(detail ? '%B %e, %Y at %l:%M %p' : '%B %e, %Y')
    end
  end

  require 'action_view'
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  # Convert seconds to a # Days # Hours # Minutes # Seconds format
  def seconds_to_time(secs, precise = false)
    if secs == 0
      return '0 seconds'
    end
    if precise
      return [[60, :second], [60, :minute], [24, :hour], [1000, :day]].map { |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          if n.to_i != 0
            pluralize(n.to_i, name.to_s)
          end
        end
      }.compact.reverse.join(', ')
    end

    distance_of_time_in_words(Time.now - secs, Time.now)
  end

  # Determine a human-friendly version of a permission value for the dropdown menu.
  def determine_text(opt)
    case opt
      when :true
        return 'Yes'
      when :false
        return 'No'
      when :flow
        return 'Flow to Next'
      when :own
        return 'Own'
      else
        return opt.to_s.capitalize.gsub('_', ' ')
    end
  end

  # Convert a commit message to an HTML version with a link to the issue closed and removes the (#Pull-Request) from the end.
  def rich_commit(message)
    # Linkify Issues
    orgName = 'Avicus'
    if message.include?("#{orgName}/Issues#")
      issue = message.match(/#{orgName}\/Issues#(\S*)/)[1]
      message = message.gsub(/(#{orgName}\/Issues)([^\s]+)/, "<a href=\"https://github.com/#{orgName}/Issues/issues/#{issue}\">##{issue}</a>")
    end

    # Remove PR (#)
    message = message.gsub(/\(#([^)]+)\)/, '')

    message
  end

  # https://gist.github.com/mahemoff/4136057
  # Convert a string to a string that is suitable for a title.
  def titleize(str)
    str
        .gsub('_', ' ')
        .split(/\s+/).map { |word| word.slice(0, 1).capitalize + word.slice(1..-1) }.join(' ')
        .gsub(/(mc)/i, 'MC')
        .gsub(/(id)/i, 'ID')
  end

  # Get all fields the current user can edit from an object.
  def editable_fields(obj)
    return [] unless obj.class.respond_to?(:perm_fields)
    editable = []
    raise "Class '#{obj.to_s}' does not have perm_fields definition" if obj.class.perm_fields.nil?
    obj.class.perm_fields.each do |field|
      editable << field if obj.can_edit?(current_user, field)
    end
    editable
  end

  # Get a logo based on the current holiday (in the user's timezone)
  # The returned string is the file name of the logo in the asset folder.
  def holiday_logo
    day = Date.today.in_time_zone(Time.zone).day
    case Date.today.in_time_zone(Time.zone).month
      when 1
        return 'new-years' if day == 1
        return 'au' if day == 26
      when 4
        return 'green' if day == 22
      when 7
        return 'ca' if day == 1
        return 'us' if day == 4
      when 9
        return 'mx' if day == 16
      when 12
        return 'christmas' if day == 25
        return 'new-years' if day == Date.today.in_time_zone(Time.zone).end_of_month.day
    end

    return 'blue'
  end

  # Punish multiple users at once in the most efficient way.
  def punish_users(punisher, reason, type, expires, user_ids = [])
    inserts = []
    now = Time.now.to_s(:db)
    user_ids.each do |user|
      inserts.push "('#{now}', '#{reason}' #{punisher.nil? ? '' : ", '#{punisher}'"}, '#{type}', #{user} #{expires.nil? ? '' : ", '#{expires.to_s(:db)}'"})"
    end
    sql = "INSERT INTO `punishments` (`date`, `reason` #{punisher.nil? ? '' : ', `staff_id`'}, `type`, `user_id`#{expires.nil? ? '' : ', `expires`'}) VALUES #{inserts.join(', ')}"
    Punishment.connection.execute sql
  end
end
