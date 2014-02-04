class Sell < ActiveRecord::Base
  self.table_name = "sell"

  # Returns Sell data as a hash
  def to_hash
    hash = {
      "id" => id,
      "user_id" => user_id,
      "book_id" => book_id,
      "price" => price,
      "start_date" => start_date,
      "end_date" => end_date }
  end
end
