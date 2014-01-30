require 'securerandom'

class Verification < ActiveRecord::Base
  self.table_name = "verification"

  # Generates a verification code
  #
  # @return [String] verification code
  def Verification.generate_code
    return SecureRandom.urlsafe_base64    
  end
end
