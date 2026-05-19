import VersoSlides

open VersoSlides

#doc (Slides) "Mathlib adaptation and downstream testing" =>
%%%
theme := "white"
slideNumber := true
transition := "none"
%%%

# Mathlib adaptation and downstream testing

Kim Morrison, Marcelo Lynch, Joscha Mennicken

FRO + Mathlib offsite, 20 May 2026

# Lean and Mathlib both move fast and break things

* We're still shipping significant new features.
  We need to be able to move fast to deliver our roadmap.
* We need accurate and timely feedback on how PRs affect downstream projects.
* We want our users to have a better experience dealing with toolchain and dependency updates.
* Efficient processes and automation are essential.

# Today

* The basic tension
* The status quo
* What's new
  * downstream monorepo
  * hopscotch
* Next steps

# The basic tension

* We want to be able to test most Lean PRs against downstream repositories.
  * "Mathlib as a giant test suite"
  * Minimize surprises, and minimize context switching.
* Some Lean changes require non-trivial changes, and the Lean PR author can't be responsible for fixing everything.
* We also need to *review* all changes being made in Mathlib / downstream.
* But this all needs to happen fast, or there's no usable version of Mathlib for Lean to test against.

* But this isn't just about changes in Lean. Mathlib and Batteries and ... change, and break their downstreams,
  and we need to provide a good experience.

# The status quo - Lean toolchains

* Lean releases a new "minor" version every month, as a release candidate.
  * We're currently at `v4.30.0-rc2`.
