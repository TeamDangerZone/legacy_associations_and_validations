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
    f = Term.create(name: "Fall", starts_on: 2015-10-01, ends_on: 2015-12-30, school_id: 4)
    s.terms << f
    assert_equal "Fall", f.name
    assert_equal 2015-10-01, f.starts_on
    assert_equal 2015-12-30, f.ends_on
  end

  def test_lessons_can_have_many_readings
    l = Lesson.create(name: "The Oxford Comma", description: "Discussion of the Oxford Comma", outline: "Will debate use of the Oxford Comma", lead_in_question: "Do you always use an Oxford Comma?")
    r = Reading.create(caption: "History of the Oxford Comma", url: "www.oxfordcomma.org")
    l.readings << r
    assert_equal [r], l.readings
  end

  def test_readings_are_automatically_destroyed_when_lessons_are_destroyed
    m = Lesson.create(name: "The Mystery of 'subtraction'", description: "How to subtract", outline: "A peek at the nuances of 'subtraction'", lead_in_question: "How has subtraction impacted your life?")
    q = Reading.create(caption: "2 - 3 = negative fun", url: "www.math.org")
    m.readings << q
    m.destroy
    m.save
    assert q.destroyed?
  end

  def test_term_can_have_many_courses
    t = Term.create(name: "Spring", starts_on: 2015-01-15, ends_on: 2015-05-30, school_id: 4)
    c = Course.create(name: "French", course_code: "FRE", color: "blue", period: "Third", description: "Learn French oui oui")
    t.courses << c
    assert_equal [c], t.courses
  end

  def test_term_with_courses_cannot_be_deleted
    spring = Term.create(name: "Spring", starts_on: 2015-01-15, ends_on: 2015-05-30, school_id: 4)
    french = Course.create(name: "French", course_code: "FRE", color: "blue", period: "Third", description: "Learn French oui oui")
    spring.courses << french
    begin
      spring.destroy
    rescue
    end
      assert_equal [french], spring.reload.courses
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
    e.save
    assert l.destroyed?
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
    spanish.reload
    assert_equal "cannot destroy course", output
  end

  def test_courses_can_have_many_instructors
    e = Course.create(name: "English", course_code: "ENG", color: "red", period: "First", description: "How to English")
    dan = CourseInstructor.create(instructor_id: 1)
    molly = CourseInstructor.create(instructor_id: 2)
    e.course_instructors << dan
    e.course_instructors << molly
    assert_equal [dan, molly], e.course_instructors
  end

  def test_courses_with_instructors_cannot_be_deleted
    physics = Course.create(name: "Physics", course_code: "PHY", color: "green", period: "Fourth", description: "Why things do what they do")
    dave = CourseInstructor.create(instructor_id: 3)
    mary = CourseInstructor.create(instructor_id: 4)
    physics.course_instructors << dave
    physics.course_instructors << mary
    begin physics.destroy; rescue; end
    assert_equal [dave, mary], physics.reload.course_instructors
  end

  def test_courses_can_have_many_assignments
    c = Course.create(name: "Spanish", course_code: "SPA", color: "green", period: "Fourth", description: "Learn Spanish si si")
    a = Assignment.create(name: "Habloing Espanol")
    c.assignments << a
    c.save
    assert_equal [a], c.assignments
  end

  def test_assignments_are_automatically_destroyed_when_course_is_destroyed
    c = Course.create(name: "Spanish", course_code: "SPA", color: "green", period: "Fourth", description: "Learn Spanish si si")
    a = Assignment.create(name: "Habloing Espanol", course_id: 4, percent_of_grade: 0.10)
    c.assignments << a
    c.destroy
    c.save
    assert a.destroyed?
  end

  def test_in_class_assignments_can_have_many_lessons
    l = Lesson.create(name: "The Oxford Comma", description: "Discussion of the Oxford Comma", outline: "Will debate use of the Oxford Comma", lead_in_question: "Do you always use an Oxford Comma")
    b = Assignment.create(name: "Oxford Comma Practice")
    b.lessons << l
    assert_equal [l], b.lessons
  end

  def test_courses_can_have_many_readings_through_lessons
    e = Course.create(name: "English", course_code: "ENG", color: "red", period: "First", description: "How to English")
    l = Lesson.create(name: "The Oxford Comma", description: "Discussion of the Oxford Comma", outline: "Will debate use of the Oxford Comma", lead_in_question: "Do you always use an Oxford Comma")
    r = Reading.create(caption: "History of the Oxford Comma", url: "www.oxfordcomma.org")
    l.readings << r
    e.lessons << l
    p e.readings
    assert_equal [r], e.readings
  end

  def test_schools_must_have_names
    assert_raises do s = School.create!end
  end

  def test_terms_must_have_name_starts_on_ends_on_and_school_id
    assert_raises do t = Term.create!end
  end

  def test_user_must_have_first_name_last_name_email
    assert_raises do u = User.create!end
  end

  def test_user_emails_must_be_unique
    dan = User.create(first_name: "Dan", last_name: "B", email: "d@gmail.com")
    assert_raises do dave = User.create!(first_name: "Dave", last_name: "C", email: "d@gmail.com")end
  end

  def test_assignments_must_have_course_id_name_percent_of_grade
    assert_raises do a = Assignment.create!end
  end

  def test_user_email_has_proper_format
    assert_raises do dan = User.create!(first_name: "Dan", last_name: "B", email: "my email")end
    assert dan = User.create(first_name: "Dan", last_name: "B", email: "d@gmail.com")
  end

  def test_user_photo_url_has_proper_format
    assert_raises do dan = User.create!(first_name: "Dan", last_name: "B", email: "my email", photo_url: "htps://photo")end
    assert User.create(first_name: "Dan", last_name: "B", email: "my email", photo_url:"http://photo.com")
    assert User.create(first_name: "Dan", last_name: "B", email: "my email", photo_url: "https://photo.com")
  end

  def test_assignments_must_have_unique_names_in_course
    e = Course.create(name: "English", course_code: "ENG", color: "red", period: "First", description: "How to English")
    b = Assignment.create(name: "Oxford Comma Practice", percent_of_grade: 0.10)
    c = Assignment.create(name: "Oxford Comma Practice", percent_of_grade: 0.10)
    e.assignments << b
    e.assignments << c
    assert b.valid?
    refute c.valid?
  end

end
