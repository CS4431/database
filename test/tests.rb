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

  # Sets up the Routes app to be run
  def app
    DBHandler.establish_test_connection
    routes = Routes
    routes.set :public_folder, 'public'
    routes.set :environment, :test
    routes
  end

  # Code to run before each test
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
  end

  # Tests that a user gets created fine
  def test_create_user
  	params = {"email" => "foo@lakeheadu.ca", "password" => "foo"}
    post 'api/create/user', params
    assert_equal(last_response.status.to_i, 200)
  end

  # Tests that a user can login
  def test_login
    params = {"email" => "user1@lakeheadu.ca", "password" => "password"}
    post '/api/login', params
    assert_equal(last_response.status.to_i, 200)
  end

  # Tests that you can get mutiple sells at a time
  def test_get_multiple_sells
    params = {"count" => 10}
    post '/api/sell', params
    data = JSON.parse(last_response.body)
    assert(data.length > 1)
  end

  # Tests that you cannot create a user using with an existing email address
  def test_emails_should_be_unique
    params = { 'email' => 'foo@lakeheadu.ca', 'password' => 'foo'}
    post 'api/create/user', params
    data = JSON.parse(last_response.body)
    assert data[0]['data']['id'] != nil
    post 'api/create/user', params
    data = JSON.parse(last_response.body)
    assert data[0]['kind'] == 'error'
  end

  def test_only_lakeheadu_emails_accepted
    params = { 'email' => 'foo@notlakeheadu.ca', 'password' => 'foo'}
    post 'api/create/user', params
    data = JSON.parse(last_response.body)
    assert data[0]['kind'] == 'error'
  end
end
