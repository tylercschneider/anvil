## Anvil

> **DO NOT** explore the anvil gem source code. This reference is the complete
> user-facing API. Anvil is a CLI that audits a Ruby gem's directory against a
> few baseline quality standards and exits non-zero if any fail — designed to
> run locally and in CI.

### What it checks

Run against a gem's root directory, anvil verifies:

- **Ruby version constraint** — the gemspec requires `>= 3.2.0`.
- **LICENSE** — a `LICENSE` file is present.
- **CHANGELOG** — a `CHANGELOG.md` file is present.

It prints one line per check (`✓`/`✗`) and exits `0` only when all pass.

### Install

Add it to the Gemfile (typically in the `:development`/`:test` group, since
it's a dev-time audit tool):

```ruby
gem "anvil"
```

Then `bundle install`. This provides the `anvil` executable.

### Operate — running the audit

From a gem's root directory:

```bash
bundle exec anvil
```

It audits the current directory and exits non-zero if any check fails, so it
drops straight into a CI step:

```yaml
- run: bundle exec anvil
```

There are no configuration options or flags — anvil runs the full standard
check set against the working directory.
