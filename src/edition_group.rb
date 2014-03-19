# Handles edition_group database table
class EditionGroup < ActiveRecord::Base
  self.table_name = "edition_group"
  has_many :editions
  validates :title, presence: true

  # Returns Book data as a hash
  def to_hash
    hash = {
      "id" => id,
      "title" => title }
  end
end
