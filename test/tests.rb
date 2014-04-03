# Main class for running unit tests
class TestAPI < SinatraTest
  # Tests that / redirects to the documentation
  def test_redirect_to_docs
    get '/'
    follow_redirect!
    assert last_response.ok?
    assert_equal 'http://example.org/doc/index.html', last_request.url
  end

  # Tests that you can get mutiple sells at a time
  def test_get_multiple_sells
    params = {"count" => 10}
    post '/api/sell', params
    data = JSON.parse(last_response.body)
    assert(data.length > 1)
  end
end
