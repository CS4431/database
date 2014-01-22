require 'sqlite3'

module DBHandler
  # Gets book data for specified book id
  #
  # @param id [Integer] the book id to search for
  # @return [Hash] the book data; nil if no book found
  def DBHandler.get_book_by_id(id)
    db = SQLite3::Database.open("db/books.sqlite")
    query = "SELECT * FROM books WHERE _id = #{id}"
    row = db.get_first_row(query)
    return nil if row == nil

    # get column information (index 1 is column name)
    columns = db.execute("PRAGMA table_info(books)")
    
    column_names = columns.select { |col| col[1] }
    Hash[column_names.zip(row)]
  end

end
