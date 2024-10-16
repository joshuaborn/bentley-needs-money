require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_path, params: { person_id: people(:administrator).id }
    @person = people(:user_one)
  end

  test "should not be allowed to access any actions if not an administrator" do
    delete login_path
    post login_path, params: { person_id: people(:user_one).id }
    get people_path
    assert_redirected_to root_url
    assert_equal "The administrator functionality can only be accessed by administrators.", flash[:danger]
  end

  test "should get index" do
    get people_path
    assert_response :success
  end

  test "should get new" do
    get new_person_path
    assert_response :success
  end

  test "should create person" do
    assert_difference("Person.count") do
      post people_path, params: { person: { is_administrator: @person.is_administrator, name: @person.name } }
    end

    assert_redirected_to people_url
  end

  test "should get edit" do
    get edit_person_path(@person)
    assert_response :success
  end

  test "should update person" do
    patch person_path(@person), params: { person: { is_administrator: @person.is_administrator, name: @person.name } }
    assert_redirected_to people_url
  end

  test "should destroy person" do
    assert_difference("Person.count", -1) do
      delete person_path(@person)
    end

    assert_redirected_to people_url
  end
end
