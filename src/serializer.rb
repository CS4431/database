require 'json'

module Serializer
  # Serialized data into the correct format
  #
  # @param kind [String] what data you're serializing (book, user, etc.)
  # @param data [Hash] the data you want serialized
  # @param ext [String] format extension
  def Serializer.serialize(kind, data, ext)
    hash = { "kind" => kind, "data" => data }
    JSON hash
  end
end
