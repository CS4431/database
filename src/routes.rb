require 'sinatra/base'
require 'sinatra/activerecord'
require_relative './db_handler'
require_relative './serializer'

# Handles all url pattern matching and sends the requested data back to the user. Main entry point of the application.
class Routes < Sinatra::Base
  @extensions = Serializer::EXTENSIONS

  # Checks for existence of the ext get parameter and assigns it to a class variable
  # @param p [Hash] the parameters hash
  # Returns the parameters hash without the ext parameter
  def clean_extension(p)
    @@ext = "json" 
    return p unless p.key?("ext")
    @@ext = p["ext"]
    p.delete("ext")
    return p
  end

  # Routes

  # @method get_documentation
  # @overload get "/"
  # Returns the documentation if you have a top-level request
  get '/' do
    index = File.expand_path('doc/index.html', settings.public_folder)
    if File.exist?(index)
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
  post "/api/:type" do
    type = params[:type]
    parameters = clean_extension(params)
    count = parameters.key?("count") ? parameters.delete("count") : 1
    offset = parameters.key?("offset") ? parameters.delete("offset") : 0

    # Remove captures, type and splat from outgoing hash
    parameters.delete("captures")
    parameters.delete("type")
    parameters.delete("splat")
  
    case type
    when "book"
      books = DBHandler.get_books(parameters, count, offset)
      data_hash = {"book" => books}
    when "department"
      departments = DBHandler.get_departments(parameters, count, offset)
      data_hash = {"department" => departments}
    when "course"
      courses = DBHandler.get_courses(parameters, count, offset)
      data_hash = {"course" => courses}
    when "sell"
      sells = DBHandler.get_sells(parameters, count, offset)
      edition_ids = sells.collect { |sell| sell["edition_id"] }
      books = DBHandler.get_books({"id" => edition_ids}, edition_ids.count, 0)
      data_hash = {"sell" => sells, "book" => books}
    else
      halt "Invalid type of data requested."
    end

    Serializer.serialize(data_hash, @@ext)
  end

  # @method add_to_database
  # @overload post "/api/create/:type"
  # @param type [String] the type of record being added
  # @param post-params [Hash] the POST parameters passed with the HTTP request, gets passed as Hash to database
  # Returns the record you added to the database as your selected extension
  post "/api/create/:type" do
    type = params[:type]
    parameters = clean_extension(params)

    # Remove captures, type and splat from outgoing hash
    parameters.delete("captures")
    parameters.delete("type")
    parameters.delete("splat")

    case type
    when "sell"
      sells = DBHandler.create_sell(parameters)
      data_hash = {"sell" => sells}
    else
      halt "Invalid data type requested."
    end

    Serializer.serialize(data_hash, @@ext)
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
  if app_file == $0
    set :root, Pathname.new(Pathname(__FILE__).dirname + '/../')
    set :public_folder, '../public'
    run!
  else
    set :root, Pathname.new(Pathname(__FILE__).dirname + './')
    set :public_folder, './public'
  end
  #run! if app_file == $0
end
