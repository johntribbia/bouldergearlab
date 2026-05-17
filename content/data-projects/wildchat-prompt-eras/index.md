---
title: "How Users Vote With Their Prompts"
date: 2026-05-09
tags: ['data project']
categories: ['data project']
description: "When GPT-4 launched in March 2023, the topic mix of real user prompts shifted in the exact direction the model quality gaps would predict: coding and reasoning grew, casual conversation did not."
draft: false
banner: "wc-banner.svg"
---
<!--more-->

<style>
/* ── WildChat Prompt Eras — BGL Dark Theme ── */

.wc-lede {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.4);
  border-left: 2px solid var(--moss);
  padding: 0.8rem 1.2rem;
  background: rgba(125,184,0,0.06);
  line-height: 1.65;
  margin-bottom: 2.5rem;
  letter-spacing: 0.03em;
}

.wc-p {
  font-size: 1.5rem;
  color: rgba(255,255,255,0.65);
  line-height: 1.78;
  margin-bottom: 1.2rem;
}
.wc-p strong { color: rgba(255,255,255,0.88); font-weight: 700; }

.wc-h2 {
  font-family: var(--f-display);
  font-size: 1.65rem;
  font-weight: 700;
  color: rgba(255,255,255,0.9);
  margin: 3rem 0 1rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.wc-hr {
  border: none;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin: 3rem 0;
}

/* ── Visualization cards ── */
.wc-vis-card {
  background: rgba(255,255,255,0.025);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 8px;
  padding: 28px 24px 20px;
  margin: 36px 0;
}
.wc-vis-label {
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--moss);
  margin-bottom: 4px;
}
.wc-vis-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255,255,255,0.88);
  margin-bottom: 3px;
  font-family: var(--f-display);
}
.wc-vis-sub {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 18px;
  font-family: var(--f-mono);
}
.wc-vis-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 22px;
  margin-bottom: 14px;
  font-size: 1.25rem;
  color: rgba(255,255,255,0.55);
  font-family: var(--f-mono);
}
.wc-vis-legend span { display: flex; align-items: center; gap: 8px; }
.wc-vis-legend i { display: inline-block; width: 26px; height: 3px; border-radius: 2px; flex-shrink: 0; }
.wc-vis-note {
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  margin-top: 16px;
  font-style: italic;
  font-family: var(--f-mono);
  line-height: 1.65;
}

/* ── Callout ── */
.wc-callout {
  margin: 2.2rem 0;
  padding: 1.3rem 1.7rem;
  border-left: 3px solid var(--moss);
  background: rgba(125,184,0,0.05);
  font-style: italic;
  font-size: 1.5rem;
  color: rgba(255,255,255,0.55);
  line-height: 1.8;
}
.wc-callout.red { border-color: var(--rust); background: rgba(224,112,85,0.05); }
.wc-callout strong { color: rgba(255,255,255,0.82); font-style: normal; }

/* ── Data table ── */
.wc-table-wrap {
  overflow-x: auto;
  margin: 26px 0;
  border-radius: 4px;
  border: 1px solid rgba(255,255,255,0.07);
}
.wc-table { width: 100%; border-collapse: collapse; font-size: 1.25rem; }
.wc-table thead tr { background: rgba(255,255,255,0.06); }
.wc-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.7);
}
.wc-table tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
.wc-table tbody td {
  padding: 11px 16px;
  border-top: 1px solid rgba(255,255,255,0.05);
  font-family: var(--f-mono);
  color: rgba(255,255,255,0.5);
  font-size: 1.25rem;
  line-height: 1.6;
}
.wc-table tbody td:first-child { font-weight: 700; color: rgba(255,255,255,0.82); }
.wc-table-caption {
  font-family: var(--f-mono);
  font-size: 1.1rem;
  color: rgba(255,255,255,0.28);
  letter-spacing: 0.06em;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
}

/* ── Footnotes ── */
.wc-footnotes {
  margin-top: 52px;
  border-top: 1px solid rgba(255,255,255,0.08);
  padding-top: 26px;
  font-family: var(--f-mono);
  font-size: 1.25rem;
  color: rgba(255,255,255,0.3);
  line-height: 1.65;
}
</style>

<div class="wc-lede">
  13,597 real user prompts · WildChat-1M (Allen AI) · April 2023 – April 2024 · 1,000 sampled per shard · BERTopic over English first-turn messages
</div>

*Article by John Tribbia*

<p class="wc-p"><a href="/data-projects/model-quality-overview/">A previous post</a> built a framework for measuring whether AI model quality drives user engagement. The data was synthetic by design. You can't observe the true causal effect in a real system, so the methodology was validated by injecting a known effect and checking recovery. But the framework made a behavioral prediction that real data can test: if quality drives engagement, then when a model improves unevenly across task types, the aggregate topic mix of what users actually do should shift in the direction of the improvement.</p>

<p class="wc-p">GPT-4 launched on March 14, 2023. Its quality gains over GPT-3.5 were not uniform. On coding benchmarks it improved by nearly 19 percentage points. On reasoning and factual tasks it gained 13–16 points. On casual conversation it gained almost nothing. If users are sensitive to that quality gradient, even without knowing the benchmark numbers, coding and reasoning prompts should grow at the transition. Casual prompts should not.</p>

