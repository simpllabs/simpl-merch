require 'test_helper'

class PackingslipControllerTest < ActionDispatch::IntegrationTest
  test "should get message" do
    get packingslip_message_url
    assert_response :success
  end

end
