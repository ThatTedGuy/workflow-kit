# Performance

The target hardware, the frame-time budget, and the results of every measurement. Set in pre-production, and checked at every phase gate (technical principle: "A performance budget").

- **Who changes what:** a phase can move time between lines of the split (section 4) with {{OWNER}}'s OK. Only {{OWNER}} changes the totals, the target, or the specs. Every change is logged in `docs/DECISIONS.md`, and this doc is updated to match, so it always shows the current numbers.
- **The results log** (section 7) gets a row at every phase gate, and whenever a step profiles against the budget.

## 1. The two PCs

**{{OWNER}}'s PC** is where everything is measured.

| Part | {{OWNER}}'s PC |
| --- | --- |
| CPU | TODO-DESIGN: model, cores, threads |
| GPU | TODO-DESIGN: model, video memory, driver |
| RAM | TODO-DESIGN: size and speed |
| Storage | TODO-DESIGN: drive |
| Display | TODO-DESIGN: resolution and refresh rate |
| OS | TODO-DESIGN: version and build |

**The lower-end reference spec** is the PC the game must run well on.

| Part | Lower-end reference spec |
| --- | --- |
| GPU | TODO-DESIGN: speed class and video memory |
| CPU | TODO-DESIGN: cores and threads |
| RAM | TODO-DESIGN: size |
| Storage | TODO-DESIGN: SSD or HDD |
| Display | TODO-DESIGN: resolution and refresh rate |
| OS | TODO-DESIGN: versions |

- **Why this spec:** TODO-DESIGN: how common these parts are, for example from the Steam Hardware Survey
- **A real lower-end PC** is tested by TODO-DESIGN: step at the latest. Until then, {{OWNER}}'s PC stands in for it (section 3).

## 2. The target

**TODO-DESIGN: frame rate at TODO-DESIGN: resolution on the lower-end spec,** during the worst case each phase adds. TODO-DESIGN: 60 fps is 16.7 ms a frame.

| Limit, on the lower-end spec | CPU | GPU |
| --- | --- | --- |
| Average frame time | TODO-DESIGN: ms | TODO-DESIGN: ms |
| 99th percentile: 99% of frames take this long or less | TODO-DESIGN: ms | TODO-DESIGN: ms |
| Worst frame, after the scene has warmed up | TODO-DESIGN: ms | TODO-DESIGN: ms |

- **Leave a safety margin** between the average and the frame time, for background apps, drivers, and spikes.
- **Check CPU and GPU separately.** They work at the same time, so a frame takes as long as the slower of the two.

## 3. The limits on {{OWNER}}'s PC

Each lower-end limit, multiplied by how fast the lower-end part is next to {{OWNER}}'s: **TODO-DESIGN: factor for the GPU** and **TODO-DESIGN: factor for the CPU**, from benchmarks listed in section 8.

| Limit, same scene and settings | Lower-end spec | {{OWNER}}'s PC |
| --- | --- | --- |
| Average GPU time | TODO-DESIGN: ms | TODO-DESIGN: ms |
| Average CPU time | TODO-DESIGN: ms | TODO-DESIGN: ms |

This is an estimate until a real lower-end PC is tested.

## 4. The split by system

How much time each system can spend, so no system eats the others' share.

| System | GPU, lower-end (ms) | CPU, lower-end (ms) | Notes |
| --- | --- | --- | --- |
| TODO-DESIGN: system | TODO-DESIGN: ms | TODO-DESIGN: ms | TODO-DESIGN: what it covers |
| Margin | TODO-DESIGN: ms | TODO-DESIGN: ms | Unassigned, for what the plan missed |

## 5. Memory limits

| Memory | Limit | Why |
| --- | --- | --- |
| Video memory | TODO-DESIGN: GB | TODO-DESIGN: the lower-end card's size, less what the OS and drivers use |
| System memory | TODO-DESIGN: GB | TODO-DESIGN: the lower-end RAM, less the OS and background apps |

## 6. How to measure

TODO-DESIGN: The tool, the build to measure (a release export, not the editor), the scene and settings, how long to run, and what to record. One fixed measuring run that every gate repeats, so results compare.

## 7. Results log

| Date | Step or gate | Scene | Average GPU / CPU (ms) | 99th percentile GPU / CPU (ms) | Worst (ms) | Memory | Pass? | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

## 8. Sources

TODO-DESIGN: The benchmarks and surveys behind the spec and the speed factors, with links.
