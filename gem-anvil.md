# Anvil — Gem Production Framework

**Type:** Ruby Gem (CLI + generators)
**Repo:** `~/projects/gems/anvil` (not created yet)
**Status:** Spec phase
**Tagline:** "Forge gems on a single anvil. One way. The right way."

---

## Why this exists

Two reasons:

1. **Consistency over ad-hoc generation.** Every gem should start at the same baseline and stay there. Decisions are made once, encoded in the tool, and applied identically — so the next gem isn't re-decided by a developer (or an agent) from scratch.
2. **The audit (`apps-and-gems-audit.md`) shows 15 gems with diverging conventions:**
   - **Test framework:** Minitest in `event_engine`, `herald`, `ask_first` — RSpec in `keystone_ui` — none in `till`.
   - **CI:** Some have `.github/workflows/ci.yml`, most don't.
   - **Docs:** `keystone_ui` has README + ROADMAP + PLAN + CHANGELOG + CONTRIBUTING + CODE_OF_CONDUCT. `till` has the default plugin README. Most are somewhere in between.
   - **Gemspec metadata:** `event_engine` declares `allowed_push_host`, `source_code_uri`, `changelog_uri`, `bug_tracker_uri`, `documentation_uri`. `keystone_ui` declares only `source_code_uri`.
   - **Skeletons that never grew:** `till`, `metric_planner`, `ai_ui` sit at 1–3 commits with TODO gemspecs and default READMEs.

Anvil exists so the next gem starts at the same baseline as `event_engine` (the most mature) — not as `till` (the skeleton) — and so existing gems can be brought up to that baseline without bespoke per-gem work.

## Goals

- `anvil new <name>` produces a gem that is publishable to RubyGems.org on day one — gemspec valid, CI green, test suite running, README populated, generator stubbed.
- `anvil audit` runs against any gem and reports the gap between the gem and the standard. Exit code is non-zero if the gem fails the standard.
- `anvil upgrade` brings an existing gem closer to the standard non-destructively (adds missing files, never overwrites without `--force`).
- The standard is **opinionated** — Anvil makes one choice per axis. No `--rspec` flag. No `--no-ci` flag. If you want different choices, fork Anvil.

## Non-goals

- Generic gem generation (use `bundle gem` for that).
- Replacing `rails plugin new` for the Rails-engine boilerplate. Anvil runs `rails plugin new --mountable` or `bundle gem` under the hood, then layers the standard on top.
- Building gems that aren't Ruby. Rails engines and pure-Ruby libraries only.

---

## The standard (locked choices)

Each row is a fixed decision. Anvil enforces it; deviating means failing `anvil audit`.

