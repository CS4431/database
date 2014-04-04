require_relative './sinatra_test'

# Test department detail routes
class TestDepartmentDetail < SinatraTest
  # perform a post to the api/departmentdetail route
  # @param params [Hash] parameters to post
  # @return [Array] results returned from the route
  def post_departmentdetail(params = {})
    post 'api/departmentdetail', params
    JSON.parse last_response.body
  end

  # tests that departmentdetail return the correct 'kind'
  def test_get_departmentdetail_kind
    data = post_departmentdetail({'id' => 1})
    assert_equal('department_courses', data[0]['kind'])
  end

  # tests that the courses for the department are returned
  def test_return_courses
    data = post_departmentdetail({'id' => 1})
    courses = data[0]['data']['courses']
    assert_equal(1, courses[0]['department_id'])
  end
end
