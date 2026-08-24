require "test_helper"

class ZuiCatalogTest < ActiveSupport::TestCase
  test "contains every registered Zui component exactly once" do
    assert_equal 241, ZuiCatalog.components.length
    assert_equal 241, ZuiCatalog.components.map { _1.fetch("slug") }.uniq.length
    assert_equal 241, ZuiCatalog.categories.sum { _1.fetch("count") }
  end

  test "preserves the source registry contract" do
    button = ZuiCatalog.find!("button")

    assert_equal "Button.qml", button.fetch("qml")
    assert_includes button.fetch("specific_properties"), "text"
    assert_includes button.fetch("events"), "click"
    assert_match "514bd4a", ZuiCatalog.metadata.fetch("source_revision")
  end

  test "all components have documentation metadata" do
    ZuiCatalog.components.each do |component|
      assert component.fetch("description").present?, component.fetch("slug")
      assert component.fetch("example").present?, component.fetch("slug")
      assert component.fetch("category").present?, component.fetch("slug")
      assert_no_match(/\bcomponent\s+:/, component.fetch("example"), component.fetch("slug"))
      assert_no_match(/\bstate\./, component.fetch("example"), component.fetch("slug"))
    end
  end

  test "publishes complete direct builder examples for complex components" do
    table = ZuiCatalog.find!("table_view").fetch("example")
    path_animation = ZuiCatalog.find!("path_animation").fetch("example")

    assert_includes table, "table_view rows, columns: columns"
    assert_includes table, "on table, :cell_click"
    assert_includes path_animation, "path_animation dot"
    assert_includes path_animation, "path: \"M 20 120"
  end
end
