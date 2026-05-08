# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "anvil/audit/checks/changelog_present"

module Anvil
  class TestChangelogPresent < Minitest::Test
    def test_passes_when_a_changelog_file_is_present_at_root
      Dir.mktmpdir do |dir|
        File.write("#{dir}/CHANGELOG.md", "# Changelog")

        result = Audit::Checks::ChangelogPresent.run(dir)

        assert_predicate result, :pass?
        assert_equal :changelog, result.name
      end
    end
  end
end
