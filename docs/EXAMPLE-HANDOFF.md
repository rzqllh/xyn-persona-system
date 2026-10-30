# XYN v2.0 task handoff — synthetic example only

The following is an illustrative task envelope. **No agent invocation or QA has actually occurred.**

```json
{
  "task_id": "XYN-DEMO-001",
  "owner_request": "Review UI; do not edit source",
  "controller": "xyn-01-xyn",
  "lead": "xyn-04-des",
  "support": [],
  "qa": "xyn-13-test",
  "runtime": "hermes",
  "execution": {
    "mode": "UNVERIFIED",
    "scope": "read_only",
    "status": "PLANNED",
    "dispatch_evidence": []
  },
  "objective": "Evaluate UI hierarchy and interaction clarity",
  "acceptance_criteria": [
    "Recommendations cite provided screens and evidence",
    "No implementation or file edits",
    "Rinne issues QA verdict per deliverable"
  ],
  "evidence": [],
  "changes": [],
  "risks": ["Native routing unverified"],
  "owner_approvals": []
}
```

Expected sequence, if supported and authorized: Ritsuka classifies → real Miori session executes read-only review → Rinne examines original task and evidence → Ritsuka summarizes and names actual contributors. If dispatch fails, the task remains blocked and the final answer must not claim Miori/Rinne executed.
