require 'json'

# Converts database results into text formats
module Serializer
  # valid file types to serialize
  EXTENSIONS = ["json", "xml"]

  # Serialized data into the correct format
  #
  # @param data_hash [Hash] Hash containing the data to be serialized; format is type => data
  # @param ext [String] format extension
  # @return [String] serialized data is specified format
  def Serializer.serialize(data_hash, ext)
    # Serialize an array of hashes
    hash_array = []
    data_hash.each do |kind, data|
      if data.kind_of?(Array) then
        data.each do |datum|
          hash_array << { "kind" => kind, "data" => datum }
        end
      else
        hash_array << {"kind" => kind, "data" => data}
      end
    end

    case ext
    when "json"
      return JSON hash_array
    when "xml"
      return Serializer.to_xml hash_array
    end
  end

  # Serialized data into valid xml
  #
  # @param hash [Hash] the data to be serialized
  # @return [String] serialized xml data
  def Serializer.to_xml(hash)
    result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    result << Serializer.val_to_xml(hash).force_encoding("UTF-8")
  end

  # Serialize a hash into xml
  #
  # @param hash [Hash] the data to be serialized
  # @return [String] hash data as xml
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

  # Parses json post parameters
  #
  # @param json_params [String] json containing the post parameters
  # @return [Hash] the post parameters as a hash
  def Serializer.parse_json_parameters(json_params)
    params = JSON.parse(json_params)

    params.each do |p_key, p_value|
      # convert JSON array onto ruby array
      if p_value.is_a? Array
        params[p_key] = params[p_key].collect do |arr_hashes|
          # is it a json array (array of hashes)?
          if arr_hashes.is_a? Hash
            arr_hashes = arr_hashes.collect { |k, v| v }
          else
            arr_hashes
          end
        end
        params[p_key].flatten!
      end
    end
  end
end
