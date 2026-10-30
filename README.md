# XYN — Multi-Agent Persona & Orchestration

**Release candidate:** `v2.0.0-rc1` | **21 identities** | **4 adapter targets** | **Not yet production-validated**

XYN is an example architecture for a single AI controller (Ritsuka Xyn / Quinella) coordinating twenty specialist personas. Each specialist has an individually authored SOUL, STYLE, character-influence interpretation and explicit domain ROLE, with deterministic target adapters for Hermes Agent, Antigravity CLI / IDE and Codex.

This release candidate is intended for source review, learning and staged validation. It is **not** evidence of native subagent operation, live QA execution, successful deployment or publication on GitHub.

## How v2.0 works

- Chat with Ritsuka; ordinary conversation remains direct.
- Specialist-owned deliverables—research, UI audit, analysis, coding, requirements, security, documentation, etc.—require **actual** dispatch of a relevant specialist based on accountable domain. `ASSISTED` perspective-only mode does not satisfy the dispatch gate.
- Rinne validates **every** specialist output, including research and recommendations, with a recorded per-contribution verdict.
- Ritsuka reconciles the evidence, names each actual contributor and their specific contribution, and preserves dissent.
- An audit request is read-only; implementing code requires separate scope authorization.
- Owner approvals, profile isolation, runtime capabilities and release gates remain mandatory.

## Structure

- `personas/xyn-*/`: canonical 21× `SOUL.md`, `STYLE.md`, `ROLE.md`, `PERSONA.json`, influences, and calibration examples.
- `operations/`: routing, mobile reporting and task handoff schemas.
- `adapters/`: deterministic native-format outputs built from canonical sources.
- `tools/build_adapters.py`: `--check` to detect generated drift.
- `tools/scan_public_release.py`: conservative source/publication preflight (not a replacement for dedicated secret scanners).
- `tests/`: source consistency, compiler parity and governance contract tests.
- `Install-Xyn-v2.ps1`: default **dry-run**; `-Apply` only installs recognized adapter changes with backup, never the main SOUL.
- `Review-Xyn-MainSoul-v2.ps1`: independent explicit main-controller diff and guarded application.
- `Rollback-Xyn-v2.ps1`: restore from an installer journal, with hash verification.
- `docs/PUBLIC-RELEASE-CHECKLIST.md`: remaining gates before a stable public release.

## Verify locally

```powershell
python -m unittest discover -s tests -p 'test_*.py' -v
python tools/build_adapters.py --check
python tools/scan_public_release.py
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-Xyn-v2.ps1
```

**Do not run** `-Apply` before inspecting diff and ensuring backup/rollback readiness. Run migration only on a trusted, verified machine. Never paste model keys, service URLs containing credentials, or personal `SOUL.md` into a public repository.

## Runtime honesty

Hermes custom `v0.22.2` profile-aware native dispatch is **unverified**. Official `advanced-delegation` profile routes require Hermes `>=0.22.5`. Test a compatible build in separate staging; do not silently upgrade an existing custom runtime. AGY, IDE and Codex likewise need real discovery, loading, dispatch and QA tests. A skill directory is not a subagent.

## Public source release and licensing

**License: MIT**, approved by the project owner on 2026-10-30. This repository distributes original agent configuration, code and documentation, **not** any rights to anime properties referenced as personality inspiration. **Public source release ≠ production certification**. The `v2.0.0-rc1` prerelease is for learning, review, and staging, not evidence of native orchestration across all runtimes. See [`docs/PUBLIC-RELEASE-CHECKLIST.md`](docs/PUBLIC-RELEASE-CHECKLIST.md) and [`docs/RELEASE-NOTES-v2.0.0-rc1.md`](docs/RELEASE-NOTES-v2.0.0-rc1.md).

To publish safely, build a **clean new repository** from the release ZIP rather than pushing the developer's Hermes code, pre-existing XYN workspace Git history or private local runtime state. The companion PowerShell bootstrap is designed around the owner's local `Documents/Code/_sandbox/xyn-persona-system` workspace and builds the public repository as a sibling to avoid unrelated history.

## Acknowledgment

Original persona design draws selectively on three anime-character influences for each original XYN identity. XYN is not affiliated with the rights holders of those works. Character influences are used as behavioral references; no copyrighted character images or dialogue are bundled here.
