require 'securerandom'

# Handles token database table
class Token < ActiveRecord::Base
  self.table_name = "token"

  # Creates a unique access token
  #
  # @return [String] a universally unique identifier
  def Token.generate_token
    SecureRandom.uuid
  end
end
