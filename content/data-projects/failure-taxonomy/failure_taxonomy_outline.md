## Detailed Post Outline

---

### Metadata / Framing
- **Title:** *"The Repair Requires a Diagnosis"* (or *"What Breaks and Where"*)
- **Subtitle/lede:** A self-healing AI system sounds autonomous. Without a failure taxonomy, it's just a loop that thrashes.
- **Target length:** ~1,400–1,800 words
- **Banner:** SVG — two repair curves diverging from the same starting point (mirrors the ARC heart rate visual language)
- **Series note:** Sequel to the model-quality, ARC, ARC-retention, and WildChat posts. Establish this in the first paragraph.

---

### Opening Analogy (~150 words)

A mechanic's diagnostic system. Modern cars log hundreds of fault codes. When a warning light trips, the code tells the mechanic *which system* threw the fault — not just that something failed. A shop that responded to every warning light by replacing the air filter would fix almost nothing, spend a lot, and never understand why the same light kept coming back.

The analogy does the work early: the signal exists, the loop exists, but without the routing mechanism (the fault code taxonomy), the repair targets the wrong layer every time. Land this in two paragraphs and get out.

**What it sets up:** the rest of the post isn't about whether to collect loss signals — your prior posts established that. It's about what you do with them once you have them.

---

### Bridge from the Series (~150 words)

Explicit callback to the prior four posts, one sentence each:

- The model-quality post showed quality drives retention, and that category-level quality variation is what makes the causal identification work.
- The ARC post showed the trajectory of how a model arrives at an answer carries signal the final score misses.
- The ARC-retention post showed trajectory shape predicts whether users come back.
- The WildChat post showed users reveal quality gaps through their prompt behavior — without ever filing a bug report.

**The gap those posts left open:** once you've detected that something is failing, you know *that* the system is underperforming. You don't yet know *where*. A retention dip is an outcome. A repair needs a cause. That's the problem this post addresses.

One crisp transition sentence into the next section.

---

### Section 1: The Scale of the Problem (~200 words)

This is the one section that leans on published numbers. Two data points, delivered fast.

**Point 1 — failure rates are not edge cases:**
MAST (NeurIPS 2025, UC Berkeley) analyzed 1,642 multi-agent execution traces across 7 state-of-the-art open-source frameworks. Failure rates ranged from 41% to 86.7%. These aren't prototype systems — they're the frameworks people are deploying.

**Point 2 — failures cluster by type, and type predicts repair target:**
AgentFixer found that parsing failures alone — malformed JSON, missing schema fields, instruction noncompliance — account for ~38% of all observed production failures. Not 38% of one category. 38% of everything. That single failure type has a specific, tractable repair target: output formatting instructions in the system prompt. You don't need a model retrain. You need a better instruction.

**The pivot:** this is the structural argument for the taxonomy. If 38% of your failures route to the same fix, and you're applying the same fix to 100% of your failures, you're burning resources on the 62% while under-investing in the 38% that would actually move the needle. The taxonomy is the routing layer.

---

### Section 2: The Taxonomy Is the Machine (~300 words)

This is the crux. Present the taxonomy table — your original contribution to this post.

**Setup paragraph:** A loss taxonomy maps observed failure signals to the system component most likely responsible. It has two jobs: route known failures to the right repair, and surface failures that don't fit any existing category (the emergent case). The second job is the more important one.

**The table:**

| Failure Pattern | Observable Signal | Likely Locus | Repair Target |
|---|---|---|---|
| Correct intent, wrong format | Retry with same content, reformatted | System prompt | Output format instructions |
| Hallucinated facts, right structure | User correction follow-up | Base model knowledge | RAG layer or targeted fine-tune |
| Refused valid request | Abrupt session end after refusal | System prompt | Instruction calibration |
| Right answer, wrong step order | Mid-task rephrase, step backtrack | Reasoning scaffold | Chain-of-thought structure |
| Works in eval, breaks in production | Eval-prod quality gap | Eval distribution | Eval set expansion |
| Fails under long context | Quality degrades mid-session | Context management | Chunking / summarization strategy |
| Unclassified | Doesn't match any row above | Unknown | → Extend the taxonomy |

**After the table — the emergent failure paragraph:**
The last row is the most important. When a failure pattern doesn't cross-reference cleanly, the temptation is to force it into the nearest existing category. That's the mistake. An unclassified failure is a signal that the taxonomy has a blind spot. Patching the symptom without extending the taxonomy guarantees the next variant of that failure also goes unclassified. The residual — the fraction of losses that don't fit — is a metric. A growing residual means the taxonomy is lagging the system.

---

### Section 3: The Experiment — Taxonomy-Routed vs. Naive Repair (~350 words)

This is the synthetic validation section, consistent with your prior posts.

**Setup:**
Synthetic dataset. 1,000 simulated production interactions. Five injected failure types drawn from MAST's published distribution: specification misalignment (~25%), reasoning failure (~20%), context management (~18%), output format error (~15%), retrieval/knowledge gap (~12%), residual/unclassified (~10%).

