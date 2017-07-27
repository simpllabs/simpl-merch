require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get order_export" do
    get orders_order_export_url
    assert_response :success
  end

end
