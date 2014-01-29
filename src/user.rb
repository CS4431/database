class User < ActiveRecord::Base
  self.table_name = "user"

  # Returns User data a a hash
  def to_hash
    hash = {
      "id" => id,
      "salt" => salt,
      "password" => password,
      "email" => email,
      "verified" => verified }
  end
end
