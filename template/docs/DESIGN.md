# {{PROJECT_NAME}} — Design

The single source of truth for v1. The session commands look for the sections below by these names, so keep the headings.

**Status:** Draft (pre-production). TODO-DESIGN: when {{OWNER}} approves it, write "Approved ({{OWNER}}, YYYY-MM-DD)".

## Vision

TODO-DESIGN: Two or three sentences: what this is and who it's for.

## Design pillars

Every feature must serve at least one.

1. TODO-DESIGN: **pillar name:** one line
2. TODO-DESIGN: **pillar name:** one line

## v1 scope

TODO-DESIGN: What v1 includes. Be specific: /plan-it quotes these lines to mark work IN.

## Not in v1

TODO-DESIGN: What v1 leaves out on purpose. /plan-it flags work that lands here as OUT.

## Core systems design

One subsection per system, saying how it should behave. `/qa-docreview` checks the code against these.

### TODO-DESIGN: System name

TODO-DESIGN: How it works.

## Technical principles

TODO-DESIGN: The same list as in CLAUDE.md.

## Roadmap

Phases hold steps, and steps hold sub-steps. Each sub-step is one Build-track cycle (`/plan-it` → `/code` → `/review-fix-commit`). Each step has a "Done when" line, and each phase ends with a gate.

This roadmap is the Production stage (RULES.md, "Stages"). Pre-production isn't in it, since it's what writes the roadmap. The first phase usually sets up the foundations, such as folders, tests, and the build. The last phases cover polish, bug fixing, and the v1 release. Work after release goes under "Updates after v1".

### Phase 1 — TODO-DESIGN: name

#### Step 1.1 — TODO-DESIGN: name

- 1.1.1 TODO-DESIGN: sub-step
- 1.1.2 TODO-DESIGN: sub-step

Done when: TODO-DESIGN: a statement someone can check

#### Step 1.2 — TODO-DESIGN: name

- 1.2.1 TODO-DESIGN: sub-step

Done when: TODO-DESIGN: a statement someone can check

**Phase 1 gate:** TODO-DESIGN: conditions that must all be true before Phase 2 starts

## Updates after v1

The Post-production stage. Empty until v1 ships. `/pre-pro` adds one subsection per update, planned from the parking lot ideas {{OWNER}} picked for it, and {{OWNER}} approves it before building starts. Phase numbers carry on from the last one before, so sub-step IDs never clash: if v1 ends at Phase 9, v1.1 starts at Phase 10.

### v1.1 — TODO-DESIGN: name

**Status:** Draft. TODO-DESIGN: when {{OWNER}} approves it, write "Approved ({{OWNER}}, YYYY-MM-DD)".

**Scope:** TODO-DESIGN: the parking lot ideas picked for this update, and how each should work. /plan-it quotes these lines to mark work IN.

**Not in this update:** TODO-DESIGN: what's left for later.

**Phases:** TODO-DESIGN: laid out like the v1 roadmap: phases, steps, sub-steps, "Done when" lines, and gates. The last phase releases the update.

## Parking lot

{{OWNER}}'s reviewed copy of the ideas in `docs/AFTER_V1.md`.
