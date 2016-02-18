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
    spring = Term.create(name: "Spring", starts_on: 2015-01-15, ends_on: 2015-05-30)
    french = Course.create(name: "French", course_code: "FRE", color: "blue", period: "Third", description: "Learn French oui oui")
    spring.courses << french
    begin
      spring.destroy
    rescue
      puts "cannot delete term"
    end
      assert_equal [french], spring.courses
  end

  def test_courses_can_have_many_students
    c = Course.create(name: "Spanish", course_code: "SPA", color: "green", period: "Fourth", description: "Learn Spanish si si")
    s = CourseStudent.create(student_id: 244, final_grade: "F")
    c.course_students << s
    assert_equal [s], c.course_students
  end

  def test_courses_with_students_cannot_be_deleted
    output = ""
    spanish = Course.create(name: "Spanish", course_code: "SPA", color: "green", period: "Fourth", description: "Learn Spanish si si")
    new_student = CourseStudent.create(student_id: 244, final_grade: "F")
    spanish.course_students << new_student
    begin
      spanish.destroy
    rescue
      output = "cannot destroy course"
    end
    assert_equal "cannot destroy course", output
  end
end
