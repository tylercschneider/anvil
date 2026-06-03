# Anvil

Anvil is a small CLI that audits a Ruby gem's directory against baseline quality
standards and exits non-zero if any fail — built to run locally and in CI.

## What it checks

Run against a gem's root directory, anvil verifies:

- **Ruby version constraint** — the gemspec requires `>= 3.2.0`.
- **LICENSE** — a `LICENSE` file is present.
- **CHANGELOG** — a `CHANGELOG.md` file is present.

It prints one line per check (`✓`/`✗`) and exits `0` only when all pass.

## Installation

Add anvil to your Gemfile, typically in the development/test group since it's a
dev-time audit tool:

```ruby
gem "anvil", group: %i[development test]
```

Then `bundle install`. This provides the `anvil` executable.

## Usage

From a gem's root directory:

```bash
bundle exec anvil
```

It audits the current directory and exits non-zero if any check fails, so it
drops straight into a CI step:

```yaml
- run: bundle exec anvil
```

There are no configuration options or flags — anvil runs the full standard check
set against the working directory.

## the_local companion

When [`the_local`](https://github.com/tylercschneider/the_local) is installed in
your app, anvil registers expert subagents (`anvil-info`, `anvil-install`,
`anvil-operate`) that your AI agent can delegate to. anvil works fine without it.

## Development

After checking out the repo, run `bin/setup` to install dependencies, then
`rake` to run the tests and linter (`standardrb`). For an interactive prompt,
run `bin/console`.

## Contributing

Bug reports and pull requests are welcome at
https://github.com/tylercschneider/anvil.

## License

Released under the [MIT License](LICENSE).
