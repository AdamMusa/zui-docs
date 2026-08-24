require "test_helper"

class DocumentationSourceTest < ActiveSupport::TestCase
  test "every seeded code block declares matching Lexxy language metadata" do
    source = Rails.root.join("db/seeds.rb").read
    block_tags = source.scan(/<pre\b([^>]*)><code\b([^>]*)>/)

    assert_equal 14, block_tags.length
    assert block_tags.all? { |pre, _code| pre.match?(/data-language="(?:ruby|bash)"/) }
    assert block_tags.all? { |_pre, code| code.match?(/class="language-(?:ruby|bash)"/) }
  end

  test "the syntax controller normalizes legacy blocks and scopes Lexxy highlighting" do
    source = Rails.root.join("app/javascript/controllers/syntax_highlight_controller.js").read

    assert_includes source, "pre.dataset.language"
    assert_includes source, "highlightCode(this.element)"
  end
end
