# frozen_string_literal: true

require "components/test_helper"

class PrimerAlphaStackTest < Minitest::Test
  include Primer::ComponentTestHelpers

  def test_renders
    render_inline(Primer::Stack.new)

    assert_text("Add a test here")
  end
end