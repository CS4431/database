require 'sqlite3'
require 'active_record'
require_relative './book'
require_relative './buy'
require_relative './contact'
require_relative './course'
require_relative './course_book'
require_relative './department'
require_relative './edition'
require_relative './user'
require_relative './verification'

# Handles all database connections
module DBHandler
  
  # Establishes a connection with the database
  def DBHandler.establish_connection
   ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/books.sqlite')
  end

  # Gets book data as a hash
  #
  # @param hash [Hash] the book data to search for
  # @return [Hash] the book data; empty hash if no book found
  def DBHandler.get_book(hash = {})
    edition = Edition.find_by(hash)
    {} if edition.nil?
    book = Book.find_by(id: edition.book_id)
    hash = edition.to_hash
    hash["title"] = book.title
    hash
  end
  
  # Gets department data as a hash
  #
  # @param hash [Hash] the department data to search for
  # @return [Hash] the department data; empty hash if no department found
  def DBHandler.get_department(hash = {})
    department = Department.find_by(hash)
    {} if course.nil?
    department.to_hash
  end

  # Create a department
  #
  # @param hash [Hash] the department data to add to database
  # @return [Hash] the department data added;
  def DBHandler.create_department(hash = {})
    department = Department.create(hash)
    department.to_hash
  end

  # Gets course data as a hash
  #
  # @param hash [Hash] the course data to search for
  # @return [Hash] the course data; empty hash if no department found
  def DBHandler.get_course(hash = {})
    course = Course.find_by(hash)
    {} if course.nil?
    course.to_hash
  end

  # Gets sell data as a hash
  #
  # @param hash [Hash] the sell data to search for
  # @return [Hash] the sell data; empty hash if no sell found
  def DBHandler.get_sell(hash = {})
    sell = Sell.find_by(hash)
    {} if sell.nil?
    sell.to_hash
  end
  
  # Creates a user and salts and hashes the password
  #
  # @param email [String] the user's email
  # @param password [String] the user's plaintext password
  # @return [Integer] the created user's account id
  def DBHandler.create_user(email, password)
    user = User.new
    user.email = email
    user.pass = password
    user.save
    
    verification = Verification.new
    verification.code = Verification.generate_code
    verification.user_id = user.id
    verification.save

    MailHandler.send_verification(user.email, verification.code)

    return user.id
  end

  # Creates a sell request record in the database
  #
  # @param hash [Hash] the sell data to add to the database
  # @return [Hash] the sell data added
  def DBHandler.create_sell(hash)
    sell = Sell.create(hash)
    return sell.to_hash
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
    return false if user.nil?
    user.login(password)
  end
end