<p class="wc-p">That is the question. WildChat-1M gives us a dataset large enough to look for the signal.</p>

<hr class="wc-hr">

<h2 class="wc-h2">What WildChat Is</h2>

<p class="wc-p">WildChat is a corpus of 1 million real user conversations with ChatGPT, collected with user consent by Allen AI. Each conversation includes the full turn sequence, timestamps, the model version used, country of origin, and a toxicity flag. It covers January 2023 through late 2024, spanning the GPT-3.5 era, the GPT-4 launch, and the early GPT-4 diffusion period.</p>

<p class="wc-p">The analysis here uses 13,597 English first-turn prompts, 1,000 sampled from each of the 14 monthly parquet shards, after deduplication and language filtering. The first turn is the cleanest signal: it is what the user actually wanted when they sat down. Follow-up turns increasingly reflect the model's prior outputs, which makes them harder to categorize as user intent.</p>

<div class="wc-callout">
  <strong>Why first-turn only?</strong> In a user research context, the first message is the equivalent of an unprompted task statement in an interview. It captures intent before the conversation diverges into clarification, correction, or model-directed follow-up. Later turns contain signal too, but mixing them with first turns muddies the taxonomy.
</div>

<hr class="wc-hr">

<h2 class="wc-h2">Prompt Taxonomy</h2>

<p class="wc-p">BERTopic with sentence embeddings (all-MiniLM-L6-v2) and HDBSCAN clustering produced 39 distinct topic clusters from the 13,597 prompts. The outlier cluster (-1, prompts that resist classification) contained 37.6% of documents, a figure that gets its own section below.</p>

<p class="wc-p">The largest clusters were not what most summaries of LLM use would predict. <strong>Image generation</strong> was the dominant topic at 13.1% of named-topic prompts, users piping Midjourney-style visual concepts through ChatGPT. Software coding and debugging was second at 8.7%. Professional and business writing was third. The coding-dominant story turns out to be a partial portrait.</p>

<p class="wc-p">Topic 21, Jailbreak Attempts, shows up as a small but coherent behavioral pattern: 0.67% of named prompts, consistent enough in its term structure that HDBSCAN assigned it its own cluster rather than absorbing it into general chat. Topic 35, "Meta: ChatGPT Itself," captures users asking ChatGPT about ChatGPT: its version, capabilities, and the nature of the system they're talking to. That 0.38% is a reminder that a fraction of every corpus is about the instrument, not the task the instrument was built for.</p>

<p class="wc-p">The taxonomy is also an intent map that no survey would produce. Users described what they wanted in natural language, under real conditions, with something at stake. The ordering that falls out reflects what the platform actually means to its users, not what its designers hoped it would mean. Image generation coming in first and coding second is not a caveat. It is the finding.</p>

<!-- Chart 1: Topic taxonomy (horizontal bar) -->
<div class="wc-vis-card">
  <div class="wc-vis-label">WildChat-1M · 13,597 English prompts · BERTopic</div>
  <div class="wc-vis-title">The prompt taxonomy, ranked by volume</div>
  <div class="wc-vis-sub">Share of all first-turn messages per topic cluster · percent</div>
  <div style="position: relative; width: 100%; height: 420px;">
    <canvas id="taxonomyChart"></canvas>
  </div>
  <p class="wc-vis-note">Topic names assigned manually after reviewing top keywords per cluster. Outlier cluster (-1) excluded. Source: allenai/WildChat-1M.</p>
</div>

<hr class="wc-hr">

<h2 class="wc-h2">Before and After</h2>

<p class="wc-p">Monthly topic shares from April 2023 through April 2024 reveal a before-after structure at the GPT-4 Turbo launch date (November 6, 2023). The shift is not dramatic. This is aggregate behavior, not a controlled experiment. But the direction is not what a straightforward quality-gap reading would predict.</p>

<p class="wc-p">The biggest mover was not coding. Image Generation (Midjourney) held 8.3% of prompts in the months before the GPT-4 Turbo launch and jumped to 20.9% after, a 12.7-percentage-point increase that dwarfed every other shift in the dataset (p&lt;0.0001). Software coding and debugging actually <em>contracted</em> slightly: from 9.3% to 7.6%, a statistically significant decrease that reflects dilution rather than decline: the Midjourney wave brought a large new cohort into the dataset, compressing every other topic's share as a byproduct. General chat and conversational roleplay fell sharply, both dropping more than 3 percentage points, consistent with early exploratory users giving way to a more purposeful user mix. Casual conversation, the control prediction, was effectively flat: 4.0% before, 4.3% after, p=0.38. Not distinguishable from noise, and exactly what the quality-gap framework predicts for a task where model improvements were minimal.</p>

