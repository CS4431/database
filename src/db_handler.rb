require 'sqlite3'
require 'sinatra/activerecord'
require_relative './buy'
require_relative './contact'
require_relative './course'
require_relative './course_book'
require_relative './department'
require_relative './edition'
require_relative './edition_group'
require_relative './sell'
require_relative './user'
require_relative './verification'

# Handles all database connections
module DBHandler
  
  # Establish a connection to the database. Used to connect to the database when the server is not running (ie. using irb)
  def DBHandler.establish_connection
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                            database: 'db/books.sqlite')
  end

  # Gets multiple books as a hash
  #
  # @param hash [Hash] the book data to search for
  # @param count [Integer] how many books to return
  # @param offset [Integer] how many books to offset the search results by
  # @return [Array of Hashes] the book data, empty hash if no books found
  def DBHandler.get_books(hash = {}, count, offset)
    # change title parameter to book.title
    hash["edition_group.title"] = hash.delete("title") if hash.has_key?("title")

    editions = Edition.select('edition.*, 
                              edition_group.title,
                              count(sell.id)/2 AS "for_sale",
                              Group_Concat(DISTINCT course.code||"-"||course.section) AS "course_code"').
      joins(:edition_group).
      joins('LEFT OUTER JOIN sell ON sell.edition_id = edition.id').
      references(:edition, :edition_group, :sell).
      group("edition.id").
      joins('INNER JOIN course_book ON course_book.edition_id = edition.id').
      joins('INNER JOIN course ON course_book.course_id = course.id').
      where(hash).
      limit(count).
      offset(offset)

    {} if editions.nil?
    editions_array = editions.to_a.map(&:serializable_hash)
    # count the number of each edition that is for sale
    editions_array.each do |edition|
      for_sale = Sell.select('count(*) AS "for_sale"').
        where({"edition_id" => edition["id"]}).
        count
      edition["for_sale"] = for_sale
    end

    editions_array
  end

  # Creates a book and edition
  #
  # @param hash [Hash] the book data to add
  # @return [Hash] the edition added to database
  def DBHandler.create_book(hash = {})
    edition_group = EditionGroup.find_by({"title" => hash["title"]})
    edition_group = EditionGroup.create({"title" => hash["title"]}) if edition_group.nil?
    hash.delete("title")
    hash["edition_group_id"] = edition_group["id"]
    edition = Edition.where({"isbn" => hash["isbn"]})
    return edition[0] unless edition.empty?
    edition = Edition.create(hash)[0]
  end

  # Updates a value in the edition table
  #
  # @param id [Integer] the id of the edition
  # @param attribute [String] the attribute to update
  # @param value [String] the new value
  def DBHandler.update_edition_attribute(id, attribute, value)
    Edition.update(id, attribute => value)
  end

  # Creates an association betwwen a book and a course
  #
  # @param hash [Hash] the association data
  # @return [Hash] the added data
  def DBHandler.create_course_book(hash = {})
    course_book = CourseBook.find_by(hash)
    return course_book unless course_book.nil?
    course_book = CourseBook.create(hash)
    course_book.to_hash
  end

  # Gets multiple department data as an array of hashes
  #
  # @param hash [Hash] the department data to search for
  # @param count [Integer] how many departments to return
  # @param offset [Integer] how many departments to offset the search result by
  # @return [Array of Hashes] the department data, empty hash if no departments found
  def DBHandler.get_departments(hash = {}, count, offset)
    departments = Department.where(hash).limit(count).offset(offset)
    return {} if departments.nil?
    departments_array = departments.to_a.map(&:serializable_hash)
  end

  # Create a department unless department already exists.
  #
  # @param hash [Hash] the department data to add to database. If department already exists return existing data.
  # @return [Hash] the department data added;
  def DBHandler.create_department(hash = {})
    department = Department.find_by(hash)
    return department.to_hash unless department.nil?
    department = Department.create(hash)
    department.to_hash
  end

  # Gets multiple course data as an array of hashes
  #
  # @param hash [Hash] the course data to search for
  # @param count [Integer] how many courses to return
  # @param offset [Integer] how many course to offset the search results by
  # @return [Array of Hashes] the course data; empty hash if no courses found
  def DBHandler.get_courses(hash = {}, count, offset)
    courses = Course.select('course.*,
                            department.name AS "department_name"').
      joins('INNER JOIN department ON course.department_id = department.id').
      where(hash).
      limit(count).
      offset(offset).
      references(:course, :department)
    return {} if courses.nil?
    courses_array = courses.to_a.map(&:serializable_hash)
  end

  # Creats a course unless course already exists
  #
  # @param hash [Hash] the course data to add to database
  # @return [Hash] the course data added
  def DBHandler.create_course(hash = {})
    course = Course.find_by(hash)
    return course.to_hash unless course.nil?
    course = Course.create(hash)
    course.to_hash
  end

  # Get multiple sell datas as an array of hashes
  #
  # @param hash [Hash] the sell data to search for
  # @param count [Integer] how many sells to return
  # @param offset [Integer] how many sells to offset the search results by
  # @return [Array of Hashes] the sell data, empty hash if no sells found
  def DBHandler.get_sells(hash = {}, count, offset)
    sells = Sell.where(hash).limit(count).offset(offset)
    return {} if sells.nil?
    sells_array = sells.to_a.map(&:serializable_hash)
  end
  
  # Creates a user and salts and hashes the password
  #
  # @param email [String] the user's email
  # @param password [String] the user's plaintext password
  # @return [Integer] the created user's account id
  def DBHandler.create_user(hash)
    user = User.new
    user.email = hash["email"]
    user.pass = hash["password"]
    user.verified = false
    user.save
    
    #verification = Verification.generate_code(user.id)
    #MailHandler.send_verification(user.email, verification.code)

    # Why does users get passed backs as an array???? -David
    users_array = [user.to_hash]
  end

  # Creates a sell request record in the database
  #
  # @param hash [Hash] the sell data to add to the database
  # @return [Hash] the sell data added
  def DBHandler.create_sell(hash)
    sell = Sell.new_with_dates(hash)
    return DBHandler.get_sells({"id" => sell.id}, 1, 0)
  end

  # Verifies a user account
  #
  # @param code [String] verification code
  # @return [Bool] true if verification successful
  def DBHandler.verify_user(code)
    verification = Verification.find_by(code: code)
    return false if verification.nil?
    user = User.find_by(id: verification.user_id)
    user.verified = true
    user.save
    verification.destroy
    return true
  end

  # Checks if user login information is correct
  #
  # @param email [String] user's email
  # @param password [String] password user is attempting to login with
  # @return [Bool] true if login information is correct; false otherwise
  def DBHandler.login(email, password)
    user = User.find_by(email: email)
    nil if user.nil?
    user.login(password)
  end

  # Get a count of the number of books, buys, courses, departments and sells
  # 
  # @return [Array of Hashes] the number of items in each table
  def DBHandler.get_counts
    data_array = [{"book" => Edition.count,
                   "buy" => Buy.count,
                   "course" => Course.count,
                   "department" => Department.count,
                   "sell" => Sell.count}]
  end
end
