# Design: basalt_dart-style documentation for analytics_hub

**Date:** 2026-08-05
**Status:** Approved

## Context

`analytics_hub` currently has functional but flat READMEs (English + Ukrainian, per
package) with no badges, no "what's inside" reference table, no `doc/` deep-dive
guides, and no root `CONTRIBUTING.md`. The user wants documentation that follows
the same structural patterns as `basalt_dart` (a sibling Dart monorepo the user
maintains), scaled down to this repo's size (4 small packages vs. basalt's 7 larger
ones).

Reference material: `/Users/genius/Development/basalt_dart/README.md`,
`packages/basalt/README.md`, `packages/basalt/doc/*.md`, `CONTRIBUTING.md`.

## Goals

1. Badges + a "part of workspace" cross-link banner on every README.
2. A "What's inside" reference table in the core (`analytics_hub`) README only.
3. A `packages/analytics_hub/doc/` folder with four guides, linked from the core
   README's new "Reference" section — mirroring basalt's pattern of a compact
   README example plus an outbound link for the deep dive.
4. A root `CONTRIBUTING.md` for people extending the workspace itself.

## Non-goals

- No `doc/` folders in the provider packages (firebase/mixpanel/appsflyer) — each
  has 2-3 classes and the README already covers them fully.
- No "what's inside" tables in provider packages — same reasoning.
- No CI documentation beyond what already exists as comments in
  `.github/workflows/*.yml`.
- No changes to the Ukrainian READMEs' structure beyond mirroring badge/banner
  additions made to the English ones (content stays English-only for `doc/` and
  `CONTRIBUTING.md`, consistent with basalt_dart, which does not localize its
  `doc/` guides either).

## Design

### 1. Badges + workspace banner

**Root `README.md`**: add a badge row above the existing intro, styled after
basalt's root README:

```markdown
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-brightgreen)
![Style](https://img.shields.io/badge/style-lints-brightgreen)
```

**Each package README** (`analytics_hub`, `analytics_hub_firebase`,
`analytics_hub_mixpanel`, `analytics_hub_appsflyer`), English version only: add a
badge row + a banner note, styled after `packages/basalt/README.md`:

```markdown
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

> Part of the analytics_hub workspace. New here? Start with the
> [root README](../../README.md).
```

The core package keeps its existing pub-version badge (already present) in
addition to the new ones. Provider packages do **not** get a pub-version badge —
they aren't published yet, so a version badge would either 404 or lie.

### 2. "What's inside" table (core only)

Insert into `packages/analytics_hub/README.md`, between "Features" and
"Installation":

```markdown
## What's inside

| Area | Types | Source |
|---|---|---|
| **Hub** | `AnalyticsHub` | `analytics_hub.dart` |
| **Events** | `Event`, `LogEvent`, `EventProvider`, `EventOverrides` | `event/events/events.dart` |
| **Providers** | `AnalyticsProvider`, `ProviderIdentifier`, `EventResolver` | `provider/`, `event/event_resolver.dart` |
| **Interceptors** | `EventInterceptor`, `InterceptorResult`, `NextEventInterceptor` | `core/interception/interceptor/` |
| **Context** | `Context`, `EventContext`, `ContextEntry`, `EventDispatchContext`, `ResolvedEvent` | `core/interception/context/` |
| **Dispatch pipeline** | `EventDispatcher`, `DispatchTarget`, `EventDispatchContextBuilder`, `InterceptorChainExecutor`, `EventOverridesApplier`, `CorrelationIdGenerator` | `core/interception/dispatch/` |
```

Source paths are relative to `lib/src/`.

### 3. `packages/analytics_hub/doc/`

Four new files, matching basalt's tone: short, code-example-driven, no fluff.

