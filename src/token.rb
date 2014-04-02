require 'securerandom'

# Handles token database table
class Token < ActiveRecord::Base
  self.table_name = "token"

  # Creates a unique access token
  #
  # @return [String] a universally unique identifier
  def Token.generate_uuid
    SecureRandom.uuid
  end

  # Constructs a Token object
  #
  # @param email [String] the email to tie the token to
  # @return [Token] the token generated
  def Token.make_token(email)
		token = Token.new do |t|
      t.email = email
      t.start_date = Time.now
      seven_days = 604800
      t.end_date = Time.now + seven_days
      t.token = Token.generate_uuid
    end
  end

end
