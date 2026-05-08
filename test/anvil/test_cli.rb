# frozen_string_literal: true

require "test_helper"
require "stringio"
require "tmpdir"
require "anvil/cli"

module Anvil
  class TestCLI < Minitest::Test
    def test_audits_the_directory_and_writes_a_report_to_io
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
        File.write("#{dir}/LICENSE", "MIT")
        File.write("#{dir}/CHANGELOG.md", "# Changelog")
        io = StringIO.new

        Anvil::CLI.run(dir, io)

        assert_includes io.string, "✓ ruby_min_version"
      end
    end

    def test_returns_true_when_all_checks_pass
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
        File.write("#{dir}/LICENSE", "MIT")
        File.write("#{dir}/CHANGELOG.md", "# Changelog")

        assert_equal true, Anvil::CLI.run(dir, StringIO.new)
      end
    end
  end
end
