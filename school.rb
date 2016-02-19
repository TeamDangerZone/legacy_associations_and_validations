class School < ActiveRecord::Base
  has_many :terms
  validates :name, presence: true
  has_many :courses, through: :terms
  default_scope { order('name') }
end
