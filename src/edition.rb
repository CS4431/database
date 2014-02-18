# Handles edition database table
class Edition < ActiveRecord::Base
  self.table_name = "edition"
  belongs_to :edition_group, foreign_key: "edition_group_id"

  # Returns Edition data as a hash
  def to_hash
    hash = {
      "id" => id,
      "isbn" => isbn,
      "edition_group_id" => edition_group_id,
      "author" => author,
      "edition" => edition,
      "publisher" => publisher,
      "cover" => cover,
      "image" => image }
  end
end
