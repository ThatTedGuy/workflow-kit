# Roadmap Status

Progress against the roadmap in [DESIGN.md](DESIGN.md). Tick a sub-step `[x]` in the same commit as its work. Tick a step's "Done when" line only once it is true. Lines that {{OWNER}} must check personally say "({{OWNER}} verifies)". A project that starts with a finished design doc skips pre-production: it writes Production on the Stage line, and its first sub-step on the Next sub-step line, such as `1.1.1 — <name> (/plan-it 1.1.1)`.

**Stage:** Pre-production (RULES.md, "Stages").

**Next sub-step:** none yet: see the checklist below.

## Pre-production checklist

`/pre-pro` works one item per session, in any order that suits, but the roadmap comes last. {{OWNER}} ticks each item after reading it. When every item is ticked, {{OWNER}} sets the Stage line to Production and the Next sub-step line to 1.1.1.

- [ ] Notes gathered: {{OWNER}}'s ideas are in `docs/preprod/NOTES.md`
- [ ] Open questions listed in `docs/preprod/QUESTIONS.md`, and each one answered or deferred
- [ ] Vision and design pillars written
- [ ] v1 scope and "Not in v1" written
- [ ] Core systems designed, one section each
- [ ] Stack or engine chosen, with the decision logged in `docs/DECISIONS.md`
- [ ] Prototypes answered the riskiest questions (or none were needed)
- [ ] Technical principles written, here and in `CLAUDE.md`
- [ ] `CLAUDE.md`'s `TODO-DESIGN:` markers filled in: where things stand, conventions, Checks, Environment
- [ ] Roadmap written: phases through polish and the v1 release, every step with a "Done when" line, and every phase with a gate
- [ ] Roadmap copied below as checkboxes
- [ ] {{OWNER}} approves `docs/DESIGN.md` as the source of truth for v1

## Phase 1 — TODO-DESIGN: name

### Step 1.1 — TODO-DESIGN: name

- [ ] 1.1.1 TODO-DESIGN: sub-step
- [ ] 1.1.2 TODO-DESIGN: sub-step
- [ ] Done when: TODO-DESIGN: copied from DESIGN.md

### Step 1.2 — TODO-DESIGN: name

- [ ] 1.2.1 TODO-DESIGN: sub-step
- [ ] Done when: TODO-DESIGN: copied from DESIGN.md

- [ ] **Phase 1 gate:** TODO-DESIGN: copied from DESIGN.md

## Updates after v1

Empty until v1 ships. When {{OWNER}} approves an update in `DESIGN.md`, copy its phases here as checkboxes, under a heading such as "v1.1 — <name>", set the Stage line to Post-production if it isn't already, and point the Next sub-step line at its first sub-step.

## Notes

Dated notes on anything left open, such as checks {{OWNER}} still has to do.
