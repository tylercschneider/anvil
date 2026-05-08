# frozen_string_literal: true

require_relative "../../standard"

module Anvil
  module Audit
    module Checks
      class RubyMinVersion
        Result = Struct.new(:name, :pass) do
          alias_method :pass?, :pass
        end

        def self.run(dir)
          gemspec_path = Dir["#{dir}/*.gemspec"].first
          return Result.new(:ruby_min_version, false) unless gemspec_path

          spec = Gem::Specification.load(gemspec_path)
          expected = Standard.entries.find { |e| e[:key] == :ruby_min_version }[:value]

          Result.new(:ruby_min_version, spec.required_ruby_version.to_s == expected)
        end
      end
    end
  end
end
