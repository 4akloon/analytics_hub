# Contributing to analytics_hub

## Contents

- [Prerequisites](#prerequisites)
- [Getting the code](#getting-the-code)
- [Repository layout](#repository-layout)
- [Everyday commands](#everyday-commands)
- [Architecture at a glance](#architecture-at-a-glance)
- [Extending the project](#extending-the-project)
- [Coding conventions](#coding-conventions)
- [Tests](#tests)
- [Commits & pull requests](#commits--pull-requests)

## Prerequisites

- Dart SDK `>=3.5.0 <4.0.0`.
- Flutter (stable channel). The core `analytics_hub` package is pure Dart,
  but the provider packages' tests depend on `flutter_test` (for mocking
  Flutter-plugin SDKs), and this repo is a single pub workspace — so a
  Flutter install is needed even if you're only touching core.

## Getting the code

This repo is a [Dart pub workspace](https://dart.dev/tools/pub/workspaces):
all four packages are resolved together from one lockfile. Run this once
from the repo root:

```sh
flutter pub get
```

`flutter pub get` is the one command that always works here, since it
resolves both the pure-Dart core package and the Flutter-dependent providers
in the same workspace. Plain `dart pub get` also works if you're only working
on `packages/analytics_hub`.

## Repository layout

See the [packages table in the root README](README.md#packages) for what
each package does. In short: `analytics_hub` (core) has no dependency on any
provider SDK; every provider package (`analytics_hub_firebase`,
`analytics_hub_mixpanel`, `analytics_hub_appsflyer`) depends on core and
implements its `AnalyticsProvider`/`EventResolver` contracts.

## Everyday commands

Run from the repo root unless noted otherwise:

```sh
dart analyze packages
dart format packages

# Core package (pure Dart):
cd packages/analytics_hub && dart test

# Provider packages (depend on flutter_test):
cd packages/analytics_hub_firebase && flutter test
cd packages/analytics_hub_mixpanel && flutter test
cd packages/analytics_hub_appsflyer && flutter test

# Before publishing a package:
cd packages/<package> && dart pub publish --dry-run
```

## Architecture at a glance

Sending an event goes through a fixed pipeline: per-provider overrides are
applied first, then hub-level interceptors run, then provider-level
interceptors, then the provider's `EventResolver` actually delivers the
event. Each event/provider pair gets its own `EventDispatchContext` built
for that dispatch. See
[doc/interceptors_and_context.md](packages/analytics_hub/doc/interceptors_and_context.md)
for the full breakdown.

## Extending the project

- **New provider:** implement `AnalyticsProvider` + `EventResolver` in a new
  `analytics_hub_<backend>` package that depends on `analytics_hub`. See
  [doc/providers.md](packages/analytics_hub/doc/providers.md) for the
  step-by-step walkthrough.
- **New cross-cutting behavior** (renaming, redaction, sampling, etc.):
  implement `EventInterceptor` instead of modifying a provider — see
  [doc/interceptors_and_context.md](packages/analytics_hub/doc/interceptors_and_context.md).

## Coding conventions

Enforced via `analysis_options.yaml` (built on `package:lints/recommended.yaml`):

- `public_member_api_docs` — every public member needs a doc comment.
- `sort_constructors_first`, `prefer_final_locals`, and the other rules
  listed in `analysis_options.yaml`.

Design conventions worth knowing before you touch core:

- The hub is intentionally **session-agnostic** as of 0.5.0 — there is no
  `Session`/`HubSessionDelegate` concept. Apps manage user identity directly
  on the underlying SDK (e.g. `Mixpanel.identify`, `FirebaseAnalytics.setUserId`).
  Don't reintroduce a session abstraction in core.

## Tests

- Core dispatch pipeline: `packages/analytics_hub/test/`.
- Each provider's resolver/provider behavior: `packages/<provider>/test/`.

See [doc/testing.md](packages/analytics_hub/doc/testing.md) for the pattern
used to test app code that calls `AnalyticsHub` (a fake provider + resolver
that records what it receives).

## Commits & pull requests

- Branch off `main`.
- Run `dart analyze packages` and the relevant test suite(s) before pushing.
- Update the affected package's `CHANGELOG.md` for any user-facing change.
