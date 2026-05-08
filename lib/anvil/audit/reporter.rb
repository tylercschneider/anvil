# frozen_string_literal: true

module Anvil
  module Audit
    class Reporter
      def self.report(results, io)
        results.each do |result|
          io.puts(result.pass? ? "✓" : "✗")
        end
      end
    end
  end
end
