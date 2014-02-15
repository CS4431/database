# Handles book database table
class Book < ActiveRecord::Base
  self.table_name = "book"
  has_many :editions

  # Returns Book data as a hash
  def to_hash
    hash = {
      "id" => id,
      "title" => title }
  end
end
