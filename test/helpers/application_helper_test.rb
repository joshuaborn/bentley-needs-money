require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "rename of flash notifications for Bulma" do
    assert_equal "info", bulma_notification_name("notice")
    assert_equal "info", bulma_notification_name("info")
    assert_equal "warning", bulma_notification_name("alert")
    assert_equal "warning", bulma_notification_name("warning")
    assert_equal "danger", bulma_notification_name("error")
    assert_equal "danger", bulma_notification_name("danger")
  end
end
