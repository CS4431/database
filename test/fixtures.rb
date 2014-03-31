require 'date'
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
    math1171 = Course.create({'id' => 2, 'title' => 'Calculus',
                              'code' => 'MATH-1171', 'section' => 'FA',
                              'department_id' => math.id, 'instructor' => 'Ms Elcim Elgun',
                              'term' => '13F'})

    # Books
    cProgramGroup = EditionGroup.create({'id' => 1, 'title' => 'C How To Program'})
    cProgram = Edition.create({'id' => 1, 'isbn' => '9780132990448',
                               'author' => 'Deitel, Paul', 'publisher' => 'Pearson Education',
                               'edition' => '7', 'cover' => 'paperback',
                               'edition_group_id' => cProgramGroup.id})
    CourseBook.create({'id' => 1, 'course_id' => comp1411.id, 'edition_id' => cProgram.id})

    calculusGroup = EditionGroup.create({'id' => 2, 'title' => 'Calculus: One And Several Variables'})
    calculus = Edition.create({'id' => 2, 'isbn' => '9780471698043',
                               'author' => 'Salas, Satunio', 'publisher' => 'Wiley',
                               'edition' => 10, 'edition_group_id' => calculusGroup.id})
    CourseBook.create({'id' => 2, 'course_id' => math1171.id, 'edition_id' => calculus.id})

    # Users
    user1 = User.create({'id' => 1, 'email' => 'user1@lakeheadu.ca',
                         'password' => '$2a$10$yHMWvRkay6QdxA9WEv2y2u7L3/q8iPf8V.WA4UNTv4tnKF/RXs3ey',
                         'verified' => true})
    user2 = User.create({'id' => 2, 'email' => 'user2@lakeheadu.ca',
                         'password' => '$2a$10$UJgoJv.8x0zvCqZEoIzJ3uqGTtqPWjKXtCoO85I2YKyoRugxikBtO',
                         'verified' => false})

    # Sells
    Sell.create({'id' => 1, 'user_id' => user1.id,
                 'edition_id' => cProgram.id, 'price' => 60,
                 'start_date' => Time.now, 'end_date' => (Time.now + (30 * 86400))})
    Sell.create({'id' => 2, 'user_id' => user1.id,
                 'edition_id' => calculus.id, 'price' => 80,
                 'start_date' => Time.now, 'end_date' => (Time.now + (30 * 86400))})

    # Buys
  end
end
