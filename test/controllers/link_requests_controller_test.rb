require 'test_helper'

class LinkRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get createlinkrequest" do
    get link_requests_createlinkrequest_url
    assert_response :success
  end

end
