"""Limited public-source preflight. Not a replacement for gitleaks/semgrep/osv-scanner."""
from __future__ import annotations
from pathlib import Path
import re,sys
ROOT=Path(__file__).resolve().parents[1]
BAD_BASENAMES={'.env','auth.json','config.yaml','MEMORY.md'}
SUFFIXES={'.md','.txt','.json','.py','.ps1','.toml','.yml','.yaml','.csv'}
PATTERNS=[
 ('private home path',re.compile(r'C:\\Users\\[^\\\s]+',re.I)),
 ('GitHub token',re.compile(r'gh[pousr]_[A-Za-z0-9]{20,}')),
 ('OpenAI style secret',re.compile(r'sk-(?:proj-)?[A-Za-z0-9_-]{24,}')),
 ('AWS access key',re.compile(r'AKIA[0-9A-Z]{16}')),
 ('private key content',re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----')),
]
EXCLUDE={'tools/scan_public_release.py'} # regex literals are patterns, not secrets
errors=[];scanned=0
for path in ROOT.rglob('*'):
 if not path.is_file():continue
 relative=path.relative_to(ROOT).as_posix()
 if '/.git/' in '/'+relative or '__pycache__' in path.parts: continue
 if path.name in BAD_BASENAMES or (path.suffix.lower() in {'.pem','.key'}):
  errors.append(f'Forbidden file: {relative}');continue
 if path.stat().st_size > 3_000_000: errors.append(f'Unexpected large file: {relative}');continue
 if path.suffix.lower() not in SUFFIXES or relative in EXCLUDE:continue
 try:contents=path.read_text('utf8')
 except UnicodeDecodeError:errors.append(f'Non-UTF8 source: {relative}');continue
 scanned+=1
 for label,regex in PATTERNS:
  if regex.search(contents): errors.append(f'{label}: {relative}')
 # obvious accidental credential assignment (not examples or empty variables)
 if path.suffix in {'.json','.toml','.yaml','.yml'}:
  if re.search(r'''(?:api_key|access_token|secret_key)\s*[=:]\s*["'](?:sk-|ghp_|AKIA)[A-Za-z0-9_-]{12,}''',contents,re.I):
   errors.append(f'Possible hardcoded credential: {relative}')
if errors:
 print('PUBLIC_PREFLIGHT_FAIL',len(errors))
 for v in errors[:30]:print(v)
 sys.exit(1)
print(f'PUBLIC_PREFLIGHT_PASS: scanned {scanned} source files, no high-confidence matches. Not a comprehensive secret scan.')
