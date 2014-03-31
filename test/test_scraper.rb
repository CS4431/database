require 'test/unit'
require 'net/http'
require 'json'
require_relative '../src/scraper'

# Main class for running unit tests
class TestScraper < Test::Unit::TestCase
  # Tests that and isbn 10 is properly converted to isbn 13
  def test_convert_isbn_10_to_13
    isbn_10 = "0130131466"
    isbn_13 = Scraper.convert_to_isbn_13(isbn_10)
    assert_equal("9780130131461", isbn_13)
  end
end
