require 'sqlite3'
require 'sinatra/activerecord'
require_relative '../src/buy'
require_relative '../src/contact'
require_relative '../src/course'
require_relative '../src/course_book'
require_relative '../src/department'
require_relative '../src/edition'
require_relative '../src/edition_group'
require_relative '../src/sell'
require_relative '../src/user'
require_relative '../src/verification'
require_relative '../src/token'

module Fixtures

  def self.delete_all
    Buy.delete_all
    Contact.delete_all
    Course.delete_all
    CourseBook.delete_all
    Department.delete_all
    Edition.delete_all
    EditionGroup.delete_all
    Sell.delete_all
    User.delete_all
    Verification.delete_all
    Token.delete_all
  end

  def self.load
    self.delete_all

    # Departments
    comp = Department.create({'id' => 1, 'name' => 'Computer Science', 'code' => 'COMP'})
    math = Department.create({'id' => 2, 'name' => 'Mathematics', 'code' => 'MATH'})

    # Courses
    comp1411 = Course.create({'id' => 1, 'title' => 'Computer Programming I',
                              'code' => 'COMP-1411', 'section' => 'FA',
                              'department_id' => comp.id, 'instructor' => 'Dr Jinan A. Fiaidhi',
                              'term' => '13F'})

    # Books
    cProgramGroup = EditionGroup.create({'id' => 1, 'title' => 'C How To Program'})
    cProgram = Edition.create({'id' => 1, 'isbn' => '9780132990448',
                               'author' => 'Deitel, Paul', 'publisher' => 'Pearson Education',
                               'edition' => '7', 'cover' => 'paperback',
                               'edition_group_id' => 1})
    CourseBook.create({'id' => 1, 'course_id' => comp1411.id, 'edition_id' => cProgram.id})

    # Users

    # Sells

    # Buys
  end
end
