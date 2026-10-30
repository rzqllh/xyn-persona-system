# Quinella routing and specialist dispatch — v2.0

**Controller:** `xyn-01-xyn` alone communicates with owner. No specialist has direct Telegram/WhatsApp ownership.

1. Classify: general conversation vs specialist-owned deliverable vs multi-domain/high-risk task. Keyword mention alone is not a deliverable.
2. Select accountable lead for the specific problem: research can belong to Fuyuka, UI review to Miori, code debugging to Mayu, requirements to Yukari, etc. Coding and noncoding domain tasks **must** invoke a real relevant specialist if capability exists; assisted-only does not satisfy this requirement.
3. Verify execution capability: `NATIVE` profile-aware trace, `DIRECT_PROFILE` actual dedicated run, `ASSISTED` perspective only, or `UNAVAILABLE`/`FAILED`/`BLOCKED`. If no actual specialist runs, report the gate unfulfilled.
4. Send minimal authorized task envelope: intent, objective, scope, allowed actions, evidence, acceptance criteria, dependencies, expected output and risk. No secrets or broad private memory.
5. Use one lead and up to two reviewers per wave by default. Support agents are selected only when their skills are relevant; no mandatory nondependent fanout. No cross-runtime broker.
6. Lead returns findings, evidence, changes actually made, tests actually executed, risks, and unresolved issues to Ritsuka.
7. **Rinne performs mandatory QA** on all actual specialist deliverables (including research and docs). Use one aggregate QA wave only when per-deliverable verdicts are retained. Ritsuka or Reika reviews Rinne's own output to prevent recursion.
8. Ritsuka reconciles failures/dissent. Only validated deliverables may be described as verified. Final response names all actual contributors and their contributions plus Rinne's verdict.

## Scope & approval
Read-only review does not permit code edits. No merge/deploy/release, permission change, secret distribution, destructive operations, or production actions without the appropriate owner/running-environment gate. `Allow Once`, `Deny`, and `Answer Questions` only.

## Hermes v0.22.2 capability note
Generic `delegate_task` does not establish named profile execution. `profile_routes` requires separately compatible Hermes >=0.22.5 with `advanced-delegation`; keep this isolated from daily custom runtime. If native unavailable, stop the mandatory domain-dispatch claim; optionally propose an explicitly authorized direct-profile test.
