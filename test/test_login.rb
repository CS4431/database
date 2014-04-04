require_relative './sinatra_test'

# Unit tests for testing login routes
class TestLogin < SinatraTest
  # tests that using a valid token will work
  def test_valid_token
    params = {'user_id' => 'abcd'}
    post 'api/sell', params
    data = JSON.parse(last_response.body)
    assert_not_equal('error', data[0]['kind'])
  end

  # tests that using an expired token will send an error
  def test_expired_token_sends_error
    params = {'user_id' => 'efgh'}
    post 'api/sell', params
    data = JSON.parse(last_response.body)
    assert_equal('error', data[0]['kind'])
  end

  # tests that using a token that doesn't exist sends and error
  def test_nonexistant_token_sends_error
    params = {'user_id' => 'aaaa'}
    post 'api/sell', params
    data = JSON.parse(last_response.body)
    assert_equal('error', data[0]['kind'])
  end

  # tests that logging in will return a token
  def test_login_returns_token
    params = {'email' => 'user1@lakeheadu.ca',
              'password' => 'password'}
    post 'api/login', params
    data = JSON.parse(last_response.body)
    assert_equal('token', data[0]['kind'])
  end
  
  # tests that using a wrong password will return an error
  def test_wrong_password_returns_error
    params = {'email' => 'user1@lakeheadu.ca',
              'password' => 'notpassword'}
    post 'api/login', params
    data = JSON.parse(last_response.body)
    assert_equal('error', data[0]['kind'])
  end

  # tests that using a wrong email will return an error
  def test_wrong_email_returns_error
    params = {'email' => 'nouser@lakeheadu.ca',
              'password' => 'password'}
    post 'api/login', params
    data = JSON.parse(last_response.body)
    assert_equal('error', data[0]['kind'])
  end

  # tests that the same error message is returned for an incorrect email
  # and incorrect password
  def test_wrong_email_and_wrong_password_return_same_error
    params = {'email' => 'user1@lakeheadu.ca',
              'password' => 'notpassword'}
    post 'api/login', params
    wrong_password_data = JSON.parse(last_response.body)

    params = {'email' => 'nouser@lakeheadu.ca',
              'password' => 'password'}

    wrong_email_data = JSON.parse(last_response.body)
    assert_equal(wrong_password_data, wrong_email_data)
  end

end
