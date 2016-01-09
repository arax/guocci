require 'test_helper'

class HaikunatorControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end