- **`doc/getting_started.md`** (~40 lines). Install snippet + one event sent
  end-to-end (hub creation → `initialize()` → `sendEvent()`). Condenses the
  current README "Installation" + opening of "Event model" into a single
  walkthrough. Ends with a "Where to go next" list pointing at the other three
  guides (mirrors basalt's `getting_started.md` ending).

- **`doc/providers.md`** (~90 lines). **Moves** the README's current
  "Implementing your own provider (step‑by‑step)" and "When to create your own
  provider" sections here verbatim (with light editing for standalone context).
  This is currently the single largest README section (~100 lines) and is exactly
  the kind of "deep dive" basalt pushes into `doc/`.

- **`doc/interceptors_and_context.md`** (~70 lines). Expands the README's current
  short "Interceptors" example with: the interceptor chain execution order
  (hub interceptors → provider interceptors → resolver), what `EventDispatchContext`
  exposes (`correlationId`, `originalEvent`, `providerIdentifier`), and how
  `EventContext`/`ContextEntry` carry typed metadata from the event through to
  resolvers. Reuses the existing `PrefixInterceptor` example from the README as
  the entry point, then goes deeper.

- **`doc/testing.md`** (~50 lines, new content — no direct README equivalent).
  Shows how a consumer tests code that uses `AnalyticsHub`: a minimal fake
  `AnalyticsProvider` + `EventResolver` that records `ResolvedEvent`s (pattern
  lifted from `packages/analytics_hub/test/src/analytics_hub_test.dart`'s
  `TestProvider`/`TestEventResolver`), and asserting on `sendEvent` results.

**README changes accompanying this:**
- The "Implementing your own provider (step‑by‑step)" and "When to create your
  own provider" sections are deleted from the README and replaced with one short
  example provider class + a link: `See [doc/providers.md](doc/providers.md) for
  the full walkthrough.`
- The "Interceptors" section keeps its existing short `PrefixInterceptor` example
  but adds a link to `doc/interceptors_and_context.md`.
- The README's existing `## More information` section (currently: a link to
  `example/main.dart` and a note about sibling provider packages) is renamed to
  `## Reference` and extended with links to all four `doc/` files — matching
  basalt's package README section of the same name, rather than adding a
  second, overlapping section.
- The README's Table of Contents (if/where one exists inline via headers) is not
  a separate maintained ToC in this package today — no ToC to update.

### 4. Root `CONTRIBUTING.md`

New file at the repo root, adapted from `basalt_dart/CONTRIBUTING.md`'s structure,
trimmed to what applies here (no Docker, no separate DevTools Flutter app):

```markdown
# Contributing to analytics_hub

## Contents
- Prerequisites
- Getting the code
- Repository layout
- Everyday commands
- Architecture at a glance
- Extending the project
- Coding conventions
- Tests
- Commits & pull requests
```

Content per section:

- **Prerequisites** — Dart SDK `>=3.5.0 <4.0.0`; Flutter (stable) needed because
  the provider packages' tests depend on `flutter_test` (mocking Flutter-plugin
  SDKs) even though the core package is pure Dart.
- **Getting the code** — this is a Dart pub workspace; one `flutter pub get` at
  the root resolves everything (core is pure Dart but pinned into the same
  workspace as the Flutter-dependent provider packages, so `flutter pub get` is
  the one command that always works; plain `dart pub get` also works for
  core-only work).
- **Repository layout** — point at the packages table in the root README; note
  core has no provider-SDK dependency, providers depend on it.
- **Everyday commands** — `dart analyze packages`, `dart format packages`,
  per-package `dart test` (core) / `flutter test` (providers), `dart pub publish
  --dry-run` per package.
- **Architecture at a glance** — the dispatch pipeline in one paragraph:
  overrides → hub interceptors → provider interceptors → resolver, each event/
  provider pair building its own `EventDispatchContext`; link to
  `doc/interceptors_and_context.md` for the deep dive.
- **Extending the project** — "New provider: implement `AnalyticsProvider` +
  `EventResolver` in a new `analytics_hub_<backend>` package depending on core;
  see [doc/providers.md](packages/analytics_hub/doc/providers.md)."
- **Coding conventions** — the linter rules already enforced via
  `analysis_options.yaml` worth calling out explicitly: `sort_constructors_first`,
  `public_member_api_docs`, `prefer_final_locals`; and the 0.5.0 decision to keep
  the hub session-agnostic (no `Session`/`HubSessionDelegate` — apps manage
  identity directly on the underlying SDK).
- **Tests** — where things are tested (core dispatch pipeline in
  `packages/analytics_hub/test/`, each provider's resolver/provider tests in its
  own `test/`).
- **Commits & pull requests** — branch off `main`; run `dart analyze packages`
  and the relevant test suites before pushing; update the affected package's
  `CHANGELOG.md` for user-facing changes.

## Testing / validation

Documentation-only change; no code behavior changes. Validation is:
- `dart analyze packages` stays clean (no code touched, but re-run as a safety
  net in case an example snippet in a `.md` file is later lifted into
  `example/main.dart` — not planned here, but harmless to check).
- Manually confirm all relative links in the new/edited `.md` files resolve
  (root README ↔ package READMEs ↔ `doc/*.md` ↔ `CONTRIBUTING.md`).
- Spot-check badge URLs render (shields.io badges are static and don't need
  network validation beyond a visual check in the rendered markdown preview).

## Out of scope / explicitly deferred

- Localizing `doc/*.md` or `CONTRIBUTING.md` into Ukrainian (README.ua.md files
  keep their current content; only get the same badge/banner treatment as their
  English counterparts, no `doc/` links since the guides themselves are
  English-only).
- Provider package `doc/` folders or "what's inside" tables.
- A pub-version badge for provider packages (add once they're actually published).
