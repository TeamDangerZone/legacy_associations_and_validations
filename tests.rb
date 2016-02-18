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
    l = Lesson.create(name: "The Oxford Comma", description: "Discussion of the Oxford Comma", outline: "Will debate use of the Oxford Comma", lead_in_question: "Do you always use an Oxford Comma")
    r = Reading.create(caption: "History of the Oxford Comma", url: "www.oxfordcomma.org")
    l.readings << r
    assert_equal [r], l.readings
  end

  def test_readings_are_automatically_destroyed_when_lessons_are_destroyed
    m = Lesson.create(name: "Math", description: "How to add", outline: "How to add", lead_in_question: "Do you know how to add?")
    q = Reading.create(caption: "Math", url: "www.math.org")
    m.readings << q
    m.destroy
    assert_equal [], m.readings
  end

  def test_courses_can_have_many_lessons
    e = Course.create(name: "English", course_code: "ENG", color: "red", period: "First", description: "How to English")
    l = Lesson.create(name: "The Oxford Comma", description: "Discussion of the Oxford Comma", outline: "Will debate use of the Oxford Comma", lead_in_question: "Do you always use an Oxford Comma")
    e.lessons << l
    assert_equal [l], e.lessons
  end

  def test_lessons_are_automatically_destroyed_when_course_is_destroyed
    e = Course.create(name: "English", course_code: "ENG", color: "red", period: "First", description: "How to English")
    l = Lesson.create(name: "The Oxford Comma", description: "Discussion of the Oxford Comma", outline: "Will debate use of the Oxford Comma", lead_in_question: "Do you always use an Oxford Comma")
    e.lessons << l
    e.destroy
    assert_equal [], e.lessons
  end


end
