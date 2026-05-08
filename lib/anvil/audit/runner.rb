# frozen_string_literal: true

require_relative "checks/ruby_min_version"

module Anvil
  module Audit
    class Runner
      CHECKS = [Checks::RubyMinVersion].freeze

      def self.run(dir)
        CHECKS.map { |check| check.run(dir) }
      end
    end
  end
end
