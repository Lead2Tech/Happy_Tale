require "test_helper"

class PlaygroundsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get playgrounds_index_url
    assert_response :success
  end

  test "should get show" do
    get playgrounds_show_url
    assert_response :success
  end

  test "should get new" do
    get playgrounds_new_url
    assert_response :success
  end

  test "should get create" do
    get playgrounds_create_url
    assert_response :success
  end

  test "should get edit" do
    get playgrounds_edit_url
    assert_response :success
  end

  test "should get update" do
    get playgrounds_update_url
    assert_response :success
  end

  test "should get destroy" do
    get playgrounds_destroy_url
    assert_response :success
  end
end
