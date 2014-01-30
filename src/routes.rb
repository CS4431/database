require 'sinatra/base'
require './db_handler'
require './serializer'
require 'mail'

class Routes < Sinatra::Base
  # Make server publicly accessible
  set :bind, '0.0.0.0'

  before do
    @extensions = Serializer::EXTENSIONS
    DBHandler.establish_connection
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

  # @method get_book
  # @overload get "/api/book?[key]=[value]&[key2]=[value2]..."
  # @param get-params [Hash] get parameters to search books by
  # @param extension [String] return format, JSON or XML
  # Returns Book data searched by given get parameters
  get "/api/book" do
    ext = params["ext"]
    params.delete("ext")

    data = DBHandler.get_book(params)
    Serializer.serialize("book", data, ext)
  end

  # @method get_department
  # @overload get "/api/department?[key]=[value]&[key2]=[value2]..."
  # @param (see #get_book)
  # Returns Department data searched by given get parameters
  get "/api/department" do
    ext = params["ext"]
    params.delete("ext")

    data = DBHandler.get_department(params)
    Serializer.serialize("department", data, ext)
  end

  # @method get_course
  # @overload get "/api/department?[key]=[value]&[key2]=[value2]..."
  # @param (see #get_book)
  # Returns Course data by given id in specified format 
  get "/api/course" do
    ext = params["ext"]
    params.delete("ext")

    data = DBHandler.get_course(params)
    Serializer.serialize("course", data, ext)
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