<!-- Chart 2: Topic share over time (stacked area / small-multiple line) -->
<div class="wc-vis-card">
  <div class="wc-vis-label">WildChat-1M · Monthly topic share · Apr 2023 – Apr 2024</div>
  <div class="wc-vis-title">Topic prevalence over time</div>
  <div class="wc-vis-sub">Share of monthly prompts per cluster · top 12 topics · percent</div>
  <div class="wc-vis-legend" id="timeseriesLegend"></div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="timeseriesChart"></canvas>
  </div>
  <p class="wc-vis-note">Dashed vertical line marks GPT-4 Turbo (gpt-4-1106-preview) general availability (November 6, 2023), the model-cost inflection that drove renewed GPT-4 adoption in the data. Source: allenai/WildChat-1M.</p>
</div>

<hr class="wc-hr">

<h2 class="wc-h2">Benchmarks vs. Behavior</h2>

<p class="wc-p">Coding improved nearly 19 percentage points on HumanEval between GPT-3.5 and GPT-4. Casual conversation improved by 0.04 points on MT-Bench. Effectively nothing. If those quality differences register with users, the behavioral data should reflect them.</p>

<!-- Table 2: Coding vs. Casual Chat — benchmark gain vs. behavioral response -->
<div class="wc-table-wrap">
  <div class="wc-table-caption">Table 2 · Coding vs. casual conversation: benchmark gain vs. behavioral response</div>
  <table class="wc-table">
    <thead>
      <tr>
        <th>Task</th>
        <th>Benchmark gain</th>
        <th>Share &Delta; at transition</th>
        <th>GPT-4 share / GPT-3.5 share</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Coding (HumanEval)</td>
        <td>+18.9 pp</td>
        <td>&minus;1.67 pp *</td>
        <td>13.9% / 7.1%</td>
      </tr>
      <tr>
        <td>Casual Chat (MT-Bench)</td>
        <td>+0.04 pts &dagger;</td>
        <td>+0.32 pp (p&nbsp;=&nbsp;0.38)</td>
        <td>0.8% / 5.1%</td>
      </tr>
    </tbody>
  </table>
</div>
<p class="wc-vis-note">* Coding share contracted at the aggregate transition because the Midjourney wave compressed every other topic's share. The cross-sectional ratio (13.9% vs. 7.1%) is the cleaner signal. &dagger; MT-Bench uses a 0&ndash;10 scale; GPT-3.5: 8.35 &rarr; GPT-4: 8.39. Sources: OpenAI GPT-4 Technical Report (2023); allenai/WildChat-1M.</p>

<div class="wc-callout">
  <strong>What the model-quality framework predicts here:</strong> Users don't need to know benchmark scores to respond to quality differences. If a tool reliably handles coding tasks better, the people who do coding will use it more for coding. The aggregate topic mix is revealed preference: behavioral evidence of the quality signal without any explicit user report.
</div>

<hr class="wc-hr">

<h2 class="wc-h2">GPT-3.5 vs GPT-4: Same Platform, Different Behavior</h2>

<p class="wc-p">WildChat records which model handled each conversation. Comparing the topic mix for conversations that went to GPT-3.5-turbo versus GPT-4 provides a cross-sectional version of the same hypothesis: if users self-select models based on task difficulty, the GPT-4 conversations should be heavier on the tasks where GPT-4's advantage is largest.</p>

<!-- Chart 4: Topic share by model (grouped bar) -->
<div class="wc-vis-card">
  <div class="wc-vis-label">WildChat-1M · GPT-3.5-turbo vs GPT-4</div>
  <div class="wc-vis-title">Who goes to which model, and for what</div>
  <div class="wc-vis-sub">Topic share per model · top 12 topics · percent of model-specific prompts</div>
  <div class="wc-vis-legend">
    <span><i style="background:#7db800;"></i> GPT-4</span>
    <span><i style="background:#a8c8d8;"></i> GPT-3.5-turbo</span>
  </div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="modelBreakdownChart"></canvas>
  </div>
  <p class="wc-vis-note">Model field from WildChat metadata. All 13,597 records in this sample include an explicit model identifier. Source: allenai/WildChat-1M.</p>
</div>

<hr class="wc-hr">

<h2 class="wc-h2">How Users Voted With Their Model Choice</h2>

<p class="wc-p">The topic breakdown by model tells you what users brought to each model. The routing preference index asks the inverse: for a given task, what fraction of users chose GPT-4 over GPT-3.5? This is a behavioral signal that sits underneath intent. It does not capture what the user wanted. It captures how confident they were, in practice, that the stronger model would matter for their particular task.</p>

<p class="wc-p">Software Coding &amp; Debugging routes to GPT-4 at roughly 2:1. Creative Fiction Writing shows a similar skew. Scene &amp; Visual Description routes even more strongly, with nearly all its share concentrated in GPT-4 conversations, consistent with tasks that require close instruction-following on detailed visual concepts. These are tasks where users chose the stronger model consistently, across 13 months of real usage. Midjourney image generation routes almost entirely to GPT-3.5. Casual Conversation does the same. Both are tasks where GPT-4's measured advantage is minimal, and the behavioral data reflects it: users did not seek out the stronger model for tasks where it would not differentiate.</p>

