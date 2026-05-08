# frozen_string_literal: true

require "test_helper"
require "anvil/standard"

module Anvil
  class TestStandard < Minitest::Test
    def test_entries_returns_a_non_empty_list
      refute_empty Anvil::Standard.entries
    end

    def test_includes_a_license_entry_naming_the_expected_file
      license_entry = Anvil::Standard.entries.find { |e| e[:key] == :license }

      assert_equal "LICENSE", license_entry[:value]
    end
  end
end
