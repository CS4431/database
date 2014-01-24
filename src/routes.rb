require 'sinatra/base'
require './db_handler'
require './serializer'
require 'mail'

class Routes < Sinatra::Base
  # Make server publicly accessible
  set :bind, '0.0.0.0'
  @extensions = Serializer::EXTENSIONS

  before do
    DBHandler.establish_connection
  end

  # Checks for existence of the ext get parameter and assigns it to a class variable
  # @param p [Hash] the parameters hash
  # Returns the parameters hash without the ext parameter
  def clean_extension(p)
    halt "ext = nil, extension parameter not passed." unless p.key?("ext")
    @@ext = p["ext"]
    p.delete("ext")
    return p
  end

  # Routes

  # @method get_documentation
  # @overload get "/"
  # Returns the documentation if you have a top-level request
  get '/' do
    if File.exist?("public/doc/index.html")
      redirect to('doc/index.html')
    else
      "YARD Docs not generated! Please contact the server administrators."
    end
  end

  # @method select_from_database
  # @overload get "/api/:type?foo=bar&foo2=bar2..."
  # @param type [String] The type of record being fetched
  # @param get-params [Hash] A & delimeted list, prepended by ?, with all the search parameters
  # Returns the record you're searching for or returns empty hash in JSON/XML
  # @note Ensure you pass ext=<serialized type> in get parameters to specify your return format!
  get "/api/:type" do
    type = params[:type]
    parameters = clean_extension(params)

    # Remove captures, type and splat from outgoing hash
    parameters.delete("captures")
    parameters.delete("type")
    parameters.delete("splat")

    case type
    when "book"
      data = DBHandler.get_book(parameters)
    when "department"
      data = DBHandler.get_department(parameters)
    when "course"
      data = DBHandler.get_course(parameters)
    else
      halt "Invalid type of data requested."
    end

    Serializer.serialize(type, data, @@ext)
  end

  # @method verify
  # @param code [String] code to verify account
  # Returns a message saying if the verification was successful or not
  get '/verify/:code' do
    result = DBHandler.verify_user(params[:code])
    if result == true
      return "Verification successful"
    else
      return "Error validating account"
    end
  end

  # Since we are subclassing Sinatra, we need to start Sinatra if being run directly
  run! if app_file = $0
end
