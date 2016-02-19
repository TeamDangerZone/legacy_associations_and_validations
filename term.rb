class Term < ActiveRecord::Base
  belongs_to :schools
  has_many :courses, dependent: :restrict_with_exception
  # validates :course_code, :uniqueness => {:scope => :term_id}
  # validates_uniqueness_of :course_code, :scope => [:term_id]
  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  def school_name
    school ? school.name : "None"
  end
end
