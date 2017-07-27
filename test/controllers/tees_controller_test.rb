require 'test_helper'

class TeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tee = tees(:one)
  end

  test "should get index" do
    get tees_url
    assert_response :success
  end

  test "should get new" do
    get new_tee_url
    assert_response :success
  end

  test "should create tee" do
    assert_difference('Tee.count') do
      post tees_url, params: { tee: { shop_id: @tee.shop_id, tee_back_url: @tee.tee_back_url, tee_front_url: @tee.tee_front_url } }
    end

    assert_redirected_to tee_url(Tee.last)
  end

  test "should show tee" do
    get tee_url(@tee)
    assert_response :success
  end

  test "should get edit" do
    get edit_tee_url(@tee)
    assert_response :success
  end

  test "should update tee" do
    patch tee_url(@tee), params: { tee: { shop_id: @tee.shop_id, tee_back_url: @tee.tee_back_url, tee_front_url: @tee.tee_front_url } }
    assert_redirected_to tee_url(@tee)
  end

  test "should destroy tee" do
    assert_difference('Tee.count', -1) do
      delete tee_url(@tee)
    end

    assert_redirected_to tees_url
  end
end
