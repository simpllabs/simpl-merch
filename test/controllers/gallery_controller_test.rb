require 'test_helper'

class GalleryControllerTest < ActionDispatch::IntegrationTest
  test "should get gallery" do
    get gallery_gallery_url
    assert_response :success
  end

end
