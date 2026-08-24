require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "renders the visual product overview and source-backed catalog" do
    get root_path

    assert_response :success
    assert_select "h1", text: /Native UI/
    assert_select ".metrics-strip strong", text: "241"
    assert_select ".hero__demo", 1
    assert_select ".bento-grid .bento", 4
    assert_select ".component-grid--featured .component-card", 6
    assert_select "pre[data-language='ruby'] code.language-ruby", 1
    assert_not_includes response.body, "From a small tool to a cinematic interface"
    assert_not_includes response.body, "Six components"
    assert_not_includes response.body, "data-command-palette-entries-value"
  end
end
