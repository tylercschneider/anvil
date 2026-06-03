# frozen_string_literal: true

require "test_helper"
require "anvil/reference"

module Anvil
  class ReferenceTest < Minitest::Test
    def test_content_documents_running_the_audit
      assert_includes Anvil::Reference.content, "bundle exec anvil"
    end
  end
end
