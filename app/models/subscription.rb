class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  validates_uniqueness_of :discussion, :scope => :user

end
