# frozen_string_literal: true

require_relative "../../standard"

module Anvil
  module Audit
    module Checks
      class LicensePresent
        Result = Struct.new(:name, :pass) do
          alias_method :pass?, :pass
        end

        def self.run(dir)
          expected = Standard.entries.find { |e| e[:key] == :license }[:value]
          Result.new(:license, File.exist?("#{dir}/#{expected}"))
        end
      end
    end
  end
end
