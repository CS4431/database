# Handles edition database table
class Edition < ActiveRecord::Base
  self.table_name = "edition"
  belongs_to :book, foreign_key: "book_id"

  # Returns Edition data as a hash
  def to_hash
    hash = {
      "id" => id,
      "isbn" => isbn,
      "book_id" => book_id,
      "author" => author,
      "edition" => edition,
      "publisher" => publisher,
      "cover" => cover,
      "image" => image }
  end
end
