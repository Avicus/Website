module StatsHelper
  # Get the ranking of the current item in a paginated collection.
  def get_ranking(collection, current)
    ((collection.current_page - 1) * collection.per_page) + (collection.index(current)) + 1
  end

  # Get an array of periods that stats can be filtered by.
  def options_for_period(selected)
    options = [[period_to_name(0), 'weekly'], [period_to_name(1), 'monthly'], [period_to_name(2), 'overall']]
    options_for_select(options, selected)
  end

  # Get an array of fields which PVP stats can be sorted by.
  def options_for_sort(selected)
    options = [%w(Kills kills), %w(Deaths deaths), %w(K/D kd_ratio), %w(Monuments monuments), %w(Wools wools), ['Time Online', 'time_online']]
    options_for_select(options, selected)
  end

  # Get an array of fields which XP stats can be sorted by.
  def options_for_xp_sort(selected)
    options = [
        ['Level', 'level'],
        ['Prestige Level', 'prestige_level'],
        ['Total XP', 'xp_total'],
        ['Nebula XP', 'xp_nebula'],
        ['KOTH XP', 'xp_koth'],
        ['CTF XP', 'xp_ctf'],
        ['TDM XP', 'xp_tdm'],
        ['Elimination XP', 'xp_elimination'],
        ['SkyWars XP', 'xp_sw'],
        ['Walls XP', 'xp_walls'],
        ['Arcade XP', 'xp_arcade']
    ]
    options_for_select(options, selected)
  end

  # Convert a stats period to a human friendly string.
  def period_to_name(period)
    case period
      when 0
        'Weekly'
      when 1
        'Monthly'
      when 2
        'Overall'
    end
  end
end
