require "test_helper"

class GuidesControllerTest < ActionDispatch::IntegrationTest
  test "renders an Action Text-backed guide" do
    guides(:quickstart).update!(body: <<~HTML)
      <h2>Start here</h2>
      <p>Install Zui.</p>
      <pre data-language="bash"><code class="language-bash">gem install zui</code></pre>
    HTML

    get guide_path("quickstart")

    assert_response :success
    assert_select "h1", "Quickstart"
    assert_select ".lexxy-content h2", "Start here"
    assert_select ".guide-content[data-controller~='syntax-highlight'] pre[data-language='bash'] code.language-bash", 1
  end
end
