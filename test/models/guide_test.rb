require "test_helper"

class GuideTest < ActiveSupport::TestCase
  test "requires a stable URL slug" do
    guide = Guide.new(title: "Draft", summary: "Draft guide", slug: "Not Valid")

    assert_not guide.valid?
    assert guide.errors[:slug].any?
  end

  test "orders guides by position" do
    assert_equal %w[quickstart state-and-bindings], Guide.ordered.pluck(:slug)
  end
end
