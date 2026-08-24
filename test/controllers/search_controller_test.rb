require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "returns compact server-side search results" do
    get search_path(format: :json), params: { q: "cell click" }

    assert_response :success
    results = response.parsed_body
    assert_operator results.length, :<=, 12
    assert results.any? { |entry| entry.fetch("label") == "Table View" }
    assert results.all? { |entry| entry.keys.sort == %w[label meta path] }
  end

  test "searches guides without embedding the catalog in page markup" do
    get search_path(format: :json), params: { q: "quickstart" }

    assert_response :success
    assert_equal "Guide", response.parsed_body.first.fetch("meta")
  end
end