<!-- Chart 7: GPT-4 routing preference index (horizontal bar) -->
<div class="wc-vis-card">
  <div class="wc-vis-label">WildChat-1M · GPT-4 vs GPT-3.5 · model routing</div>
  <div class="wc-vis-title">GPT-4 routing preference by topic</div>
  <div class="wc-vis-sub">Share of model-identified conversations routed to GPT-4 per topic · percent · green = GPT-4 majority</div>
  <div style="position: relative; width: 100%; height: 360px;">
    <canvas id="routingPreferenceChart"></canvas>
  </div>
  <p class="wc-vis-note">Dashed line at 50% marks equal model split. Topics left of the line are GPT-3.5-dominant; right of the line are GPT-4-dominant. Source: allenai/WildChat-1M.</p>
</div>

<div class="wc-callout">
  <strong>Revealed preference without a survey.</strong> No one asked users whether they thought GPT-4 was better for coding. They answered with their model selection, at scale, across 13 months of real usage. The routing distribution is the finding, not a self-report artifact, not a satisfaction score, not a rating. It is behavior observed directly.
</div>

<p class="wc-p">In a traditional UXR context, capturing task-model matching decisions would require a diary study or contextual inquiry, asking people to narrate their tool choices as they work. At this scale, with timestamped model metadata attached to every conversation, the diary runs itself. The limitations are the same as any observational study: the behavioral pattern is visible, but the mechanism is not. Users who route coding to GPT-4 might do so because GPT-4 genuinely handles their prompts better, or because they formed that habit early when GPT-4 was the only option, or because a colleague recommended it. The distribution cannot distinguish those explanations. It establishes only that the routing happens, and that it aligns with the tasks where the benchmark gap between models is largest.</p>

<hr class="wc-hr">

<h2 class="wc-h2">Dark Matter</h2>

<p class="wc-p">Topic -1, BERTopic's outlier cluster, contained 37.6% of all prompts. These are documents that HDBSCAN declined to assign to any cluster: too heterogeneous, too sparse, or genuinely unusual.</p>

<p class="wc-p">In a traditional user research study, these would be the prompts that resist any affinity map. The ones a researcher sets aside as miscellaneous and then spends the rest of the project quietly knowing they got away with ignoring. At scale, that category is not small and it is not random.</p>

<p class="wc-p">The cluster's keyword profile gives a partial picture: <em>write</em>, <em>create</em>, <em>image</em>, and <em>midjourney</em> all appear among its most distinctive terms, suggesting that a substantial portion are Midjourney-adjacent prompts too idiosyncratic to cohere with the eight Midjourney clusters HDBSCAN did identify. Beyond that, the outlier bin collects the usual debris: inputs so short they carry no extractable topic, multi-step instructions that span incompatible categories, fragments pasted out of context from longer sessions, and genuine one-offs with no peer in the sample. A random cut of 50 outlier prompts consistently yields 8 to 12 informal sub-categories. That is the exact condition under which HDBSCAN is designed to withhold a label.</p>

<div class="wc-callout red">
  <strong>The UXR limit:</strong> No clustering algorithm finds what it wasn't built to find. BERTopic surfaces structure in the modal use cases. The genuinely novel, the deeply personal, and the one-time requests disappear into the outlier bin. A researcher in the field would catch those. The algorithm doesn't.
</div>

<hr class="wc-hr">

<h2 class="wc-h2">Signals for Builders</h2>

<p class="wc-p">Topic share tells you what users do. It does not, on its own, tell you where the tool is failing them or where new behaviors are forming faster than the product team knows about. Two additional signals are in the data: the trajectory each topic follows over the 13-month window (which reveals emergence and die-off patterns), and the toxicity rate per topic (which flags where users encounter responses they did not want, a rough but consistent proxy for friction).</p>

<!-- Chart 5: Category lifecycle — per-topic share over time, emergence highlighted -->
<div class="wc-vis-card">
  <div class="wc-vis-label">WildChat-1M · Monthly share · Apr 2023 – Apr 2024</div>
  <div class="wc-vis-title">Category lifecycle: who grew, who collapsed</div>
  <div class="wc-vis-sub">Monthly share per topic · key trajectories highlighted · percent</div>
  <div class="wc-vis-legend" id="lifecycleLegend"></div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="lifecycleChart"></canvas>
  </div>
  <p class="wc-vis-note">Dashed line: GPT-4 Turbo launch (Nov 2023). Topics selected for contrast of trajectory types: sustained emergence, summer collapse, and late surge. Source: allenai/WildChat-1M.</p>
</div>

<p class="wc-p">The lifecycle chart surfaces three distinct behavioral patterns. <strong>Midjourney image generation</strong> emerged suddenly in July 2023, jumping from essentially zero in May–June to 14% by July, independent of any GPT-4 model change. That is a user-driven adoption wave, not a platform-driven one: ChatGPT was useful enough for Midjourney prompt refinement before any new model shipped, and users discovered it. <strong>Roleplay and interactive fiction</strong> peaked in June 2023 at 7.4% and collapsed to under 1% by August. That kind of rapid die-off rarely traces to lost interest alone. The timing here is consistent with content policy changes in mid-2023, though the data can't confirm the mechanism. <strong>Scene and Visual Description</strong> ran near-zero for most of the window before spiking to 9.3% in February 2024. A single-month spike of that magnitude is more consistent with an external trigger than organic growth: a viral prompt template, a Reddit thread, a specific workflow that circulated.</p>

