# HISTORICAL — v1.0, SUPERSEDED BY XYN BLUEPRINT v2.0 Q14–Q20

This preserved contract is for decision provenance. The engineering-only/optional delegation language in this historical document is superseded by DECISIONS.md and operations/QUINELLA-ROUTING.md. Do not treat it as current policy.

# Xyn Multi-Runtime — Master Implementation Contract v1.0

**Frozen by owner:** 2026-10-29. **Implementation bundle:** v1.1.0. **Runtime release:** NOT YET VERIFIED.

## Owner decisions

| ID | Policy |
| --- | --- |
| Q1 | B — Hybrid Intelligent Routing: direct simple tasks, specialist complex tasks |
| Q2 | B — Canonical persona source with runtime-native adapters |
| Q3 | B — Distinct, natural, adaptive expressive personalities |
| Q4 | B — Governed specialist autonomy under sole orchestrator Ritsuka |
| Q5 | B — Native first, transparent capability-aware fallback |
| Q6 | B — Capability-graded full-system release |
| D2 | Ritsuka R1 = Quinella/Lena/Akane; Kotone K1 = Violet/Nijika/C.C.; Tamaki T2 = Cardinal/Shion/Yuki; other 18 unchanged |
| D3 | Preserve current Xyn / The Lion Guardian operating identity when reconciling the main SOUL |
| D4 | Isolated per-agent memory and explicit authorized sharing only |
| D5 | Default one lead specialist and up to two reviewers |
| D6 | Hermes v0.22.5 upgrade remains a separate workstream |
| D7 | No automatic Always Allow, risky actions require governed approval; backup/rollback |
| D8 | Ritsuka coordinates; Reika independent audit; Sae security; Kaname readiness; owner final release |

## Non-negotiable identity contract

All 21 profiles in `roster.json` have stable `profile` IDs and exactly three equal fictional *influences*. The original profiles speak as original working identities, not as source anime characters. Every canonical persona has `SOUL.md` (worldview/opinions/decision instincts/tensions/boundaries), `STYLE.md` (voice/reactions/anti-patterns), `ROLE.md` (responsibilities/scope/handoff), examples and influence analysis. The source material is authoritative. Generated formats are not independently editable.

The first thing to inspect during implementation is the *effective* loaded prompt, not just file existence. `SOUL.md` semantics must be present in each runtime, including its STYLE traits. Persona text can never elevate authorization, modify secret access, or claim native dispatch without evidence. An incorrect answer that sounds highly personalized is still incorrect.

## Native adapter capability contract

- **Hermes:** 20 specialist profiles and optional standalone Ritsuka profile. The default main Xyn SOUL must NOT be overwritten by the generated Ritsuka proposal; perform a reviewed merge only after inspecting the current main SOUL. Profile-aware `advanced-delegation` is independently gated and may be unsupported by the custom core.
- **AGY CLI:** 21 Markdown custom agents under `~/.gemini/config/agents`, with `mainAgent: true` for Ritsuka and `subagent: true` for specialists, plus optional global persona skills under `~/.gemini/antigravity-cli/skills`.
- **Antigravity IDE:** 21 skills under `~/.gemini/config/skills`. Skill discovery is not evidence of an independently running native subagent; classify actual runtime behavior, version and available custom agent facilities.
- **Codex:** 21 TOML agent definitions under `~/.codex/agents`. Root invocation of Ritsuka is a separate workflow and must not silently override all unrelated Codex chats. Subagent approvals/sandbox follow effective parent policy.

Execution modes: `NATIVE` with separate dispatch evidence, `DIRECT_PROFILE` with an explicit dedicated session, `ASSISTED` only the perspective used by the main agent, `UNAVAILABLE`, `FAILED`, `BLOCKED`. Treat `ASSISTED` as NOT equivalent to `NATIVE`. Do not cross-delegate to another runtime in v1.0.

## Dispatch and handoff

Ritsuka triages objective, complexity, risk, dependency and budget. Simple work is done directly. Complex work has one accountable lead and up to two independent reviewers by default. Specialist disagreement is captured rather than suppressed. Never override a critical security or review blocker by a majority vote. Handoff must report objective, source context, scope, allowed actions, real execution mode, findings, artifact references, tests performed, evidence, risks, unresolved owner decisions and actual status.

## Security and memory

