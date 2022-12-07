require "test_helper"

class GradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grade = grades(:one)
  end

  test "should get index" do
    get grades_url
    assert_response :success
  end

  test "should get new" do
    get new_grade_url
    assert_response :success
  end

  test "should create grade" do
    assert_difference("Grade.count") do
      post grades_url, params: { grade: { admission_type_id: @grade.admission_type_id, efficiency: @grade.efficiency, enroll_state: @grade.enroll_state, graduate_status: @grade.graduate_status, registration_status: @grade.registration_status, simple_average: @grade.simple_average, student_id: @grade.student_id, study_plan_id: @grade.study_plan_id, weighted_average: @grade.weighted_average } }
    end

    assert_redirected_to grade_url(Grade.last)
  end

  test "should show grade" do
    get grade_url(@grade)
    assert_response :success
  end

  test "should get edit" do
    get edit_grade_url(@grade)
    assert_response :success
  end

  test "should update grade" do
    patch grade_url(@grade), params: { grade: { admission_type_id: @grade.admission_type_id, efficiency: @grade.efficiency, enroll_state: @grade.enroll_state, graduate_status: @grade.graduate_status, registration_status: @grade.registration_status, simple_average: @grade.simple_average, student_id: @grade.student_id, study_plan_id: @grade.study_plan_id, weighted_average: @grade.weighted_average } }
    assert_redirected_to grade_url(@grade)
  end

  test "should destroy grade" do
    assert_difference("Grade.count", -1) do
      delete grade_url(@grade)
    end

    assert_redirected_to grades_url
  end
end
