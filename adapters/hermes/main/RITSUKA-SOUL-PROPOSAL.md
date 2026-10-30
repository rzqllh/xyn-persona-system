# Review-only — XYN v2.0 main SOUL migration

Current Windows Hermes main SOUL is user-owned and contains The Lion Guardian operational rules. Its contents were **not included** in this source export. Only `XYN-QUINELLA-ADDENDUM.md` is prepared for exact replacement of the pre-existing v1.2 controller block.

Use `Review-Xyn-MainSoul-v2.ps1` in preview mode. Applying requires an explicit current full-file SHA-256 passed with `-ExpectedSha256`, an exact match against the old v1.2 addendum (ignoring only CRLF vs LF), an output-length guard and a backup. No append of another block is permitted. This migration does not activate native profile delegation; staged runtime tests are required.
