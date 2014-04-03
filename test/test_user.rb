require_relative './sinatra_test'

class TestUser < SinatraTest
  # perform a post to the api/create/user route
  # @param params [Hash] parameters to post
  # @return [Array] results returned from the route
  def post_create_user(params = {})
    post 'api/create/user', params
    JSON.parse last_response.body
  end
  
  # tests that creating an email will return the email back on success
  def test_create_user_returns_email
    data = post_create_user({'email' => 'newuser@lakeheadu.ca',
                             'password' => 'password'})
    assert_equal('newuser@lakeheadu.ca', data[0]['data']['email'])
  end

  # tests that multiple accounts cannot be created for the same email
  def test_no_duplicate_emails
    data = post_create_user({'email' => 'user1@lakeheadu.ca',
                             'password' => 'password'})
    assert_equal('error', data[0]['kind'])
  end

  # tests that only lakeheadu.ca emails are accepted
  def test_only_lakehead_emails
    data = post_create_user({'email' => 'user1@notlakeheadu.ca',
                             'password' => 'password'})
    assert_equal('error', data[0]['kind'])
  end

  # tests that sending no post parameters will return an error
  def test_send_no_parameters_returns_error
    data = post_create_user({})
    assert_equal('error', data[0]['kind'])
  end

end
