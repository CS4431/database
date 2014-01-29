require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt
  self.table_name = "user"

  def pass=(new_password)
    self.salt = Engine.generate_salt
    self.password = Password.create(self.salt + new_password)
  end

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
