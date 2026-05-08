# frozen_string_literal: true

require "test_helper"
require "stringio"
require "anvil/audit/reporter"

module Anvil
  class TestReporter < Minitest::Test
    Result = Struct.new(:pass) do
      alias_method :pass?, :pass
    end

    def test_prints_a_check_mark_for_passing_results_and_a_cross_for_failures
      io = StringIO.new

      Audit::Reporter.report([Result.new(true), Result.new(false)], io)

      assert_equal "✓\n✗\n", io.string
    end
  end
end
