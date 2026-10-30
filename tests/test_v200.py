import unittest,pathlib,json,subprocess,sys,hashlib,tomllib,re
ROOT=pathlib.Path(__file__).resolve().parents[1]
FIELDS=('accountable_domain','delegate_when','do_not_delegate_when','inputs_required','allowed_operations','approval_escalations','outputs_required','acceptance_criteria','handoff_targets','independent_review_requirements')
class V200(unittest.TestCase):
 def people(self):return sorted((ROOT/'personas').glob('xyn-*/PERSONA.json'))
 def test_roster_complete_dna_and_unique_names(self):
  p=self.people();self.assertEqual(len(p),21)
  d=[json.loads(x.read_text('utf8')) for x in p]
  self.assertEqual(len({x['profile'] for x in d}),21)
  self.assertEqual(len({x['display_name'] for x in d}),21)
  for x in d:
   self.assertEqual(x['canonical_version'],'2.0.0-rc1')
   self.assertEqual(len(x['dna']),3)
   self.assertEqual(x['mandatory_qa'],'xyn-13-test')
   self.assertEqual(x['routing_policy'],'skill_based_mandatory')
  self.assertIn('Akane Tsunemori',' '.join(d[0]['dna']))
  self.assertIn('C.C.',' '.join(d[5]['dna']))
  self.assertIn('Shion Karanomori',' '.join(d[7]['dna']))
 def test_role_contracts_explicit_and_unique(self):
  roles=[]
  for p in self.people():
   text=(p.parent/'ROLE.md').read_text('utf8');roles.append(text)
   for key in FIELDS:self.assertIn('## '+key,text,p.parent.name)
   for key in ('delegate_when','do_not_delegate_when','outputs_required','independent_review_requirements'):
    content=text.split('## '+key+'\n')[1].split('\n## ')[0]
    self.assertGreater(len(content.strip()),18,p.parent.name)
   self.assertIn('xyn-13-test',text)
  self.assertEqual(len(set(roles)),21)
  self.assertIn('all specialist',roles[12].lower())
 def test_q14_20_decision_precedence(self):
  ledger=(ROOT/'DECISIONS.md').read_text('utf8')
  for q in range(14,21):self.assertIn(f'Q{q}',ledger)
  self.assertIn('SUPERSEDED',ledger)
  operations=(ROOT/'operations/QUINELLA-ROUTING.md').read_text('utf8')
  self.assertIn('Rinne',operations)
  self.assertIn('noncoding',operations)
  self.assertIn('ASSISTED',operations)
  self.assertIn('read-only',operations.lower())
 def test_main_soul_and_addendum_replace_old_logic(self):
  s=(ROOT/'personas/xyn-01-xyn/SOUL.md').read_text('utf8')
  self.assertIn('requires dispatch of at least one',s)
  self.assertNotIn('For non-engineering conversation',s)
  self.assertIn('Every actual specialist output',s)
  add=(ROOT/'adapters/hermes/main/XYN-QUINELLA-ADDENDUM.md').read_text('utf8')
  self.assertIn('v2.0.0 BEGIN',add)
  self.assertNotIn('v1.2.0 BEGIN',add)
 def test_generated_adapters_all_in_sync(self):
  p=subprocess.run([sys.executable,str(ROOT/'tools/build_adapters.py'),'--check'],cwd=ROOT,capture_output=True,text=True)
  self.assertEqual(p.returncode,0,p.stdout+p.stderr)
  self.assertIn('189',p.stdout)
 def test_role_loaded_effectively_or_proven_skill_only(self):
  for p in self.people():
   name=p.parent.name
   role=(p.parent/'ROLE.md').read_text('utf8')
   soul=(p.parent/'SOUL.md').read_text('utf8')
   style=(p.parent/'STYLE.md').read_text('utf8')
   ag=(ROOT/'adapters/antigravity/agents'/f'{name}.md').read_text('utf8')
   cx=tomllib.loads((ROOT/'adapters/codex/agents'/f'{name}.toml').read_text('utf8'))
   hermes=(ROOT/'adapters/hermes/profiles'/name/'SOUL.md').read_text('utf8')
   skill=(ROOT/'adapters/antigravity/skills'/('persona-'+name)/'SKILL.md').read_text('utf8')
   for x in (ag,cx['developer_instructions'],hermes):
    self.assertIn(role,x)
    self.assertIn(soul,x)
    self.assertIn(style,x)
   self.assertIn('not evidence',skill)
  # ROOT Hermes is user-owned, not installed automatically.
  self.assertNotIn('Copy-Item -LiteralPath $newPath -Destination $soul', (ROOT/'Install-Xyn-v2.ps1').read_text('utf8'))
 def test_role_selection_and_qa_schema(self):
  envelope=json.loads((ROOT/'operations/task-envelope.schema.json').read_text('utf8'))
  qa=json.loads((ROOT/'operations/qa-verdict.schema.json').read_text('utf8'))
  self.assertEqual(envelope['properties']['qa']['const'],'xyn-13-test')
  self.assertEqual(qa['properties']['qa_agent']['const'],'xyn-13-test')
  self.assertEqual(len(qa['properties']['contributions']['items']['properties']['verdict']['enum']),5)
 def test_baseline_manifest_integrity(self):
  for name in ('MANIFEST.json','BASELINE-V1.2-SHA256.json'):
   self.assertTrue((ROOT/name).exists())
  m=json.loads((ROOT/'MANIFEST.json').read_text('utf8'))
  self.assertGreater(len(m),350)
  for rel,h in m.items():
   self.assertEqual(hashlib.sha256((ROOT/rel).read_bytes()).hexdigest(),h,rel)
 def test_public_source_preflight(self):
  proc=subprocess.run([sys.executable,str(ROOT/'tools/scan_public_release.py')],cwd=ROOT,capture_output=True,text=True)
  self.assertEqual(proc.returncode,0,proc.stdout+proc.stderr)
 def test_runtime_truth_and_approval(self):
  op=(ROOT/'operations/QUINELLA-ROUTING.md').read_text('utf8')
  for text in ('NATIVE','DIRECT_PROFILE','ASSISTED','UNAVAILABLE','Rinne','Owner','approval','profile_routes'):
   self.assertIn(text.lower(),op.lower())
  installer=(ROOT/'Install-Xyn-v2.ps1').read_text('utf8')
  self.assertIn('[switch]$Apply',installer)
  self.assertIn('CONFLICT_MODIFIED',installer)
  self.assertIn('backupRoot',installer)
if __name__=='__main__':unittest.main()