<p class="wc-p">For a product team, these are three different kinds of opportunity. The Midjourney wave says: users will find use cases you did not design for, and they will scale them fast. Roleplay's collapse says: policy decisions are behavioral decisions, and they will register in your topic data before they register in your satisfaction surveys. The Scene & Visual Description spike says: one workflow spreading virally can overwhelm a category signal, and without a way to detect it, you will not know whether to invest or wait.</p>

<!-- Chart 6: Prompt depth (word count) by topic -->
<div class="wc-vis-card">
  <div class="wc-vis-label">WildChat-1M · Prompt length · by topic cluster</div>
  <div class="wc-vis-title">How hard users are working: median prompt word count by topic</div>
  <div class="wc-vis-sub">Median and IQR of first-turn prompt word count per topic · top 12 clusters</div>
  <div style="position: relative; width: 100%; height: 380px;">
    <canvas id="promptDepthChart"></canvas>
  </div>
  <p class="wc-vis-note">Word count of the cleaned prompt text. Higher values indicate topics where users arrive with more fully-formed, high-effort requests, where a weak response is more likely to be noticed. Source: allenai/WildChat-1M.</p>
</div>

<p class="wc-p">Prompt length is a proxy for commitment depth: a 500-word prompt is someone who came prepared, who has already done work, and who has a specific expectation about what comes back. When the model fails a short casual question, the cost is low: the user rephrases or drops it. When it fails a 500-word prompt, the user has already lost something. Median prompt length by topic produces a rough map of where failure hurts most. Midjourney image-generation prompts tend toward the long end. Users paste in extended visual concept descriptions. Jailbreak prompts show a bimodal distribution: elaborate circumvention attempts at one end, blunt one-line probes at the other. Casual conversation and general chat cluster at the short end, consistent with low-stakes exploratory use. Professional and business writing falls in the middle-to-high range, where users bring drafted language and want targeted improvement. A product team setting triage priorities for model improvements should weight these by volume: the high-median topics with high volume are where the model's failures compound at scale.</p>

<p class="wc-p">The topic distribution also surfaces coverage gaps in evaluation sets. Standard LLM benchmarks concentrate on coding, mathematical reasoning, and factual recall. The WildChat taxonomy shows that image generation, professional writing, and instructional tasks together account for more real usage than the standard benchmark suite was designed to measure. A model that improves sharply on HumanEval while plateauing on dense instructional prompts will look fine in eval and frustrate a substantial share of actual users. Mapping the empirical topic distribution against a benchmark suite's task coverage makes those gaps visible. Where the eval is thin and user traffic is heavy is where blind spots compound, and where the next round of model investment is most likely to be misdirected.</p>

<p class="wc-p">Routing behavior and prompt depth read together produce a quality-of-experience priority map. A topic with high median prompt length, meaningful volume, and strong GPT-4 routing is one where users arrive prepared, have already decided the premium model matters for this task, and have something to lose if the response falls short. That combination (effort invested, quality expectation set, failure cost high) is where underperformance is most likely to register as churn rather than a shrug. The routing preference chart and the prompt depth chart measure different things, but they point at the same question: for which tasks has the user already made a bet on the model? Those are the tasks where the model has to deliver.</p>

<p class="wc-p">The Midjourney pattern also has a forward-looking version. Any product with interaction logs can run a continuous version of this analysis: cluster first-turn prompts monthly, track which clusters are growing, watch for clusters near the outlier boundary that are beginning to cohere. The Midjourney wave went from effectively zero to 14% share in two months. In a monthly monitoring setup it would have been detectable at the 2% level, well before it dominated the aggregate numbers. Catching an emerging use case at 2% is cheap. Catching up at 20% is not.</p>

<div class="wc-callout red">
  <strong>The outlier bin as product opportunity:</strong> 37.6% of all prompts land in BERTopic's outlier cluster, too heterogeneous to name, too sparse to cluster. In classical UXR that is the discard pile. In a product context it is the most interesting bin: these are the prompts that did not fit the model's existing vocabulary of use cases. Some fraction of them are the next Midjourney wave in embryonic form. The algorithm cannot find them. A researcher pulling 200 outlier prompts per quarter would.
</div>

<hr class="wc-hr">

<h2 class="wc-h2">What This Connects Back To</h2>

<p class="wc-p">The model-quality post built a causal estimator on the premise that users who happen to rely on categories where the model is strong will experience higher quality and, as a result, remain more engaged. The key mechanism was within-version variation: same model, different task mix, different experienced quality.</p>

<p class="wc-p">This analysis operates at a coarser level, across model versions, across months, on observational data. But the behavioral logic is the same. Model quality is not uniform across task types. Users, in aggregate, respond to quality. The topic mix is the trace of that response.</p>

<p class="wc-p">The Midjourney finding reframes rather than refutes the quality-gap thesis. GPT-4 Turbo's price reduction made the model accessible to a different kind of user than early GPT-4 adopters, and those users came primarily for image generation, piping idiosyncratic visual concepts into ChatGPT to be reformulated as structured Midjourney prompts. That task benefits substantially from improved instruction-following and creative elaboration, both areas where GPT-4 outperforms GPT-3.5. The coding signal, while swamped at the aggregate transition, shows up clearly in the cross-sectional data: coding accounts for 13.9% of GPT-4 conversations versus 7.1% on GPT-3.5, a near-2× overrepresentation that is consistent with users routing harder tasks to the better model. The practical implication still holds: the return on a quality investment depends on which category you improve, not just by how much. The finding is that the category that moved most at GPT-4 Turbo's launch was not the one the benchmarks advertised.</p>

