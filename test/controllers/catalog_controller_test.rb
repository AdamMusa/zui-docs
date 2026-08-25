require "test_helper"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  test "lists every component from the synced registry" do
    get components_path

    assert_response :success
    assert_select ".component-grid[data-catalog-target='grid'] > .component-card", 241
    assert_select ".component-card__visual", 241
    assert_select "[data-catalog-target='category']", 13
    assert_select ".catalog-page[data-controller='catalog']", 1
    assert_select ".catalog-page[data-controller~='reveal']", 0
    assert_select ".catalog-hero[data-controller~='reveal']", 1
    assert_select "h1", text: /Component/
  end

  test "shows component API, events, and the complete source-backed example" do
    get component_path("button")

    assert_response :success
    assert_select "h1", "Button"
    assert_select "#properties code", text: "text"
    assert_select "#events code", text: "click"
    assert_select ".code-panel", text: /button\("Deploy"/
    assert_select ".code-panel pre[data-language='ruby'] code.language-ruby", 1
    assert_select ".preview-lab", 0
    assert_select "#related", 0
  end

  test "supports underscore component identifiers" do
    get component_path("model_view_3d")

    assert_response :success
    assert_select "h1", "Model View 3D"
    assert_select ".component-header__badges", text: /Native Qt/
  end

  test "uses direct builder examples for table and path animation" do
    get component_path("table_view")
    assert_select ".code-panel", text: /table = table_view rows, columns: columns/
    assert_select ".code-panel", text: /on table, :cell_click/

    get component_path("path_animation")
    assert_select ".code-panel", text: /motion = path_animation dot/
    assert_select ".code-panel", text: /path: "M 20 120 C 120 10, 240 230, 360 120"/
  end
end
