require 'sinatra/base'

class Routes < Sinatra::Base
  before do
    @extensions = ['json', 'xml']
  end

  # Routes

  # @method get_documentation
  # @overload get "/"
  # Returns the documentation if you have a top-level request
  get '/' do
    send_file "public/doc/Routes.html"
  end

  # @method get_book_by_ISBN
  # @overload get "/api/book/*.*"
  # @param isbn [Fixnum] book ISBN, 10 or 13 digits
  # @param extension [String] return format, JSON or XML
  # Returns Book data by given 10-digit or 13-digit ISBN in specified format
  get %r{/api/book/(\d{10,})\.(\w+)} do |isbn, ext|
    ext.downcase!

    # Sanitize API call
    halt 400, "Your ISBN is malformed." unless isbn.length == 10 or isbn.length == 13
    halt 400, "Bad extension" unless @extensions.include? ext

    "ISBN: #{isbn}, Extension: #{ext}"
  end

  # Since we are subclassing Sinatra, we need to start Sinatra if being run directly
  run! if app_file = $0
end