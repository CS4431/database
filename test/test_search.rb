require_relative './sinatra_test'

# Tests search routes
class TestSearch < SinatraTest
  # tests that a book can be searched for by its title
  def test_search_book_matching_title
    params = { 'searchstring' => 'Calculus' }
    post 'api/search/book', params
    data = JSON.parse(last_response.body)
    assert_equal('book', data[0]['kind'])
  end

  # tests that you can search for a course by title
  def test_search_course_by_title
    params = { 'searchstring' => 'computer' }
    post 'api/search/course', params
    data = JSON.parse(last_response.body)
    assert_equal('course', data[0]['kind'])
  end

  # tests that you can search for a course by code
  def test_search_course_by_code
    params = { 'searchstring' => 'comp-1411' }
    post 'api/search/course', params
    data = JSON.parse(last_response.body)
    assert_equal('course', data[0]['kind'])
  end

  # tests that a search not matching any results will return an empty array
  def test_no_results_returns_empty_array
    params = { 'searchstring' => 'abcdefghijk' }
    post 'api/search/course', params
    data = JSON.parse(last_response.body)
    assert_equal([], data)
  end

  # tests that you can search for a department by name
  def test_search_department_by_name
    params = { 'searchstring' => 'computer' }
    post 'api/search/department', params
    data = JSON.parse(last_response.body)
    assert_equal('department', data[0]['kind'])
  end

  # tests that you can search for a department by code
  def test_search_department_by_code
    params = { 'searchstring' => 'comp' }
    post 'api/search/department', params
    data = JSON.parse(last_response.body)
    assert_equal('department', data[0]['kind'])
  end
end
