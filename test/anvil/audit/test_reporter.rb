# frozen_string_literal: true

require "test_helper"
require "stringio"
require "anvil/audit/reporter"

module Anvil
  class TestReporter < Minitest::Test
    Result = Struct.new(:name, :pass) do
      alias_method :pass?, :pass
    end

    def test_prints_check_name_with_pass_or_fail_marker
      io = StringIO.new

      Audit::Reporter.report(
        [Result.new(:ruby_min_version, true), Result.new(:ruby_min_version, false)],
        io
      )

      assert_equal "✓ ruby_min_version\n✗ ruby_min_version\n", io.string
    end
  end
end
