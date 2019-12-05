require 'test_helper'

class TripsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get trips_new_url
    assert_response :success
  end

  test "should get show" do
    get trips_show_url
    assert_response :success
  end

  test "should get index" do
    get trips_index_url
    assert_response :success
  end

  test "should get edit" do
    get trips_edit_url
    assert_response :success
  end

  test "should get details" do
    get trips_details_url
    assert_response :success
  end

end
