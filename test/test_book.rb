require_relative './sinatra_test'

class TestBook < SinatraTest
  # perform a post to the api/book route
  # @param params [Hash] parameters to post
  # @return [Array] results returned from the route
  def post_book(params = {})
    post 'api/book', params
    JSON.parse last_response.body
  end

  # tests that book returns the correct 'kind'
  def test_book_kind
    data = post_book({'id' => 1})
    assert_equal('book', data[0]['kind'])
  end

  # tests that you can search for a book by id
  def test_get_book_by_id
    data = post_book({'id' => 1})
    assert_equal(1, data[0]['data']['id'])
  end

  # tests that you can search for a book by isbn
  def test_get_book_by_isbn
    data = post_book({'isbn' => '9780132990448'})
    assert_equal(9780132990448, data[0]['data']['isbn'])
  end

  # tests that you can search for a book by edition_group_id
  def test_get_book_by_edition_group_id
    data = post_book({'edition_group_id' => 1})
    assert_equal(1, data[0]['data']['edition_group_id'])
  end

  # tests that all information is returned by the route
  def test_return_all_book_information
    data = post_book({'id' => 1})
    assert(data[0]['data'].has_key?('id'))
    assert(data[0]['data'].has_key?('isbn'))
    assert(data[0]['data'].has_key?('edition_group_id'))
    assert(data[0]['data'].has_key?('author'))
    assert(data[0]['data'].has_key?('edition'))
    assert(data[0]['data'].has_key?('publisher'))
    assert(data[0]['data'].has_key?('cover'))
    assert(data[0]['data'].has_key?('image'))
    assert(data[0]['data'].has_key?('title'))
    assert(data[0]['data'].has_key?('course_code'))
    assert(data[0]['data'].has_key?('for_sale'))
  end 

end
