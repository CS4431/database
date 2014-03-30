require 'securerandom'

# Handles verification database table
class Verification < ActiveRecord::Base
  self.table_name = "verification"
  validates :code, presence: true
  validates :user_id, presence: true

  # Generates a verification code
  # @param user_id [Integer] the user_id to generate a verification code for
  # @return [String] verification code
  def Verification.generate(user_id)
    verification = Verification.new
    verification.user_id = user_id
    verification.code = SecureRandom.urlsafe_base64
    verification.end_date = Time.now + 86400 # 1 day
    verification.save
    verification
  end
end
