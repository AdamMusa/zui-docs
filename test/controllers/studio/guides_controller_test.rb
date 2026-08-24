require "test_helper"

class Studio::GuidesControllerTest < ActionDispatch::IntegrationTest
  test "renders the Lexxy guide editor" do
    get edit_studio_guide_path(guides(:quickstart))

    assert_response :success
    assert_select "lexxy-editor[name='guide[body]']", 1
    assert_select ".lexxy-shell", text: /Markdown enabled/
  end

  test "publishes edited Action Text content" do
    patch studio_guide_path(guides(:quickstart)), params: {
      guide: {
        title: "Quickstart",
        summary: "A better first Zui app.",
        body: "<h2>Updated</h2><p>Native Ruby.</p>"
      }
    }

    assert_redirected_to guide_path("quickstart")
    assert_equal "A better first Zui app.", guides(:quickstart).reload.summary
    assert_includes guides(:quickstart).body.to_plain_text, "Native Ruby"
  end
end