Runtime policy and platform safety outrank task instructions, which outrank role contract, which outranks persona voice, which outranks retrieved material. No agent can self-approve broader tool access. Actions involving credentials, shared infrastructure, destructive deletion, merging, release and changing global config require the effective approval policy, with owner confirmation where mandated. Do not assume an English sentence in a prompt is enforcement. If a runtime has no required gate, stop or use a safe manual step. All credentials and unrelated private context are excluded from handoff. Memory remains per profile/session; cross-runtime information exchange must be explicit and authorized.

## Implementation phases

| Phase | Output | Gate |
| --- | --- | --- |
| P0 | Read-only baseline, hashes, safe archive/rollback | No unrecognized production writes; source changes separated from active config |
| P1 | Approved canonical source for 21 | Verified D2 and unique behavioral signatures |
| P2 | Reproducible generator / native adapters | Exact equality of compiled adapters; parser tests |
| P3 | Known-hash, backed-up deployment | Unknown targets preserved; report all conflicts |
| P4 | Hermes explicit profile / main SOUL reconciliation | Existing Xyn contract preserved; effective loading evidence |
| P5 | AGY custom-agent smoke tests | Distinct independent subagent output, evidence-backed |
| P6 | Antigravity IDE skill and capability tests | Skill loaded; native/assisted correctly classified |
| P7 | Codex custom-agent smoke tests | Spawn and sandbox inherited as documented |
| P8 | Reliability and governance tests | Zero critical failures and valid fallback |
| P9 | Rollback rehearsal | Full baseline restoration, exact SHA256 |
| P10 | Release candidate and owner approval | Gate matrix all applicable PASS, per-runtime capabilities recorded |

P0–P3 are provided by this bundle **in a guarded manner**, but executing the scripts on the laptop is required for actual deployment. P4–P10 cannot be marked PASS by offline package tests alone. Prior Hermes merge regression (`get_scratch_dir`) remains in a separate branch/worktree and MUST NOT be silently fixed by persona migrator.

## Acceptance criteria

- 21/21 canonical identities, SOUL/STYLE/ROLE/exemplars; all 84 identity-to-runtime mappings accounted for.
- At least 84 baseline identity activations (21 profiles x 4 runtime surfaces), or explicit platform limitation classification with no false native PASS.
- Five deeper behavioral cases per persona across representative viable environments: domain problem, disagreement, uncertainty, self-correction, cross-domain coordination.
- Personality fidelity: each of five dimensions scored 0–5 (identity, reasoning signature, voice, integrity, task relevance), mean >=4, no dimension below 3; assessor records real samples and evidence.
- Real native dispatch tests for all domains on native-capable runtimes. No synthetic or prompted persona roleplay counted as a separately spawned worker.
- Negative tests: owner Deny, escalation, unapproved write, prompt injection, memory boundary, failed subagent, malformed metadata and model downtime: **zero critical breaches**.
- Fallback must be accurately labeled; failures bounded; concurrency within runtime/model budget; no uncontrolled restart.
- Restore rehearsal in staging and exact hash comparison after rollback.
- Status reported per runtime: `READY NATIVE`, `READY ASSISTED`, `BLOCKED` or `UNVERIFIED`; none can be declared ready from file presence alone.
- Final release requires explicit owner go/no-go; Kaname assesses readiness, Reika verifies independently and Sae assesses security.

## Data-preserving cleanup policy

Do not treat similar folder names as proof of obsolescence. An exact unmodified copy of ZIP v1.0 can be archived into timestamped `XynPersonaBackups`; unknown, modified, or Git-based folders must be preserved. Existing runtime files may be replaced only when their SHA256 equals the exact v1.0 shipped artifact; new files may be added if absent. A modified file is a conflict and must be manually reconciled, not overwritten. The main Hermes SOUL, runtime memory, credentials, model/provider configuration, live source repo, global policies and running services are protected. Migration logs track each changed target; rollback must hash-check the current file before restoration.

## Stop conditions and owner decisions

Stop on unexpectedly changed Hermes branch/HEAD, source checksum mismatch, unsafe reparse point, incomplete rollback data, unknown user-modified file, missing authentication, invalid provider capability, failed governance test, or unauthorized action. Never conceal a partial or unverified result. User approval of this contract is not an approval to publish, merge or change secrets. Every high-impact deployment or release still requires a concrete, scoped authorization.
