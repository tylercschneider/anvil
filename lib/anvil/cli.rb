# frozen_string_literal: true

require_relative "audit/runner"
require_relative "audit/reporter"

module Anvil
  class CLI
    def self.run(dir, io)
      Audit::Reporter.report(Audit::Runner.run(dir), io)
    end
  end
end
