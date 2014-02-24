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
end
