require_relative './sinatra_test'

# Test Department routes
class TestDepartment < SinatraTest
  # perform a post to the api/department route
  # @param params [Hash] parameters to post
  # @return [Array] results returned from the route
  def post_department(params = {})
    post 'api/department', params
    JSON.parse last_response.body
  end

  # tests that department returns the correct 'kind'
  def test_department_kind
    data = post_department('id' => 1)
    assert_equal('department', data[0]['kind'])
  end

  # tests that you can search for a department by id
  def test_get_department_by_id
    data = post_department('id' => 1)
    assert_equal(1, data[0]['data']['id'])
  end

  # tests that you can search for a department by code
  def test_get_department_by_code
    data = post_department('code' => 'COMP')
    assert_equal('COMP', data[0]['data']['code'])
  end

  # tests that you can search for a department by name
  def test_get_department_by_name
    data = post_department('name' => 'Computer Science')
    assert_equal('Computer Science', data[0]['data']['name'])
  end

  # tests that you can get back multiple departments
  def test_get_multiple_departments
    data = post_department('count' => 2)
    assert_equal(2, data.length)
  end

  # tests that you can offset the results returned
  def test_get_deparment_offset
    data = post_department('count' => 1, 'offset' => 1)
    assert_equal(2, data[0]['data']['id'])
  end

  # tests that 1 department is returned if no count given
  def test_default_department_count
    data = post_department('id' => 1)
    assert_equal(1, data.length)
  end
  # tests that all information is returned by the route
  def test_return_all_department_information
    data = post_department('id' => 1)
    assert(data[0]['data'].key?('id'))
    assert(data[0]['data'].key?('code'))
    assert(data[0]['data'].key?('name'))
  end
end
