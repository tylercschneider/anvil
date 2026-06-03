# frozen_string_literal: true

require_relative "reference"

module Anvil
  # Registers anvil's locals (Claude Code subagents) with the_local. anvil is a
  # CLI tool, so its lifecycle facets are info / install / operate. Soft
  # dependency: registration is a no-op when the_local is absent.
  module Companion
    def self.register!
      TheLocal.register("anvil", scope: "auditing a gem's baseline quality — Ruby version, LICENSE, CHANGELOG") do |c|
        c.agent "info",
          description: "Use to learn what anvil offers — what it checks and how to run it.",
          tools: "Read",
          body: "You explain what anvil does: it audits a gem directory for baseline quality and " \
                "exits non-zero if any check fails. Answer from the reference; make no changes.",
          knowledge: Anvil::Reference.content

        c.agent "install",
          description: "Use to add anvil to a project (Gemfile, bundle).",
          tools: "Bash, Read, Edit",
          body: "You add anvil to the project's Gemfile (dev/test group) and run bundle install, " \
                "following the reference.",
          knowledge: Anvil::Reference.content

        c.agent "operate",
          description: "Use PROACTIVELY to run anvil's audit and act on the results — including " \
                       "wiring it into CI.",
          tools: "Bash, Read",
          body: "You run `bundle exec anvil` in the gem root, interpret the ✓/✗ output, and help " \
                "fix failures or add anvil to CI, following the reference.",
          knowledge: Anvil::Reference.content
      end
    end
  end
end

begin
  require "the_local"
  Anvil::Companion.register!
rescue LoadError
  # the_local not installed — anvil works standalone.
end
