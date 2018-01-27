class Admin::StatsController < Admin::IndexController
  before_action :perms_check

  def self.permission_definition
    {
        :global_options => {
            :text => 'Admin Panel - Stats',
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :actions => {
                                      :view => [:weekday, :credits, :versions, :punishments, :appeals, :appeal_resolutions]
                                  }
                              }]
    }
  end

  def main
    @panels = [:weekday, :credits, :versions, :punishments, :appeals, :appeal_resolutions]
    @panels.delete_if { |c| !current_user.has_permission?('admin:stats_controllers', :view, c, true) }
  end

  def weekday
    @weekday = []

    @name = 'User Logins'

    intervals = [['Week', 1.week], ['Last Week', 2.weeks, 1.week], ['Last Month', 2.months, 1.month], ['Last 5 Months', 5.months, 2.months]]
    intervals.each do |i|
      counts = Session.where('created_at > ?', Time.now - i[1]).select('dayname(created_at) as day1, hour(created_at) as hour1')
      if i[2]
        counts = counts.where('created_at < ?', Time.now - i[2])
      end
      counts = counts.group_by { |s| [DateTime.parse(s.day1) + s.hour1] }.map { |k, v| [k.first, v.length] }
      counts.sort_by { |count| count[0] }
      @weekday += [{:name => i[0], :data => counts}]
    end

    @charts = [{
                   :type => :line,
                   :ref => @weekday,
                   :height => '500px',
                   :library => {:dateFormat => '%A', :tooltip => {:valueSuffix => ' players'}, :dateTimeLabelFormats => '%A %H:00'}
               }]
    render 'chart', :layout => false
  end

  def credits
    @credits = Credit.group_by_week(:created_at).sum(:amount)

    @name = 'Credits Earned'

    @charts = [{
                   :type => :line,
                   :ref => @credits,
                   :height => '500px'
               }]
    render 'chart', :layout => false
  end

  def versions
    @versions = Hash.new

    @versions_logged = 0
    User.where('mc_version IS NOT NULL').each do |user|
      if @versions.include?(user.mc_version)
        @versions[user.mc_version] += 1
      else
        @versions[user.mc_version] = 1
      end
      @versions_logged += 1
    end
    @versions['1.12'] = @versions.delete 335 if @versions.include?(335)
    @versions['1.11.1 - 1.11.2'] = @versions.delete 316 if @versions.include?(316)
    @versions['1.11'] = @versions.delete 315 if @versions.include?(315)
    @versions['1.10 - 1.10.2'] = @versions.delete 210 if @versions.include?(210)
    @versions['1.9.3 - 1.9.4'] = @versions.delete 110 if @versions.include?(110)
    @versions['1.9.2'] = @versions.delete 109 if @versions.include?(109)
    @versions['1.9.1'] = @versions.delete 108 if @versions.include?(108)
    @versions['1.9'] = @versions.delete 107 if @versions.include?(107)
    @versions['1.8'] = @versions.delete 47 if @versions.include?(47)
    @versions['1.7.6 - 1.7.10'] = @versions.delete 5 if @versions.include?(5)
    @versions['1.7.2 - 1.7.5'] = @versions.delete 4 if @versions.include?(4)

    render :layout => false
  end

  def punishments
    @punishments = {}
    @punishments_by_type = Punishment.group(:type).size
    Punishment.where('user_id != 0').group(:staff_id).size.each do |k, v|
      u = User.find_by_id(k)
      @punishments[u.username] = v unless u.nil?
      @punishments['Console'] = v if u.nil?
    end

    @punishments = @punishments.sort { |a, b| b[1] <=> a[1] }
    @punishments_by_type = @punishments_by_type.sort { |a, b| b[1] <=> a[1] }

    render :layout => false
  end

  def appeals
    @appeals_by_staff = {}
    @appeals_by_type = {}
    @open = 0
    @escalated = 0

    Appeal.all.each do |appeal|
      @open += 1 if appeal.status == 'Open'
      @escalated += 1 if appeal.status == 'Escalated'

      @appeals_by_type[appeal.punishment.type.to_sym] = 0 if @appeals_by_type[appeal.punishment.type.to_sym].nil?
      @appeals_by_type[appeal.punishment.type.to_sym] += 1

      @appeals_by_staff[appeal.punishment.staff.username] = 0 if @appeals_by_type[appeal.punishment.staff.username].nil?
      @appeals_by_staff[appeal.punishment.staff.username] += 1 unless appeal.punishment.staff.nil?

      @appeals_by_staff['Console'] = 0 if @appeals_by_staff['Console'].nil?
      @appeals_by_staff['Console'] += 1 if appeal.punishment.staff.nil?
    end

    @appeals_by_type = @appeals_by_type.sort { |a, b| b[1] <=> a[1] }

    render :layout => false
  end

  def appeal_resolutions
    @appeals_by_status = {}

    @appeals_denied_by_staff = {}
    @appeals_accepted_by_staff = {}

    Appeal.all.each do |appeal|
      next if appeal.actions.where(action: :close).last.nil? || appeal.actions.where(action: :close).last.user.nil?
      @appeals_by_status[appeal.status] = 0 if @appeals_by_status[appeal.status].nil?
      @appeals_by_status[appeal.status] += 1

      if appeal.status == 'Closed'
        @appeals_denied_by_staff[appeal.actions.where(action: :close).last.user.username] = 0 if @appeals_denied_by_staff[appeal.actions.where(action: :close).last.user.username].nil?
        @appeals_denied_by_staff[appeal.actions.where(action: :close).last.user.username] += 1 unless appeal.actions.where(action: :close).last.user.nil?
      end

      if appeal.status == 'Appealed'
        @appeals_accepted_by_staff[appeal.actions.where(action: :close).last.user.username] = 0 if @appeals_accepted_by_staff[appeal.actions.where(action: :close).last.user.username].nil?
        @appeals_accepted_by_staff[appeal.actions.where(action: :close).last.user.username] += 1 unless appeal.actions.where(action: :close).last.user.nil?
      end
    end

    @appeals_denied_by_staff = @appeals_denied_by_staff.sort { |a, b| b[1] <=> a[1] }
    @appeals_accepted_by_staff = @appeals_accepted_by_staff.sort { |a, b| b[1] <=> a[1] }

    render :layout => false
  end

  private

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :stats, true), '/', :page)
  end

end
