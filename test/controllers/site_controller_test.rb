require 'test_helper'

class SiteControllerTest < ActionController::TestCase
  test "should get notifications" do
    get :notifications
    assert_response :success
  end

end
