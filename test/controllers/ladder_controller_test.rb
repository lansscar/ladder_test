require 'test_helper'

class LadderControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ladder_index_url
    assert_response :success
  end

end
