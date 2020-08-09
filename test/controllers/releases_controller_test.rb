require 'test_helper'

class ReleasesControllerTest < ActionDispatch::IntegrationTest
  test "should get view" do
    get releases_view_url
    assert_response :success
  end

end
