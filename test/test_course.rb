require_relative './sinatra_test'

# Test Course routes
class TestCourse < SinatraTest
  # perform a post to the api/course route
  # @param params [Hash] parameters to post
  # @return [Array] results returned from the route
  def post_course(params = {})
    post 'api/course', params
    JSON.parse last_response.body
  end

  # tests that course returns the correct 'kind'
  def test_course_kind
    data = post_course('id' => 1)
    assert_equal('course', data[0]['kind'])
  end

  # tests that you can search for a course by id
  def test_get_course_by_id
    data = post_course('id' => 1)
    assert_equal(1, data[0]['data']['id'])
  end

  # test that you can search for a course by title
  def test_get_course_by_title
    data = post_course('title' => 'Calculus')
    assert_equal('Calculus', data[0]['data']['title'])
  end

  # tests that you can search for a course by code
  def test_get_course_by_code
    data = post_course('code' => 'COMP-1411')
    assert_equal('COMP-1411', data[0]['data']['code'])
  end

  # tests that you can search for a course by department_id
  def test_get_course_by_department_id
    data = post_course('department_id' => 1)
    assert_equal(1, data[0]['data']['department_id'])
  end

  # tests that you can get multiple courses
  def test_get_multiple_courses
    data = post_course('count' => 2)
    assert_equal(2, data.length)
  end

  # tests that you can offset course search results
  def test_get_course_offset
    data = post_course('count' => 1, 'offset' => 1)
    assert_equal(2, data[0]['data']['id'])
  end

  # tests that course route returns all the information
  def test_return_all_course_information
    data = post_course('id' => 1)
    assert(data[0]['data'].key?('id'))
    assert(data[0]['data'].key?('title'))
    assert(data[0]['data'].key?('code'))
    assert(data[0]['data'].key?('section'))
    assert(data[0]['data'].key?('department_id'))
    assert(data[0]['data'].key?('instructor'))
    assert(data[0]['data'].key?('term'))
    assert(data[0]['data'].key?('department_name'))
  end
end
