# Handles buy database table
class Buy < ActiveRecord::Base
  self.table_name = "buy"
  validates :user_id, presence: true
  validates :edition_id, presence: true

  # Returns Buy data as a hash
  def to_hash
    hash = {
      "id" => id,
      "user_id" => user_id,
      "edition_id" => edition_id,
      "start_date" => start_date,
      "end_date" => end_date }
  end
end
