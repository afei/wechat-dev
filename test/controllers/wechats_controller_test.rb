require 'test_helper'

class WechatsControllerTest < ActionController::TestCase
  test "should get wechat_auth" do
    get :wechat_auth
    assert_response :success
  end

  test "should get wechat_post" do
    get :wechat_post
    assert_response :success
  end

end