| Area | Decision | Rationale |
|---|---|---|
| Ruby min version | `>= 3.2.0` | Matches `event_engine`. Drops 3.0/3.1 quirks. |
| Rails min version | `>= 7.1`, `< 9` (engines) | Matches Jumpstart-app baseline. |
| Test framework | **Minitest** | Rails default; `event_engine`, `herald`, `ask_first` already use it. RSpec gets converted on `anvil upgrade`. |
| Test layout | `test/` with `test/dummy` Rails app for engines | Standard `rails plugin new --mountable` layout. |
| Linter | **standardrb** | Zero config, no bikeshedding. |
| CI | **GitHub Actions** at `.github/workflows/ci.yml` | Runs lint + tests on min Ruby + min Rails. |
| License | MIT, file `LICENSE` | Matches every existing gem. |
| Versioning | SemVer; `lib/<gem>/version.rb` | Standard. |
| Changelog | `CHANGELOG.md`, [Keep a Changelog](https://keepachangelog.com/) format | `event_engine` and `herald` already use this. |
| README sections | Fixed order (see "README contract") | No more "default plugin README" gems. |
| Gemspec metadata | All five URIs required (see "Gemspec contract") | RubyGems.org lists them. |
| Engine namespace | `isolate_namespace` always | Prevents host-app collisions. |
| Table prefix | `<gem_name>_<table>` (e.g., `till_orders`) | No autoload-confusing un-prefixed tables. |
| Migration generator | `<gem>:install` copies migrations into host | Host owns its own `db/migrate/`. |
| Configuration DSL | `Gem.configure { \|c\| ... }` block | Matches `launch_checklist`, `till`, `event_engine`. |
| Initializer template | Generator-installed at `config/initializers/<gem>.rb` | Host owns its config. Gem never auto-configures. |
| Routes mounting | Host mounts; gem documents the line | Gem never auto-mounts. |
| Route helpers | `main_app.` in every shared partial that ships with the gem | Host route helpers must be explicit when partials render inside a mounted engine. |
| ViewComponents | Required for any UI surface | `keystone_ui` is the standard. No ERB partials for shipped UI. |
| CSS/JS shipping | None. Tailwind utilities only. No `app/assets/stylesheets`. | Avoids the asset-pipeline rabbit hole; matches `keystone_ui`. |
| Documentation | README + (optional) `docs/` folder. No YARD. | Keep maintenance load low. |
| Release flow | `bundle exec rake release` after `CHANGELOG.md` updated | Bundler default. Anvil adds a guard that fails release if CHANGELOG has no entry for current version. |

**Anvil refuses to scaffold a gem that doesn't follow these.** No flags. If you want RSpec, you don't want Anvil.

---

## Architecture

```
anvil/
├── exe/anvil                          # CLI entry point (Thor)
├── lib/anvil/
│   ├── version.rb
│   ├── cli.rb                         # Thor commands: new, audit, upgrade, release-check
│   ├── standard.rb                    # The locked decisions, as data
│   ├── scaffold/
│   │   ├── engine.rb                  # Mountable Rails engine path
│   │   ├── library.rb                 # Pure-Ruby library path
│   │   └── shared.rb                  # README, LICENSE, CHANGELOG, CI, .standard.yml
│   ├── audit/
│   │   ├── runner.rb
│   │   └── checks/
│   │       ├── gemspec_metadata.rb
│   │       ├── readme_sections.rb
│   │       ├── changelog_format.rb
│   │       ├── test_framework.rb
│   │       ├── ci_present.rb
│   │       ├── linter_present.rb
│   │       ├── isolate_namespace.rb
│   │       ├── table_prefix.rb
│   │       ├── main_app_prefix.rb     # Greps shared partials for missing main_app.
│   │       ├── install_generator.rb
│   │       └── ruby_rails_versions.rb
│   ├── upgrade/                       # Idempotent upgraders mirroring each check
│   └── templates/                     # ERB stubs for every file Anvil writes
└── test/
```

## CLI surface

```bash
# Scaffold a new gem
anvil new till --kind=engine --summary="Checkout flow engine" --author=tyler
anvil new metric_planner --kind=library --summary="Declarative metric request planner"

# Audit an existing gem against the standard
cd ~/projects/gems/event_engine && anvil audit
# → prints a per-check report, exit 0 if all pass

# Upgrade an existing gem toward the standard
cd ~/projects/gems/till && anvil upgrade --dry-run
cd ~/projects/gems/till && anvil upgrade

# Pre-release guardrail
cd ~/projects/gems/herald && anvil release-check
# → verifies CHANGELOG has [version], git is clean, version.rb matches, CI is green
```

`--kind=engine` produces a mountable Rails engine. `--kind=library` produces a pure-Ruby gem (no `app/`, no `config/`, no `db/`). Anvil refuses other values.

---

## What `anvil new <name> --kind=engine` produces

```
till/
├── .github/workflows/ci.yml           # standardrb + minitest, min Ruby + min Rails
├── .gitignore                         # Anvil-curated, includes test/dummy/log, tmp/, *.gem
├── .ruby-version                      # 3.2.x (the min)
├── .standard.yml                      # Pinned standardrb config
├── CHANGELOG.md                       # "## [Unreleased]"
├── CODE_OF_CONDUCT.md                 # Contributor Covenant 2.1
├── CONTRIBUTING.md                    # Standard: PR flow, TDD, one test per commit
├── Gemfile
├── LICENSE                            # MIT, copyright = author
├── README.md                          # Populated per "README contract" below
├── Rakefile                           # Default test + release tasks
├── till.gemspec                       # Populated per "Gemspec contract" below
├── lib/
│   ├── till.rb                        # require "till/engine"; Till.configure block defined
│   ├── till/
│   │   ├── version.rb                 # VERSION = "0.0.1"
│   │   ├── engine.rb                  # isolate_namespace Till
│   │   └── configuration.rb           # Block DSL with documented options
│   └── generators/till/
│       └── install/
│           ├── install_generator.rb   # rails g till:install
│           └── templates/
│               ├── initializer.rb     # Till.configure { |c| ... } stub
│               └── README             # Post-install instructions printed by generator
├── app/
│   ├── controllers/till/application_controller.rb
│   ├── models/till/application_record.rb
│   └── views/till/                    # Empty — components live elsewhere
├── config/routes.rb                   # Till::Engine.routes.draw do … end
├── db/migrate/                        # Empty until the gem author adds models
└── test/
    ├── test_helper.rb                 # Loads test/dummy
    ├── till_test.rb                   # One test: VERSION exists
    ├── dummy/                         # Generated Rails app for integration tests
    └── fixtures/
```

`--kind=library` strips `app/`, `config/`, `db/`, the engine entry point, and the install-generator templates that touch routes.

---

## README contract

Every gem README has these H2 sections in this order. `anvil audit` greps for the headings:

1. `## What it is` — one paragraph.
2. `## Installation` — bundler line, install generator command, mount line if engine.
3. `## Usage` — the smallest end-to-end example.
4. `## Configuration` — every config option, default, and what it does.
5. `## Integration` — how to consume from a host Rails app. SCRIPT_NAME notes if applicable. ViewComponent override paths if applicable.
6. `## Compatibility` — Ruby + Rails versions tested.
7. `## Versioning` — "SemVer. See CHANGELOG.md."
8. `## License` — MIT.

The audit fails if any heading is missing.

## Gemspec contract

Every gemspec must declare:

```ruby
spec.required_ruby_version = ">= 3.2.0"
spec.metadata = {
  "allowed_push_host"  => "https://rubygems.org",
  "source_code_uri"    => "https://github.com/tylercschneider/<gem>",
  "homepage_uri"       => spec.homepage,
  "changelog_uri"      => "https://github.com/tylercschneider/<gem>/blob/main/CHANGELOG.md",
  "bug_tracker_uri"    => "https://github.com/tylercschneider/<gem>/issues",
  "documentation_uri"  => "https://github.com/tylercschneider/<gem>#readme",
  "rubygems_mfa_required" => "true"
}
spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
```

`event_engine.gemspec` is the reference. `keystone_ui.gemspec` currently fails this contract — `anvil upgrade` would fix it.

## Configuration DSL contract

Every gem (engine or library) exposes a single configuration entry point:

```ruby
# lib/<gem>.rb
module Till
  class << self
    attr_writer :configuration
    def configuration; @configuration ||= Configuration.new; end
    def configure; yield(configuration); end
    def reset!; @configuration = Configuration.new; end
  end
end
```

`Till::Configuration` documents every option in code with `attr_accessor` + a comment. The install generator's `initializer.rb` template includes every option commented-out with its default. No "magic" defaults read from `Rails.application.config` without an explicit option.

## Integration safety contract

These patterns are mandatory because they're standard Rails-engine integration concerns that quietly break when omitted:

1. **Engines never auto-mount.** The host's `config/routes.rb` mounts the engine. Anvil's install-generator README prints the exact line.
2. **Shared partials shipped by the gem use `main_app.` for any host route.** `anvil audit` greps `app/views/<gem>/**/_*.{html.erb,html.slim}` for bare `_path` / `_url` calls and warns.
3. **`as:` on mount lines is forbidden in docs.** `as: :app_colors` broke `keystone_colors.` route proxy in WYN. The README's mount example never includes `as:`.
4. **Tables are prefixed.** Migrations created via `<gem>:install` copy with `till_*` names. Audit fails on `create_table :orders` inside a gem's `db/migrate/`.
5. **Models extend `<Gem>::ApplicationRecord`**, never `ActiveRecord::Base` directly.
6. **Initializers are host-installed, not bundled.** Gem code reads from `Gem.configuration`, not from `ENV` or files at boot, so a missing initializer fails loudly with `Till::Configuration::Missing` rather than silently using a default.
7. **No `require` of optional dependencies at load time.** Use `defined?(Constant)` checks. `keystone_ui`-dependent code in `dash_kit` should not crash when keystone_ui isn't installed.
8. **Rake tasks namespaced under `<gem>:`** — never pollute the host's `rake -T`.

`anvil audit` runs a check for each.

---

## `anvil audit` output (sample)

```
$ cd ~/projects/gems/till && anvil audit

till — Anvil standard audit

  ✓ ruby version             >= 3.2.0
  ✗ gemspec metadata         missing: allowed_push_host, changelog_uri, bug_tracker_uri,
                              documentation_uri, rubygems_mfa_required
  ✗ readme sections          missing: Configuration, Integration, Compatibility, Versioning
  ✗ changelog format         CHANGELOG.md not present
  ✓ test framework           minitest
  ✗ ci present               .github/workflows/ci.yml not present
  ✓ linter present           .standard.yml found
  ✓ isolate namespace        engine.rb declares isolate_namespace
  ✓ table prefix             no migrations to check
  ✓ main_app prefix          no shared partials to check
  ✗ install generator        lib/generators/till/install missing

8 / 13 passing. Exit 1.

Run `anvil upgrade` to fix the auto-fixable items
(7 of the 5 failing — readme sections need manual content).
```

Audit checks are pure functions over the filesystem. CI in each gem can run `bundle exec anvil audit` as one of its steps.

---

## Bootstrap plan

The dependency graph snapshot in `infrastructure-ideas/dependency-graph.md` decides upgrade order. Touching foundational gems first (`keystone_ui`, then its consumers) prevents re-work.

### Phase 1 — Anvil v0.1: scaffolding only

1. `anvil new <name> --kind=engine|library`
2. Templates for every file in the standard layout
3. Minitest + dummy app generated and green
4. CI workflow committed; gem passes its own audit
5. Self-host: Anvil scaffolds itself

### Phase 2 — Audit

6. `anvil audit` runs the 13 checks above
7. JSON output mode for machine consumption (e.g., command_center health rollup)
8. Exit codes; CI integration documented

### Phase 3 — Upgrade

9. `anvil upgrade --dry-run` shows planned diff
10. `anvil upgrade` applies idempotent fixes (gemspec metadata, missing files, CI, .standard.yml)
11. Run `anvil upgrade` against every gem in the audit and PR the result one gem at a time

### Phase 4 — Release guardrail

12. `anvil release-check`: clean git, version.rb matches CHANGELOG `[Unreleased]` promoted to `[<version>]`, CI green
13. `anvil release` wraps `rake release` with the guardrail

### Phase 5 — Cohesion with launch_checklist

14. Anvil's audit results POST to a launch_checklist heartbeat (`gem_audit_clean:<name>`) so a regressed gem shows red on the cross-app dashboard

---

## Open questions

- **Existing gems' test frameworks.** `keystone_ui` uses RSpec. Convert it, or grandfather it and add a per-gem opt-out? Lean: convert. The point of Anvil is no opt-outs.
- **Asset shipping for non-`keystone_ui` UI gems.** `marquee` ships ERB templates the host overrides. Should Anvil enforce ViewComponents there too, or accept ERB-as-template for "page framework" gems? Lean: ERB allowed only for host-overridable templates, never for component-style UI.
- **Where Anvil itself lives.** Adding `~/projects/gems/anvil` to a tree that already has 15 gems — keep, or put in `~/projects/tools/anvil`? Lean: gems dir; it ships to RubyGems.
- **Self-audit drift.** Anvil's standard will evolve. Need a `STANDARD_VERSION` constant that gems can pin so the CI doesn't break overnight when a new check lands.

## Success criteria

- `anvil new fine_print_v2 --kind=engine` produces a gem with green CI on first push.
- `anvil audit` against `event_engine` passes 13/13 (it's the reference; if it fails, fix the standard or the gem).
- `anvil audit` against `till` reports the skeleton state; `anvil upgrade` brings till to 12/13 (the missing one being README content, which needs human writing).
- After applying `anvil upgrade` across all 15 gems in the audit, all of them publish to RubyGems.org with consistent metadata.
- Onboarding a new gem from idea → scaffold → first commit → first release takes under 30 minutes.
