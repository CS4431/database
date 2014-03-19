require 'date'

# Handles sell database table
class Sell < ActiveRecord::Base
  self.table_name = "sell"
  validates :user_id, presence: true
  validates :edition_id, presence: true
  validates :price, presence: true
  @@expire_days = 30

  def Sell.new_with_dates(hash)
    sell = Sell.new(hash)
    sell.start_date = Time.now
    sell.end_date = Time.now + @@expire_days.days
    sell.save
    sell
  end

  # Returns Sell data as a hash
  def to_hash
    hash = {
      "id" => id,
      "user_id" => user_id,
      "edition_id" => edition_id,
      "price" => price,
      "start_date" => start_date,
      "end_date" => end_date }
  end
end