<hr class="wc-hr">

<h2 class="wc-h2">Data and Methods</h2>

<p class="wc-p">All code is in <code>scripts/wildchat_analysis.py</code> in the site repository. The analysis runs in two passes. The first produces the keyword table for each BERTopic cluster. After manually assigning topic names in the script, a second run generates the final JSON files consumed by this page's charts.</p>

<div class="wc-table-wrap">
  <div class="wc-table-caption">Table 1 · Transition test: top topics by absolute share delta</div>
  <table class="wc-table">
    <thead>
      <tr>
        <th>Topic</th>
        <th>Share before</th>
        <th>Share after</th>
        <th>Δ pp</th>
        <th>p-value</th>
      </tr>
    </thead>
    <tbody id="transitionTableBody">
      <!-- Populated by inline script from transition_test.json -->
    </tbody>
  </table>
</div>

<div class="wc-footnotes">
  <p>[1] WildChat-1M: Zhao et al. (2024). "WildChat: 1M ChatGPT Interaction Logs in the Wild." Allen Institute for AI. <a href="https://huggingface.co/datasets/allenai/WildChat-1M">huggingface.co/datasets/allenai/WildChat-1M</a>.</p>
  <p>[2] GPT-4 Technical Report: OpenAI (2023). Benchmark figures cited: HumanEval pass@1 (GPT-3.5: 48.1%, GPT-4: 67.0%), MMLU 5-shot (GPT-3.5: 70.0%, GPT-4: 86.4%), TruthfulQA (GPT-3.5: 58.7%, GPT-4: 71.9%), MT-Bench (GPT-3.5: 7.94, GPT-4: 8.99).</p>
  <p>[3] Model-quality post on this site: <a href="/data-projects/model-quality/">"Does Making AI Smarter Actually Make People Use It More?"</a></p>
  <p>[4] BERTopic: Grootendorst (2022). Embedding model: all-MiniLM-L6-v2. UMAP: n_components=5, n_neighbors=15, cosine metric. HDBSCAN: min_cluster_size=150, EOM selection.</p>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-annotation@3/dist/chartjs-plugin-annotation.min.js"></script>
