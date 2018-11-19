require 'test_helper'

class TrackingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trackings_index_url
    assert_response :success
  end

  test "should get destroy" do
    get trackings_destroy_url
    assert_response :success
  end

  test "should get create" do
    get trackings_create_url
    assert_response :success
  end

end
