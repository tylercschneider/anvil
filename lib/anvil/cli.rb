# frozen_string_literal: true

require_relative "audit/runner"
require_relative "audit/reporter"

module Anvil
  class CLI
    def self.run(dir, io)
      results = Audit::Runner.run(dir)
      Audit::Reporter.report(results, io)
      results.all?(&:pass?)
    end
  end
end
