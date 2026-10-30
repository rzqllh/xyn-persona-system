# Orchestration contract v2.0 — reference architecture

`Owner → Ritsuka/controller → accountable specialist(s) → Rinne/mandatory QA → Ritsuka synthesis → Owner`.

**Q15 precedence:** the specialist trigger is mandatory for a clear specialist-owned domain deliverable, even when analysis is simple or noncoding. Q1's earlier notion of direct handling remains valid only for ordinary questions without a specialist-owned deliverable. If dispatch is not available, report BLOCKED or UNAVAILABLE; `ASSISTED` is not a substitute for a real specialist.

**QA ordering:** Rinne receives the original objective, acceptance criteria and evidence from each actual contributor. Aggregate QA is allowed only with per-contribution verdicts. A Rinne-authored work product is independently reviewed by Ritsuka or Reika as appropriate to avoid self-approval and review loops.

**Explicitly not supported in this package:** runtime task broker, live cross-runtime execution, automatic Hermes version upgrades, model/provider changes, messaging gateway replication, direct specialist messages to owner, owner approval emulation, guaranteed parallel execution.

Tasks should use `operations/task-envelope.schema.json` and `operations/qa-verdict.schema.json` as documentation/validation schema, while the native runtime remains the execution authority.
