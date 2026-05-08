# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "anvil/audit/checks/license_present"

module Anvil
  class TestLicensePresent < Minitest::Test
    def test_passes_when_a_license_file_is_present_at_root
      Dir.mktmpdir do |dir|
        File.write("#{dir}/LICENSE", "MIT")

        result = Audit::Checks::LicensePresent.run(dir)

        assert_predicate result, :pass?
        assert_equal :license, result.name
      end
    end
  end
end
