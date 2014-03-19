# Handles department database table
class Department < ActiveRecord::Base
  self.table_name = "department"
  validates :name, presence: true
  validates :code, presence: true

  # Returns Department data as a hash
  def to_hash
    hash = {
      "id" => id,
      "name" => name,
      "code" => code }
  end
end