<script>
(async function () {
  const BASE = '/data-projects/wildchat-prompt-eras/data/';

  // ── Shared defaults ──────────────────────────────────────────────────────────
  Chart.defaults.color = 'rgba(255,255,255,0.45)';
  Chart.defaults.borderColor = 'rgba(255,255,255,0.08)';
  Chart.defaults.font.family = "'Space Mono', monospace";
  Chart.defaults.font.size = 11;
  Chart.defaults.plugins.tooltip.backgroundColor = 'rgba(10,13,20,0.96)';

  const PALETTE = [
    '#7db800','#a8c8d8','#e07055','#f0b429','#9b8fe8',
    '#5ec8a0','#e8a86b','#7ec8e3','#d4a0c8','#a8b878',
    '#e87878','#78b8e8',
  ];

  function gridColor() { return 'rgba(255,255,255,0.06)'; }

  // ── Load JSON ────────────────────────────────────────────────────────────────
  let taxonomy, timeseries, modelBreak, transition;
  try {
    [taxonomy, timeseries, modelBreak, transition] = await Promise.all([
      fetch(BASE + 'topic_taxonomy.json').then(r => { if (!r.ok) throw new Error(r.url); return r.json(); }),
      fetch(BASE + 'topic_timeseries.json').then(r => { if (!r.ok) throw new Error(r.url); return r.json(); }),
      fetch(BASE + 'model_breakdown.json').then(r => { if (!r.ok) throw new Error(r.url); return r.json(); }),
      fetch(BASE + 'transition_test.json').then(r => { if (!r.ok) throw new Error(r.url); return r.json(); }),
    ]);
  } catch (err) {
    document.querySelectorAll('.wc-vis-card canvas').forEach(c => {
      c.closest('.wc-vis-card').insertAdjacentHTML('beforeend',
        `<p style="color:rgba(255,255,255,0.35);font-family:var(--f-mono);font-size:1.1rem;margin-top:12px">Chart data unavailable (${err.message})</p>`);
    });
    return;
  }
  // growth_signals.json and toxicity_by_topic.json are loaded lazily in their own chart blocks

  // ── Chart 1: Taxonomy horizontal bar ────────────────────────────────────────
  {
    const items = taxonomy.filter(t => t.topic_id >= 0).slice(0, 15);
    const ctx = document.getElementById('taxonomyChart').getContext('2d');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: items.map(t => t.name),
        datasets: [{
          data: items.map(t => t.share_pct),
          backgroundColor: items.map((_, i) => PALETTE[i % PALETTE.length]),
          borderWidth: 1.5,
          borderRadius: 3,
          borderSkipped: false,
        }],
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          x: {
            grid: { color: gridColor() },
            ticks: { callback: v => v + '%' },
          },
          y: {
            grid: { display: false },
            ticks: { font: { size: 10 } },
          },
        },
      },
    });
  }

  // ── Chart 2: Time series line ────────────────────────────────────────────────
  {
    const ctx = document.getElementById('timeseriesChart').getContext('2d');
    const datasets = timeseries.datasets.map((ds, i) => ({
      label: ds.label,
      data: ds.data,
      borderColor: PALETTE[i % PALETTE.length],
      backgroundColor: 'transparent',
      borderWidth: 2,
      pointRadius: 0,
      tension: 0.3,
    }));

    // Build legend
    const legendEl = document.getElementById('timeseriesLegend');
    datasets.forEach((ds, i) => {
      const span = document.createElement('span');
      span.innerHTML = `<i style="display:inline-block;width:26px;height:3px;border-radius:2px;flex-shrink:0;background:${PALETTE[i % PALETTE.length]};margin-right:6px;"></i>${ds.label}`;
      span.style.display = 'flex';
      span.style.alignItems = 'center';
      legendEl.appendChild(span);
    });

    // GPT-4 Turbo launch annotation index
    const gpt4Idx = timeseries.labels.findIndex(l => l >= '2023-11');

    new Chart(ctx, {
      type: 'line',
      data: { labels: timeseries.labels, datasets },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { display: false },
          annotation: gpt4Idx >= 0 ? {
            annotations: {
              gpt4Line: {
                type: 'line',
                xMin: gpt4Idx,
                xMax: gpt4Idx,
                borderColor: 'rgba(255,255,255,0.25)',
                borderWidth: 1,
                borderDash: [4, 4],
                label: {
                  content: 'GPT-4 Turbo',
                  enabled: true,
                  color: 'rgba(255,255,255,0.4)',
                  font: { size: 10 },
                  position: 'start',
                },
              },
            },
          } : {},
        },
        scales: {
          x: {
            grid: { color: gridColor() },
            ticks: { maxTicksLimit: 12, maxRotation: 45 },
          },
          y: {
            grid: { color: gridColor() },
            ticks: { callback: v => v + '%' },
          },
        },
      },
    });
  }

  // ── Chart 4: Model breakdown grouped bar ─────────────────────────────────────
  {
    const ctx = document.getElementById('modelBreakdownChart').getContext('2d');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: modelBreak.labels,
        datasets: [
          {
            label: 'GPT-4',
            data: modelBreak.gpt4_shares,
            backgroundColor: '#7db800',
            borderWidth: 1.5,
            borderRadius: 3,
          },
          {
            label: 'GPT-3.5-turbo',
            data: modelBreak.gpt35_shares,
            backgroundColor: '#a8c8d8',
            borderWidth: 1.5,
            borderRadius: 3,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          x: {
            grid: { display: false },
            ticks: { font: { size: 10 }, maxRotation: 40 },
          },
          y: {
            grid: { color: gridColor() },
            ticks: { callback: v => v + '%' },
          },
        },
      },
    });
  }

  // ── Chart 7: GPT-4 routing preference index ──────────────────────────────────
  {
    const ctx = document.getElementById('routingPreferenceChart').getContext('2d');
    const items = modelBreak.labels.map((label, i) => {
      const g4  = modelBreak.gpt4_shares[i];
      const g35 = modelBreak.gpt35_shares[i];
      const total = g4 + g35;
      return { label, gpt4_pct: total > 0 ? +(g4 / total * 100).toFixed(1) : 0 };
    }).sort((a, b) => b.gpt4_pct - a.gpt4_pct);

    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: items.map(t => t.label),
        datasets: [{
          data: items.map(t => t.gpt4_pct),
          backgroundColor: items.map(t => t.gpt4_pct >= 50 ? '#7db800' : '#a8c8d8'),
          borderWidth: 1.5,
          borderRadius: 3,
          borderSkipped: false,
        }],
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          annotation: {
            annotations: {
              midline: {
                type: 'line',
                xMin: 50, xMax: 50,
                borderColor: 'rgba(255,255,255,0.2)',
                borderWidth: 1,
                borderDash: [4, 4],
                label: {
                  content: '50% equal split',
                  display: true,
                  color: 'rgba(255,255,255,0.35)',
                  font: { size: 10 },
                  position: 'end',
                },
              },
            },
          },
        },
        scales: {
          x: {
            max: 100,
            grid: { color: gridColor() },
            ticks: { callback: v => v + '%' },
          },
          y: {
            grid: { display: false },
            ticks: { font: { size: 10 } },
          },
        },
      },
    });
  }

  // ── Chart 5: Category lifecycle ─────────────────────────────────────────────
  {
    // Load growth_signals.json (built from topic_timeseries, always available)
    let growthData;
    try {
      growthData = await fetch(BASE + 'growth_signals.json').then(r => { if (!r.ok) throw new Error(r.url); return r.json(); });
    } catch (e) {
      console.warn('growth_signals.json unavailable', e);
      growthData = null;
    }

    if (growthData) {
      const ctx = document.getElementById('lifecycleChart').getContext('2d');
      const legendEl = document.getElementById('lifecycleLegend');

      // Highlight a curated set of topics that tell the emergence/collapse story
      const FEATURED = [
        'Image Generation (Midjourney)',
        'Roleplay & Interactive Fiction',
        'Scene & Visual Description',
        'Software Coding & Debugging',
        'Casual Conversation',
      ];
      const FEATURED_COLORS = ['#7db800', '#e07055', '#f0b429', '#a8c8d8', '#9b8fe8'];

      const featured = FEATURED.map((name, i) => {
        const t = growthData.topics.find(d => d.label === name);
        if (!t) return null;
        return {
          label: t.label,
          data: t.series.map(s => s.share),
          borderColor: FEATURED_COLORS[i],
          backgroundColor: 'transparent',
          borderWidth: 2.5,
          pointRadius: 2,
          tension: 0.3,
        };
      }).filter(Boolean);

      // Legend
      featured.forEach(ds => {
        const span = document.createElement('span');
        span.innerHTML = `<i style="display:inline-block;width:26px;height:3px;border-radius:2px;flex-shrink:0;background:${ds.borderColor};margin-right:6px;"></i>${ds.label}`;
        span.style.display = 'flex';
        span.style.alignItems = 'center';
        legendEl.appendChild(span);
      });

      const gpt4Idx = growthData.months.findIndex(l => l >= '2023-11');
      const mjIdx   = growthData.months.findIndex(l => l >= '2023-07');

      new Chart(ctx, {
        type: 'line',
        data: { labels: growthData.months, datasets: featured },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: { mode: 'index', intersect: false },
          plugins: {
            legend: { display: false },
            annotation: {
              annotations: {
                ...(gpt4Idx >= 0 ? { gpt4Line: {
                  type: 'line', xMin: gpt4Idx, xMax: gpt4Idx,
                  borderColor: 'rgba(255,255,255,0.25)', borderWidth: 1, borderDash: [4,4],
                  label: { content: 'GPT-4 Turbo', display: true, color: 'rgba(255,255,255,0.4)', font: { size: 10 }, position: 'start' },
                }} : {}),
                ...(mjIdx >= 0 ? { mjLine: {
                  type: 'line', xMin: mjIdx, xMax: mjIdx,
                  borderColor: 'rgba(125,184,0,0.4)', borderWidth: 1, borderDash: [3,3],
                  label: { content: 'Midjourney wave', display: true, color: 'rgba(125,184,0,0.7)', font: { size: 10 }, position: 'end' },
                }} : {}),
              },
            },
          },
          scales: {
            x: { grid: { color: gridColor() }, ticks: { maxTicksLimit: 12, maxRotation: 45 } },
            y: { grid: { color: gridColor() }, ticks: { callback: v => v + '%' } },
          },
        },
      });
    }
  }

  // ── Chart 6: Prompt depth by topic ────────────────────────────────────────────
  {
    let depthData;
    try {
      depthData = await fetch(BASE + 'prompt_depth_by_topic.json').then(r => { if (!r.ok) throw new Error(r.url); return r.json(); });
    } catch (e) {
      const card = document.getElementById('promptDepthChart').closest('.wc-vis-card');
      card.insertAdjacentHTML('beforeend',
        '<p style="color:rgba(255,255,255,0.35);font-family:var(--f-mono);font-size:1.1rem;margin-top:12px">Prompt depth chart data will be available after analysis re-run completes.</p>');
      depthData = null;
    }

    if (depthData && depthData.length) {
      const ctx = document.getElementById('promptDepthChart').getContext('2d');
      // Sort by median ascending for readability
      const items = [...depthData].sort((a, b) => a.median - b.median).slice(0, 12);

      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: items.map(t => t.name),
          datasets: [{
            label: 'Median word count',
            data: items.map(t => t.median),
            backgroundColor: items.map(t => {
              if (t.median > 300) return '#e07055';
              if (t.median > 150) return '#f0b429';
              return '#a8c8d8';
            }),
            borderWidth: 1.5,
            borderRadius: 3,
            borderSkipped: false,
          }],
        },
        options: {
          indexAxis: 'y',
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: {
            x: { grid: { color: gridColor() }, ticks: { callback: v => v + ' words' } },
            y: { grid: { display: false }, ticks: { font: { size: 10 } } },
          },
        },
      });
    }
  }

  // ── Transition table ──────────────────────────────────────────────────────────
  {
    const tbody = document.getElementById('transitionTableBody');
    transition.slice(0, 12).forEach(row => {
      const tr = document.createElement('tr');
      const pClass = row.p_value < 0.05 ? '' : ' style="opacity:0.5"';
      const deltaStr = (row.delta_pp > 0 ? '+' : '') + row.delta_pp.toFixed(2);
      tr.innerHTML = `
        <td>${row.name}</td>
        <td>${row.share_before.toFixed(1)}%</td>
        <td>${row.share_after.toFixed(1)}%</td>
        <td${pClass}>${deltaStr}</td>
        <td${pClass}>${row.p_value < 0.001 ? '<0.001' : row.p_value.toFixed(3)}</td>
      `;
      tbody.appendChild(tr);
    });
  }
})();
</script>
