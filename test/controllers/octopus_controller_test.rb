require "test_helper"

class OctopusControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get octopus_index_url
    assert_response :success
  end
end
