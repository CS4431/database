# Main class for running unit tests
class TestAPI < SinatraTest
  # Tests that / redirects to the documentation
  def test_redirect_to_docs
    get '/'
    follow_redirect!
    assert last_response.ok?
    assert_equal 'http://example.org/doc/index.html', last_request.url
  end
end
