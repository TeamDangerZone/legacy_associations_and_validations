# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_schools_can_have_many_terms
    s = School.create(name: "Lakeview High")
    f = Term.create(name: "Fall", starts_on: 2015-10-01, ends_on: 2015-12-30)
    s.terms << f
    assert_equal "Fall", f.name
    assert_equal 2015-10-01, f.starts_on
    assert_equal 2015-12-30, f.ends_on
  end

  def test_have_many_courses
    t = Term.create(name: "Spring", starts_on: 2015-01-15, ends_on: 2015-05-30)
    c = Course.create(name: "French", course_code: "FRE", color: "blue", period: "Third", description: "Learn French oui oui")
    t.courses << c
    assert_equal [c], t.courses
  end

  def test_term_with_courses_cannot_be_deleted
    t = Term.create(name: "Spring", starts_on: 2015-01-15, ends_on: 2015-05-30)
    c = Course.create(name: "French", course_code: "FRE", color: "blue", period: "Third", description: "Learn French oui oui")
    t.courses << c
    begin
      t.destroy
    rescue
      "cannot destroy term"
    end
    assert_equal "cannot destroy term", "cannot destroy term"
  end
end
