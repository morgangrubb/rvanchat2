require 'test_helper'

class CallbacksControllerTest < ActionController::TestCase
  test "should get facebook" do
    get :facebook
    assert_response :success
  end

  test "should get google_oauth2" do
    get :google_oauth2
    assert_response :success
  end

end
