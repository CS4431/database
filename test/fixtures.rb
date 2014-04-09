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

# Fixtures to load into the test database during testing
module Fixtures
  # deletes all data in the database
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

  # loads the fixtures into the database
  def self.load
    delete_all

    # Departments
    comp = Department.create('id' => 1, 'name' => 'Computer Science',
                             'code' => 'COMP')
    math = Department.create('id' => 2, 'name' => 'Mathematics',
                             'code' => 'MATH')

    # Courses
    comp1411 = Course.create('id' => 1, 'title' => 'Computer Programming I',
                             'code' => 'COMP-1411', 'section' => 'FA',
                             'department_id' => comp.id,
                             'instructor' => 'Dr Jinan A. Fiaidhi',
                             'term' => '13F')
    math1171 = Course.create('id' => 2, 'title' => 'Calculus',
                             'code' => 'MATH-1171', 'section' => 'FA',
                             'department_id' => math.id,
                             'instructor' => 'Ms Elcim Elgun',
                             'term' => '13F')

    # Books
    c_program_group = EditionGroup.create('id' => 1,
                                          'title' => 'C How To Program')
    c_program = Edition.create('id' => 1, 'isbn' => '9780132990448',
                               'author' => 'Deitel, Paul',
                               'publisher' => 'Pearson Education',
                               'edition' => '7', 'cover' => 'paperback',
                               'edition_group_id' => c_program_group.id,
                               'image' => 'images/book/9780132990448.jpg')
    CourseBook.create('id' => 1, 'course_id' => comp1411.id,
                      'edition_id' => c_program.id)

    calculus_group = EditionGroup.create('id' => 2,
                                         'title' => 'Calculus: One And Several Variables')
    calculus = Edition.create('id' => 2,
                              'isbn' => '9780471698043',
                              'author' => 'Salas, Satunio',
                              'publisher' => 'Wiley',
                              'edition' => 10,
                              'edition_group_id' => calculus_group.id,
                              'image' => 'http://www.example.com/images/books/calculus.jpg')
    CourseBook.create('id' => 2, 'course_id' => math1171.id,
                      'edition_id' => calculus.id)

    calculus_solution_group = EditionGroup.create('id' => 3,
                                                  'title' => 'Calculus: One And Several Variables Ssm')
    calculus_solutions = Edition.create('id' => 3, 'isbn' => '040105534',
                                        'author' => 'Salas, Satunio',
                                        'publisher' => 'Wiley',
                                        'edition' => 10,
                                        'edition_group_id' => calculus_solution_group.id)
    CourseBook.create('id' => 3, 'course_id' => math1171.id,
                      'edition_id' => calculus_solutions.id)

    # Users
    pwd1 = '$2a$10$cM5Rrhwjvhd.XvTnLyYw6.5loWOc4Usm6sUjPZ3Js0fcrZOdeC5L2'
    user1 = User.create('id' => 1, 'email' => 'user1@lakeheadu.ca',
                        'password' => pwd1,
                        'verified' => true)
    pwd2 = '$2a$10$UJgoJv.8x0zvCqZEoIzJ3uqGTtqPWjKXtCoO85I2YKyoRugxikBtO'
    user2 = User.create('id' => 2, 'email' => 'user2@lakeheadu.ca',
                        'password' => pwd2,
                        'verified' => false)

    # Tokens
    Token.create('id' => 1, 'email' => user1.email,
                 'token' => 'abcd', 'start_date' => Time.now - 10,
                 'end_date' => Time.now + 1000)
    Token.create('id' => 2, 'email' => user2.email,
                 'token' => 'efgh', 'start_date' => Time.now - 100,
                 'end_date' => Time.now - 10)

    # Sells
    Sell.create('id' => 1, 'user_id' => user1.id,
                'edition_id' => c_program.id, 'price' => 60,
                'start_date' => Time.now,
                'end_date' => (Time.now + (30 * 86_400)))
    Sell.create('id' => 2, 'user_id' => user1.id,
                'edition_id' => c_program.id, 'price' => 60,
                'start_date' => Time.now,
                'end_date' => (Time.now + (30 * 86_400)))
    Sell.create('id' => 3, 'user_id' => user2.id,
                'edition_id' => c_program.id, 'price' => 70,
                'start_date' => Time.now,
                'end_date' => (Time.now + (30 * 86_400)))
    Sell.create('id' => 4, 'user_id' => user1.id,
                'edition_id' => calculus.id, 'price' => 80,
                'start_date' => Time.now,
                'end_date' => (Time.now + (30 * 86_400)))
    # Buys
  end
end
