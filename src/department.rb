class Department < ActiveRecord::Base
  self.table_name = "department"

  def to_hash
    puts "Boggle"
    hash = Hash.new
    hash["id"] = id
    hash["name"] = name
    hash["code"] = code
    return hash
  end
end