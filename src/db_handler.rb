require 'sqlite3'
require 'active_record'
require './book'
require './buy'
require './contact'
require './course'
require './course_book'
require './department'
require './edition'
require './user'

module DBHandler
  
  # Establishes a connection with the database
  def DBHandler.establish_connection
   ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/books.sqlite')
  end

  # Gets book data for specified book id
  #
  # @param id [Integer] the book id to search for
  # @return [Hash] the book data; nil if no book found
  def DBHandler.get_book_by_id(id)
    edition = Edition.find_by(id: id)
    return nil if edition == nil
    book = Book.find_by(id: edition.book_id)
    hash = edition.to_hash
    hash["title"] = book.title
    hash
  end
  
  # Gets the department data for specified id
  #
  # @param id [Integer] the department id to search for
  # @return [Hash] the department data; nil if no department found
  def DBHandler.get_department_by_id(id)
    department = Department.find_by(id: id)
    return nil if department == nil
    department.to_hash
  end

  # Gets the course data for specified id
  #
  # @param id [Integer] the course id to search for
  # @return [Hash] the course data; nil if no department found
  def DBHandler.get_course_by_id(id)
    course = Course.find_by(id: id)
    return nil if course == nil
    course.to_hash
  end

end
