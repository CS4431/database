require 'test/unit'
require 'net/http'
require 'json'

class TestAPI < Test::Unit::TestCase
  def test_book_request_no_ext
    params = {"id" => "1"}
    uri = URI("http://localhost:4567/api/book")
    res = Net::HTTP.post_form(uri, params)
    data = JSON.parse(res.body)

    assert_equal(1, data["data"]["id"])
  end
end