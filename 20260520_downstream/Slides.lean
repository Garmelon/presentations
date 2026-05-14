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

# Lean moves fast and breaks things

* We're still shipping significant new features.
  We need to be able to move fast to deliver our roadmap.
* We need accurate and timely feedback on how PRs affect downstream projects.
* We want our users to have a better experience dealing with toolchain and dependency updates.
* Efficient processes and automation are essential.

# Today

* The basic tension
* The status quo
* What's new
  * hopscotch
  * downstream monorepo
* Next steps

# The basic tension

* We want to be able to test most Lean PRs against downstream repositories.
  * "Mathlib as a giant test suite"
  * Minimize surprises, and minimize context switching.
* Some Lean changes require non-trivial changes, and the Lean PR author can't be responsible for fixing everything.
* We also need to *review* all changes being made in Mathlib / downstream.
* But this all needs to happen fast, or there's no usable version of Mathlib for Lean to test against.

# The status quo - Lean toolchains

* Lean releases a new "minor" version every month, as a release candidate.
  * `v4.31.0-rc1` has just landed.
* Each minor version is cut from a `releases/v4.X.0` branch,
  and subsequent RCs or patch versions are produced by cherry-picking commits back to this branch.
  (There's a PR label to automate backporting to the release branch.)
* Some months there are no further RCs. Our record was `v4.29.0-rc8`.
* Usually we cut the final release of a minor version the day before the first release candidate of the next minor version.
* We only make patch releases for critical issues.

# The status quo - bumping downstream projects

* Today, ecosystem version coordination is done via "toolchain tags", i.e. many repositories will create a tag
  `v4.X.Y.rcK` when they first move to that toolchain.
* In practice, this means that the `v4.X.Y-rcK` tagged repositories are mutually compatible.
* ... but this will get harder as the ecosystem grows.
* This system is inflexible, and makes it hard for projects to use semantic versioning.
* As part of the monthly release process, the FRO release manager (:wave: Joscha + Claude)
  updates a ["blessed" set](https://github.com/leanprover/lean4/blob/master/script/release/repos.py) of downstream repositories:
  * batteries, aesop, import-graph, plausible, proof-widgets, doc-gen4, quote4, lean4-cli, mathlib4, cslib, repl, verso, verso-web-components, reference-manual, lean-fro.org, bibtex-query, lean-sqlite, comparator, lean4export, ...
* For this process to be sane, the repositories need to mostly already be ready to go, via CI tested and maintainer reviewed "adaptation branches".

# The status quo - adapting downstream projects

* TOOD: explain `nightly-testing` branches,
* TODO: `bump/v4.X.0` branches (which repos use them?)
* TODO: and how/where adaptations get reviewed, and by who (who has context/time?).
* TODO: explain `nightly-testing-YYYY-MM-DD` tags

# The status quo - testing against downstream projects

* TODO: explain how Lean PRs are automatically tested, against what?
* TODO: explain what goes wrong as `nightly-testing` falls behind
* TODO: or if `bump/nightly-YYYY-MM-DD` don't get reviewed/merged.

# Updates to the Lean release process (Joscha)

* TODO - what's changed recently? new automation?

# Hopscotch — as it is (Marcelo)

* TODO — what hopscotch does
* TODO — the local interactive workflow
* TODO — hopscotch-action and downstream-reports
* TODO — who is already using it, with numbers if possible

# Hopscotch — as it will be (Marcelo)

* TODO — near-term roadmap items
* TODO — open questions / things you want feedback on
* TODO — how this complements vs overlaps with the monorepo

# The downstream monorepo (Joscha)

* TODO — the design idea in one sentence
* TODO — current state of leanprover/downstream
* TODO — how it will be linked to lean4 PRs
* TODO — what it does that hopscotch can't, and vice versa

# How they fit together

* TODO — ???

# Next steps — cheap but effective

* TODO — 2-3 concrete things we could do this quarter at low cost??
* TODO — who would own each one??

# Next steps — expensive but worth doing

* TODO — 1-2 ambitious items, with a sketch of cost vs payoff??
* TODO — explicit asks of Mathlib / FRO / the broader community??

# Discussion

* TODO —

# TODO: Stuff to mention somewhere?

* lake support for diamonds
* still don't have `lake cache`
* crucible
