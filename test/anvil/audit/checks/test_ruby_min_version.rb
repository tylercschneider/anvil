# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "anvil/audit/checks/ruby_min_version"

module Anvil
  class TestRubyMinVersion < Minitest::Test
    def test_passes_when_gemspec_required_ruby_version_matches_standard
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

        result = Audit::Checks::RubyMinVersion.run(dir)

        assert_predicate result, :pass?
      end
    end
  end
end