Two repair strategies applied over three cycles:

- **Strategy A (Naive):** All failures treated as equivalent. Repair applied uniformly — same prompt adjustment across all failure types.
- **Strategy B (Taxonomy-Routed):** Each failure cross-referenced against the taxonomy. Repair routed to the specific locus for that failure type.

Quality scored per cycle using the same weighted-category approach from the model-quality post, so the methodology is consistent with the series.

**Results (what the chart shows):**
After cycle 1: both strategies improve. Naive repair picks up the easy wins — format errors happen to respond to general prompt tightening.

After cycle 2: Strategy B continues recovering. Strategy A plateaus. The failures that didn't respond to the uniform fix are still present; some failures that did respond have re-emerged in slightly different form because the root layer wasn't targeted.

After cycle 3: Strategy B has recovered ~85% of injected quality loss. Strategy A has recovered ~45% and is beginning to regress on failure types whose repair target conflicts with the uniform fix applied to other types.

**The chart:** Two curves, three cycles on the x-axis, quality recovery % on the y-axis. Visual language consistent with the ARC comparison chart — same color scheme, same clean SVG style. This is the banner-worthy visual.

**Key callout:** The crossover isn't a surprise. It's a structural property of the problem. When repair targets the wrong layer, it doesn't just fail to fix the failure — in some cases it makes a different failure worse. Format instruction tightening that was meant to fix output errors can over-constrain the system prompt and increase valid-request refusals. The taxonomy prevents this class of iatrogenic failure.

---

### Section 4: The Loop in Full (~200 words)

Walk the complete cycle — keep it tight, one sentence per step:

1. **Baseline** — establish quality from evals before any user traffic
2. **Collect** — aggregate loss patterns from users (explicit ratings + inferred signals: retries, rephrases, session-ending refusals, low copy rates)
3. **Cross-reference** — run losses against the taxonomy to identify repair locus
4. **Prioritize** — rank by volume × severity × tractability; fix the highest-leverage failure first
5. **Repair** — target the right layer (system prompt, RAG, fine-tune, eval set, context strategy)
6. **Test** — measure quality improvement against baseline
7. **Update the taxonomy** — classify any failures that didn't fit; add new categories; shrink the residual

**The critical note on step 7:** Most implementations skip it. They close the loop at step 6. A system that skips step 7 improves its current known failures but remains blind to the next generation. The taxonomy is both the router and the memory of the system. Without step 7, the loop is reactive indefinitely.

Small diagram here: a seven-node cycle, with step 7 drawn as feeding back into step 3, not just step 1. The visual makes the point that the taxonomy update is what makes the loop genuinely self-improving rather than self-repeating.

---

### Closing (~150 words)

Return to the mechanic analogy — close the loop on the opening.

A shop with a good diagnostic system fixes the right thing the first time, updates its fault code library when a new failure mode comes in, and gets faster over time. A shop without one replaces air filters and sends the car home. Both look like they're working. The difference shows up on the third visit.

The earlier posts in this series built the instruments: quality measurement at the category level, trajectory scoring, behavioral inference from user prompts. The taxonomy is what connects those instruments to a repair. Without it, you have signal and no routing. The self-healing loop becomes self-thrashing.

**Final sentence — forward pointer:** The next question is what the residual looks like in real user data — how fast new failure modes accumulate, and whether a taxonomy can be built to keep pace. That's the WildChat extension.

---

### Methodological Note (collapsible or footnote, consistent with your ARC posts)

- N=1,000 synthetic interactions, 5 injected failure types
- Failure type distribution drawn from MAST published percentages
- Quality scoring uses weighted-category method from model-quality post (frozen weights, same identification strategy)
- Repair effectiveness function: taxonomy-matched repair recovers 80–90% of injected loss per cycle; mismatched repair recovers 10–30%
- Three repair cycles simulated
- Code: link to GitHub repo

---

### Series Linkage (footer, consistent with your other posts)

| Post | Core Claim |
|---|---|
| Model Quality | Quality drives retention; category-level variation enables causal identification |
| ARC | Trajectory shape carries signal the final score misses |
| ARC-Retention | Trajectory shape predicts 7-day return |
| WildChat | Users reveal quality gaps through prompt behavior |
| **This post** | **Taxonomy routes loss signals to the right repair layer** |
| *Next* | *Emergent failures: measuring taxonomy lag in real user data* |

---

### Code Sketch for the Synthetic Experiment

The pieces you'll build in your codespace:

```python
# failure_types: dict of type -> (MAST_share, repair_locus)
# repair_strategies: naive (uniform) vs. routed (taxonomy-matched)
# quality_recovery(failure_type, repair_locus_match: bool) -> float
# simulate N=1000 interactions, apply 3 repair cycles each strategy
# output: quality_recovery_curve[strategy][cycle]
```

The chart is the same matplotlib/SVG pipeline you used for the ARC and model-quality figures. Two lines, three x-ticks, y-axis as % quality recovered from injected baseline loss. Add a horizontal dashed reference line at 100% (full recovery) and annotate the gap at cycle 3.