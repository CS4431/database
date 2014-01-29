class Contact < ActiveRecord::Base
  self.table_name = "contact"

  # Returns Contact data as a hash
  def to_hash
    hash = {
      "id" => id,
      "contactor_id" => contactor_id,
      "listing_id" => listing_id,
      "date" => date }
  end
end
