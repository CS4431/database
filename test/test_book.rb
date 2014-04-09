require_relative './sinatra_test'

# Unit tests for book routes
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
    data = post_book('id' => 1)
    assert_equal('book', data[0]['kind'])
  end

  # tests that you can search for a book by id
  def test_get_book_by_id
    data = post_book('id' => 1)
    assert_equal(1, data[0]['data']['id'])
  end

  # tests that you can search for a book by isbn
  def test_get_book_by_isbn
    data = post_book('isbn' => '9780132990448')
    assert_equal('9780132990448', data[0]['data']['isbn'].to_s)
  end

  # tests that you can search for a book by edition_group_id
  def test_get_book_by_edition_group_id
    data = post_book('edition_group_id' => 1)
    assert_equal(1, data[0]['data']['edition_group_id'])
  end

  # tests that all information is returned by the route
  def test_return_all_book_information
    data = post_book('id' => 1)
    keys = %w(id isbn edition_group_id author edition publisher cover image
              title course_code for_sale).sort
    returned_keys = data[0]['data'].keys.sort
    assert(returned_keys.size == keys.size && returned_keys & keys == keys,
           'Missing Keys: ' + (keys - returned_keys).to_s)
  end

  # tests that local book images will return the full uri
  def test_local_images_converted_to_full_uri
    data = post_book('id' => 1)
    assert_equal('http://bookmarket.webhop.org/images/book/9780132990448.jpg',
                 data[0]['data']['image'])
  end

  # tests that foreign images will not be converted to use server's address
  def test_foreign_images_will_not_be_converted
    data = post_book('id' => 2)
    assert_equal('http://www.example.com/images/books/calculus.jpg',
                 data[0]['data']['image'])
  end

  # tests that a book will return a value of nil for it's image
  def test_book_with_no_image_returns_nil_for_image
    data = post_book('id' => 3)
    assert_equal(nil, data[0]['data']['image'])
  end
end
