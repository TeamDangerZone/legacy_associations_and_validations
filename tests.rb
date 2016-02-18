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

  def test_lessons_can_have_many_readings
    l = Lesson.create(name: "English", description: "How to English", outline: "Will show how to English", lead_in_question: "Do you know how to English?")
    r = Reading.create(caption: "When to use the Oxford Comma", url: "www.oxfordcomma.org")
    l.readings << r
    assert_equal [r], l.readings
  end

end
