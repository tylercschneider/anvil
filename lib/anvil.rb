# frozen_string_literal: true

require_relative "anvil/version"
require_relative "anvil/reference"

module Anvil
  class Error < StandardError; end
end

# Register anvil's locals when the_local is available (no-op otherwise).
require_relative "anvil/the_local"
