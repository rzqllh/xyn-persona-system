# GitHub publication — XYN v2.0.0-rc1

**Owner-approved GitHub location:** `rzqllh/xyn-persona-system` (new public repository). **License:** MIT. **Publishable label:** source prerelease `v2.0.0-rc1` only. Stable `v2.0.0` remains blocked on runtime and rollback evidence.

The GitHub connector currently available in this session cannot create a new repository. The one-time Windows command in `Finish-XYN-v2.0-RC1.ps1` (distributed alongside the ZIP) can publish the clean prerelease through a GitHub CLI login when the owner runs it. Check `gh auth status` first; the expected authenticated account is `rzqllh`. The script refuses an existing remote repo, does not force-push, and will not reuse or publish the workspace's prior Git history.

## Workflow

1. Keep the real development workspace at `~/Documents/Code/_sandbox/xyn-persona-system` unchanged.
2. Verify package hash, manifests, Python unit tests, generated adapters and basic public-source scan.
3. Extract into a clean **sibling** staging directory within `Code/_sandbox`.
4. Check GitHub CLI authentication and the absence of `rzqllh/xyn-persona-system`.
5. Create a new local Git history from the source-only RC and publish that repository with GitHub CLI.
6. Create `v2.0.0-rc1` as a **prerelease**, not a stable release, with explicit limitations.
7. Test four runtime activations on user-controlled infrastructure and complete mandatory Rinne QA and rollback drill before stable tagging.

Source release does not grant approval to modify production systems or run installation against Hermes daily runtime. The companion bootstrap has separate preview and `-Publish` modes.
