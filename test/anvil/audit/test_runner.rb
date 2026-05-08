# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "anvil/audit/runner"

module Anvil
  class TestRunner < Minitest::Test
    def test_runs_registered_checks_and_returns_their_results
      Dir.mktmpdir do |dir|
        File.write("#{dir}/sample.gemspec", <<~RUBY)
          Gem::Specification.new do |spec|
            spec.name = "sample"
            spec.version = "0.0.1"
            spec.summary = "x"
            spec.authors = ["x"]
            spec.required_ruby_version = ">= 3.2.0"
          end
        RUBY

        results = Audit::Runner.run(dir)

        assert_equal 1, results.length
        assert_predicate results.first, :pass?
      end
    end
  end
end
