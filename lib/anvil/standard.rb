# frozen_string_literal: true

module Anvil
  module Standard
    ENTRIES = [
      {key: :ruby_min_version, value: ">= 3.2.0"},
      {key: :license, value: "LICENSE"},
      {key: :changelog, value: "CHANGELOG.md"}
    ].freeze

    def self.entries
      ENTRIES
    end
  end
end
