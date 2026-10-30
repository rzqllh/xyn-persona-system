"""XYN v2.0 deterministic compiler: canonical persona content -> native adapter files.

Does not access credentials, networks, installed runtimes or user configuration.
"""
from __future__ import annotations
import argparse, hashlib, json, pathlib, sys, tomllib
ROOT=pathlib.Path(__file__).resolve().parents[1]

def content_files():
    for fp in sorted((ROOT/'personas').glob('xyn-*/PERSONA.json')):
        d=fp.parent; name=d.name
        persona=json.loads(fp.read_text(encoding='utf-8'))
        soul=(d/'SOUL.md').read_text(encoding='utf-8')
        style=(d/'STYLE.md').read_text(encoding='utf-8')
        role=(d/'ROLE.md').read_text(encoding='utf-8')
        # Hermes loads SOUL automatically, not arbitrary STYLE/ROLE files.
        hermes_soul=soul+'\n\n<!-- XYN GENERATED ROLE/STYLE BEGIN -->\n'+role+'\n'+style+'\n<!-- XYN GENERATED ROLE/STYLE END -->\n'
        yield pathlib.Path('adapters/hermes/profiles')/name/'SOUL.md',hermes_soul
        yield pathlib.Path('adapters/hermes/profiles')/name/'STYLE.md',style
        yield pathlib.Path('adapters/hermes/profiles')/name/'ROLE.md',role
        skill_dir=pathlib.Path('adapters/antigravity/skills')/('persona-'+name)
        for label,source in [('SOUL.md',soul),('STYLE.md',style),('ROLE.md',role)]:
            yield skill_dir/label,source
        # Skills are guidance, not a claim of native isolated subagent.
        desc=persona['role'].replace(':',' -').strip()
        lines=[
            '---',f'name: persona-{name}',
            f'description: Apply {persona["display_name"]} procedures for {desc} tasks under approved scope.',
            '---','','# '+persona['display_name']+' — task procedure',
            'This is a *skill*, not evidence that a separate subagent ran.',
            'Load the accompanying ROLE.md for dispatch criteria; SOUL.md and STYLE.md for persona continuity.',
            '', '## Procedure',
            '1. Verify the actual task objective, available evidence, approved scope and effective permissions.',
            '2. Decide whether this domain is accountable; return mismatched tasks to Ritsuka.',
            '3. Perform the domain-specific procedure defined by ROLE.md and make no outside-scope changes.',
            '4. Report actual findings, source references, changes and tests; separate observation from inference.',
            '5. Send deliverable to Ritsuka for mandatory Rinne QA. Do not claim a PASS before receiving the verdict.',
            '', '## Domain trigger', '- '+str(persona['semantic_signals']['first']),
            '', '## QA focus','- '+str(persona['semantic_signals']['distrust']),
            ''
        ]
        yield skill_dir/'SKILL.md','\n'.join(lines)
        # Keep existing AGY metadata flags, no new permission grants.
        a=ROOT/'adapters/antigravity/agents'/f'{name}.md'
        current=a.read_text(encoding='utf-8')
        parts=current.split('---',2)
        if len(parts)!=3: raise ValueError('AGY YAML frontmatter missing: '+name)
        flags=parts[1]
        # replace only description so runtime metadata stays intact
        revised=[]
        for line in flags.strip('\n').splitlines():
            if line.startswith('description:'):
                line='description: '+persona['display_name']+' — '+desc+'. Route specialist-owned domain deliverables here, including noncoding analysis; actual dispatch and Rinne QA are required.'
            revised.append(line)
        ag='---\n'+'\n'.join(revised)+'\n---\n\n'+soul+'\n\n'+style+'\n\n'+role
        yield pathlib.Path('adapters/antigravity/agents')/f'{name}.md',ag
        description=persona['display_name']+' — '+desc+'. Call for specialist-owned tasks including noncoding research/review; real dispatch required, then Rinne QA. Never infer execution from file presence.'
        developer='\n\n'.join((soul,style,role))
        # JSON string escaping is valid TOML for these Unicode values.
        toml='name = '+json.dumps(name)+'\n'+'description = '+json.dumps(description,ensure_ascii=False)+'\n'+'developer_instructions = '+json.dumps(developer,ensure_ascii=False)+'\n'
        yield pathlib.Path('adapters/codex/agents')/f'{name}.toml',toml

def main(argv=None):
    arg=argparse.ArgumentParser()
    arg.add_argument('--check',action='store_true',help='verify generated adapters without writing')
    args=arg.parse_args(argv)
    expected=dict(content_files())
    errors=[]
    for path,txt in expected.items():
        target=ROOT/path
        if args.check:
            if not target.exists() or target.read_text(encoding='utf-8')!=txt:
                errors.append(path.as_posix())
        else:
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_text(txt,encoding='utf-8',newline='\n')
    if errors:
        print('DRIFT: '+str(len(errors))+' adapters mismatch\n'+'\n'.join(errors[:15]))
        return 1
    print(('VERIFY' if args.check else 'BUILT')+' '+str(len(expected))+' deterministic adapters')
    return 0
if __name__=='__main__': sys.exit(main())
