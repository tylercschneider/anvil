# frozen_string_literal: true

require "test_helper"
require "the_local"
require "anvil/the_local"

module Anvil
  class CompanionTest < Minitest::Test
    def setup
      TheLocal.reset!
      Anvil::Companion.register!
    end

    def test_registers_a_local_per_facet
      assert_equal ["anvil-info", "anvil-install", "anvil-operate"],
        TheLocal.registry.agents.map(&:qualified_name)
    end

    def test_each_local_embeds_the_reference
      assert(TheLocal.registry.agents.all? { |a| a.to_markdown.include?(Anvil::Reference.content) })
    end
  end
end
