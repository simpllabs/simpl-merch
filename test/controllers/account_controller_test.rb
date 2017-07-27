require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get add_payment_info" do
    get account_add_payment_info_url
    assert_response :success
  end

end
