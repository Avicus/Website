class ExperienceLeaderboardEntry < ActiveRecord::Base
  belongs_to :user
  attr_accessor :rank
end
