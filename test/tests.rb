require 'test/unit'
require 'net/http'
require 'json'
require_relative '../src/routes'
require_relative '../src/db_handler'
require_relative './fixtures'
require 'rack/test'


# Main class for running unit tests
class TestAPI < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    DBHandler.establish_test_connection
    routes = Routes
    routes.set :public_folder, 'public'
    routes.set :environment, :test
    routes
  end

  def setup
    DBHandler.establish_test_connection
    Fixtures.load
  end

  # Tests that / redirects to the documentation
  def test_redirect_to_docs
    get '/'
    follow_redirect!
    assert last_response.ok?
    assert_equal 'http://example.org/doc/index.html', last_request.url
  end

  # Tests that the book request with no "ext" parameter loads correctly
  def test_book_request_no_ext
    params = {"id" => "1"}
    post '/api/book', params
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    assert_equal(1, data[0]["data"]["id"])
  # @note Ensure you pass ext=<serialized type> in get parameters to specify your return format!
  end

  # Tests that a user gets created fine
  def test_create_user
  	params = {"email" => "foo@lakeheadu.ca", "password" => "foo", "ext" => "json"}
    post 'api/create/user', params
    puts last_response.status
    assert_equal(last_response.status.to_i, 200)
    end

  # Tests that a user can login
  def test_login
    # Create user first
    params = {"email" => "foo@lakeheadu.ca", "password" => "foo", "verified" => "true", "ext" => "json"}
    post '/api/create/user', params

    params = {"email" => "foo@lakeheadu.ca", "password" => "foo", "ext" => "json"}
    post '/api/login', params

    assert_equal(last_response.status.to_i, 200)
  end
end
