require_relative './sinatra_test'

# Tests sell routes
class TestSell < SinatraTest

  # tests that a user can delete their own sells
  def test_can_delete_own_sell
    params = {'user_id' => 'abcd', 'id' => 1}
    post 'api/delete/sell', params
    data = JSON.parse(last_response.body)
    assert_not_equal('error', data[0]['kind'])
  end

  # tests that a user cannot delete other user's sells 
  def test_cannot_delete_other_users_sells
    params = {'user_id' => 'efgh', 'id' => 1}
    post 'api/delete/sell', params
    data = JSON.parse(last_response.body)
    assert_equal('error', data[0]['kind'])
  end
end
