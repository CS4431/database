# Handles buy database table
class Buy < ActiveRecord::Base
  self.table_name = "buy"

  # Returns Buy data as a hash
  def to_hash
    hash = {
      "id" => id,
      "user_id" => user_id,
      "book_id" => book_id,
      "start_date" => start_date,
      "end_date" => end_date }
  end
end
