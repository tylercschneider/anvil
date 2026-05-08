# frozen_string_literal: true

require_relative "checks/ruby_min_version"
require_relative "checks/license_present"
require_relative "checks/changelog_present"

module Anvil
  module Audit
    class Runner
      CHECKS = [Checks::RubyMinVersion, Checks::LicensePresent, Checks::ChangelogPresent].freeze

      def self.run(dir)
        CHECKS.map { |check| check.run(dir) }
      end
    end
  end
end