* Each minor version is cut from a `releases/v4.X.0` branch,
  and subsequent RCs or patch versions are produced by cherry-picking commits back to this branch.
  (There's a PR label to automate backporting to the release branch.)
* Some months there are no further RCs. Our record was `v4.29.0-rc8`!
* Usually we cut the final release of a minor version the day before the first release candidate of the next minor version.
* We only make patch releases for critical issues.

# The status quo - bumping downstream projects

* Today, ecosystem version coordination is done via "toolchain tags", i.e. many repositories will create a tag
  `v4.X.Y.rcK` when they first move to that toolchain.
* In practice, this means that the `v4.X.Y-rcK` tagged repositories are mutually compatible.
* ... but there's no guarantee, and will get harder as the ecosystem grows.
* This system is inflexible, and makes it hard for projects to use semantic versioning.
* As part of the monthly release process, the FRO release manager (:wave: Joscha + Claude)
  updates a ["blessed" set](https://github.com/leanprover/lean4/blob/master/script/release/repos.py) of downstream repositories:
  * batteries, aesop, import-graph, plausible, proof-widgets, doc-gen4, quote4, lean4-cli, mathlib4, cslib, repl, verso, verso-web-components, reference-manual, lean-fro.org, bibtex-query, lean-sqlite, comparator, lean4export, ...
* For this process to be sane, the repositories need to mostly already be ready to go, via CI tested and maintainer reviewed "adaptation branches".

# The status quo - adapting downstream projects

* Many of the major downstream repositories maintain an *unreviewed* `nightly-testing` branch,
  with automation that
  1. bumps the `lean-toolchain` file to the latest Lean nightly tag
  2. runs `lake update` to update upstream repos to their latest `nightly-testing` commits
  3. frequently merges the default branch into the `nightly-testing` branch.
* The goal is to get this branch back to green as quickly as possible, but it is often broken.
* A team of FRO and MI staff, and Mathlib contributors, collaborate on this, by pushing fixes unreviewed direct to `nightly-testing`.

* At Mathlib, we tag `nightly-testing-YYYY-MM-DD` the first time `nightly-testing` is green against the `nightly-YYYY-MM-DD` release of lean,
  and `nightly-testing-green` tracks the most recent green commit on `nightly-testing`.

* Prior to release day, we make sure all the relevant `nightly-testing` branches are green.
* But: how do we review the adaptation work that accumulates on `nightly-testing`?

# The status quo - reviewing adaptation work in downstream projects.

* For many of the small projects, there's no additional review of adaptation work until release day,
  when the release manager (or rather, their scripts, often driven by Claude) merges `nightly-testing` branches back into default branches.
* Previously, this meant that I was doing this review (e.g. at `quote4`, `lean4-cli`, `doc-gen4`). As we add more downstream repos to the release process,
  and we delegate the release process to new people (and new AIs), this becomes harder.
  We can't rely on the release manager having the context to review all the changes in all the downstream repos.

* At the major projects, in particular Batteries, Mathlib, and CSLib, we maintain also a `bump/v4.X.0` branch,
  which (in principle!) is both
  1. always green (caveat: we merge the default branch directly into it, without checking CI)
  2. fully reviewed by the project maintainers.
* We move material from `nightly-testing` to `bump/v4.X.0` branches via PRs using `bump/nightly-YYYY-MM-DD` branches
  (essentially at the same time as we created the `nightly-testing-YYYY-MM-DD` tags).
* In practice, often I'm reviewing and merging these PRs myself. Many people help, but if we lag too far behind a traffic jam forms and everything gets harder.
* This is also often the first time Mathlib maintainers are seeing the adaptations, long after the underlying changes have hit Lean's master branch.

# The status quo - testing against downstream projects

So far this is a one way street: Lean changes something, and downstream repositories have to adapt.


* TODO: explain how Lean PRs are automatically tested, against what?
* TODO: explain what goes wrong as `nightly-testing` falls behind
* TODO: or if `bump/nightly-YYYY-MM-DD` don't get reviewed/merged.

# Downstream monorepo tooling (Joscha)

* Maintain a git repository containing copies of Lean packages that are downstream of a "reference repository"
* Override dependencies to point to local copies and to the reference repository
* Can be pointed to a PR branch of the reference repository to see what breaks
* Extract local changes as PRs to the individual repositories
* Tool for (and belongs to) maintainers of reference repository

# Example: Lean monorepo

* Follow Lean `master`, acting as a sandbox on top of some downstream repos
* Think of it like a `nightly` branch
* Centralize `lean-pr-testing-XXXX` branches from Batteries and Mathlib
* Regularly open PRs to downstream `nightly`/`bump` branches where present

# Other applications

* Verso/Batteries/Mathlib monorepos?
  * No requirement that all downstream repos need to compile
  * Rather, status info and a place to experiment with fixes across multiple repos
* Simplify Mathlib nightly infrastructure using Lean monorepo?

# Hopscotch — as it is (Marcelo)

* Three goals:
  * Ecosystem-wide compatibility visibility for Mathlib.
  * Good practices: stay up to date, fix one break at a time.
  * Flexible ways for downstreams to track mathlib, accomodate different maintainer styles.
* `hopscotch` (CLI): bisects a dependency's commit history. Finds the *culprit*, pins your manifest there. "Interactively" fix breaks one by one until you reach your target revision.
* Two ways to put it in CI:
  * `hopscotch-action`: a GH Action each downstream runs in its own CI. Bump PR when green, tracking issue with the *first-known-bad* revision when red. Works for any lakefile dependency.
  * `downstream-reports`: hosted centrally at `leanprover-community`. Runs break detection across a curated set, produces historical data, ships companion actions so downstreams can consume the data without running their own bisects.
* Today: "Curated set" of 21 downstreams tracked centrally. Dashboard at `leanprover-community.github.io/downstream-reports/`.

# Downstream reports webpage

{image "img/downstream_reports.png"}[Downstream reports webpage]

# Automatic bump PR

{image "img/bump_pr.png"}[Automatic bump PR]

# Fix PR & tracking issue

{image "img/issue.png" (height := "70vh")}[Tracking issue] {image "img/fix_pr.png" (height := "70vh")}[Fix PR]

# Pre-merge PR validation: `!downstream-check` (Marcelo)

* Hopscotch and downstream-reports react *after* a break lands. Complementary goal: catch breakage *before* merge, from the PR conversation itself.
* UX: a reviewer comments on a mathlib4 PR.
  * `!downstream-check FLT, Toric --merge-branch, carleson@v1.2.3`
  * Workflow gates on author association, dispatches one build per entry, posts a single result comment.
* Two build modes:
  * *LKG mode* (default): cherry-pick the PR onto the downstream's last-known-good mathlib, then build. Robust against master drift.
  * *--merge-branch*: build against the PR's merge tree directly. Cheaper (mathlib olean cache hits), but tied to current master.

{image "img/pr_validation.png"}[Downstream validation result on a mathlib PR]

# Future work (Marcelo)

* Better caching. Bisects rebuild a lot today; cache reuse across probes and downstreams would cut cost.
  * move to `lake cache`
  * cache every mathlib commit
  * alternative cache endpoints
* Beyond mathlib. The same machinery should work for any upstream/downstream pair (through the lakefile, that is)
* Move off GitHub Actions? A dedicated service gives proper scheduling, persistence, and runner control.
* Automated fixes. Small, localized culprits make AI- or heuristic-driven fix PRs tractable.
* Expose the data to arbitrary consumers (say, REST API; not only through official GH actions)

# How they fit together

* The main question throughout: who bears the cost when a change breaks dependents?
* Different changes deserve different answers. The infrastructure can support both (should it?):
* *Adaptation upfront*: break and fix ship "together".
  * Monorepo: everything lives in one tree, ship an adaptation along with the break.
  * `!downstream-check`: reviewers gate the merge on a green check.
* *Ship with attribution*: accept the break, make the culprit visible, provide tooling to absorb it.
  * `downstream-reports`: central compatibility data plus composite actions (`bump-to-latest`, `open-bump-pr`, `track-incompatibility`, `query-latest`).
  * `hopscotch-action`: each downstream runs hopscotch in its own CI. Same outcome, no dependency on central snapshots.

# Discussion
