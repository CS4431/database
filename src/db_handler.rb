require 'sqlite3'

module DBHandler
  # Gets book data for specified book id
  #
  # @param id [Integer] the book id to search for
  # @return [Hash] the book data; nil if no book found
  def DBHandler.get_book_by_id(id)
    db = SQLite3::Database.open("db/books.sqlite")
    column_names = ["id", "isbn", "book_id", "author", "edition", "publisher", "cover", "image", "title"]
    query = "SELECT edition.*, book.title FROM edition, book WHERE edition.id = #{id} AND book.id = edition.book_id"
    row = db.get_first_row(query)
    return nil if row == nil

    Hash[column_names.zip(row)]
  end

end
