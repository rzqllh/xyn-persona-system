"""Update release package hashes; does not inspect installed runtimes."""
import json,hashlib,pathlib
root=pathlib.Path(__file__).resolve().parents[1]
result={}
for f in sorted(root.rglob('*')):
 if not f.is_file(): continue
 p=f.relative_to(root).as_posix()
 if p=='MANIFEST.json' or any(x in f.parts for x in ('.git','__pycache__')):continue
 result[p]=hashlib.sha256(f.read_bytes()).hexdigest()
(root/'MANIFEST.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n',encoding='utf-8')
print('MANIFEST UPDATED:',len(result),'files')
