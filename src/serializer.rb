require 'json'

module Serializer
  # Serialized data into the correct format
  #
  # @param kind [String] what data you're serializing (book, user, etc.)
  # @param data [Hash] the data you want serialized
  # @param ext [String] format extension
  def Serializer.serialize(kind, data, ext)
    hash = { "kind" => kind, "data" => data }
    case ext
    when "json"
      return JSON hash
    when "xml"
      hash = {kind => data}
      return Serializer.to_xml hash
    end
  end

  def Serializer.to_xml(hash)
    result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    result << Serializer.val_to_xml(hash).force_encoding("UTF-8")
  end

  def Serializer.val_to_xml(hash)
    result = ""
    hash.each do |k,v|
      result << "<#{k}>"
      if v.is_a? Hash
        result << Serializer.val_to_xml(v)
      else
        result << v.to_s
      end
      result << "</#{k}>"
    end
    return result
  end

end
