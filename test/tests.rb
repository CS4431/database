require 'test/unit'
require 'net/http'
require 'json'

# Main class for running unit tests
class TestAPI < Test::Unit::TestCase
  # Tests that the book request with no "ext" parameter loads correctly
  def test_book_request_no_ext
    params = {"id" => "1"}
    uri = URI("http://localhost:4567/api/book")
    res = Net::HTTP.post_form(uri, params)
    data = JSON.parse(res.body)

    assert_equal(1, data[0]["data"]["id"])
  # @note Ensure you pass ext=<serialized type> in get parameters to specify your return format!
  end

  # Tests that a user gets created fine
  def test_create_user
  	params = {"email" => "foo@lakeheadu.ca", "password" => "foo", "ext" => "json"}
  	uri = URI("http://localhost:4567/api/create/user")
  	res = Net::HTTP.post_form(uri, params)

  	assert_equal(res.code.to_i, 200)
	end

  # Tests that a user can login
  def test_login
    # Create user first
    params = {"email" => "foo@lakeheadu.ca", "password" => "foo", "verified" => "true", "ext" => "json"}
    uri = URI("http://localhost:4567/api/create/user")
    res = Net::HTTP.post_form(uri, params)

    params = {"email" => "foo@lakeheadu.ca", "password" => "foo", "ext" => "json"}
    uri = URI("http://localhost:4567/api/login")
    res = Net::HTTP.post_form(uri, params)

    assert_equal(res.code.to_i, 200)
  end
end
