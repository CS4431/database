require 'bcrypt'

# Handles user database table
class User < ActiveRecord::Base
  include BCrypt
  self.table_name = "user"
  validates :email, presence: true
  validates :password, presence: true

  # Sets and hashes the user's password
  #
  # @param new_password [String] plaintext password
  def pass=(new_password)
    self.password = Password.create(new_password)
    puts self.password.encoding
  end

  # Checks if password is valid
  #
  # @param try_password [String] password to try
  # @return [Bool] true if password matches; false otherwise
  def login(try_password)
    pass = Password.new(self.password.encode('ascii-8bit'))
    return pass == try_password
  end

  # Returns User data (id, email) as a hash
  def to_hash
    hash = {
      "id" => id,
      "email" => email }
  end
end
