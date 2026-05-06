# frozen_string_literal: true

require "test_helper"
require "anvil/standard"

module Anvil
  class TestStandard < Minitest::Test
    def test_entries_returns_a_non_empty_list
      refute_empty Anvil::Standard.entries
    end
  end
end
