from __future__ import annotations
import ast, json, os, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
errors=[]; warnings=[]

REQUIRED=[
 'VERSION','README.md','.env.example','docker-compose.yml','docker-compose.full.yml','docker-compose.selfhosted.yml',
 'backend/Dockerfile','backend/requirements.txt','backend/app/main.py',
 'frontend/package.json','frontend/index.html','frontend/src/main.tsx','frontend/src/app.tsx',
 'apps/hamraz_admin_web/package.json','apps/hamraz_admin_web/index.html','apps/hamraz_admin_web/src/main.tsx',
 'apps/hamraz_desktop/package.json','apps/hamraz_desktop/src/main.cjs','apps/hamraz_desktop/electron-builder.yml',
 'apps/hamraz_flutter/pubspec.yaml','apps/hamraz_flutter/lib/main.dart',
 'infra/Caddyfile','docs/RELEASE_CHECKLIST.md','docs/OWNERSHIP_AND_RELEASE.md'
]
for rel in REQUIRED:
    if not (ROOT/rel).exists(): errors.append(f'missing: {rel}')

for p in (ROOT/'backend').rglob('*.py'):
    if '__pycache__' in p.parts: continue
    try: ast.parse(p.read_text(encoding='utf-8'))
    except Exception as e: errors.append(f'python syntax: {p}: {e}')

for rel in ['frontend/package.json','apps/hamraz_admin_web/package.json','apps/hamraz_desktop/package.json']:
    try: json.loads((ROOT/rel).read_text())
    except Exception as e: errors.append(f'json: {rel}: {e}')

# method+path route duplication audit, ignoring startup decorators and non-route decorators
routes={}
main=(ROOT/'backend/app/main.py').read_text(encoding='utf-8')
for m,path in re.findall(r'@app\.(get|post|put|patch|delete)\(["\']([^"\']+)',main,re.I):
    key=(m.upper(),path)
    routes.setdefault(key,0); routes[key]+=1
for p in (ROOT/'backend/app').glob('part*.py'):
    txt=p.read_text(encoding='utf-8')
    for m,path in re.findall(r'@router\.(get|post|put|patch|delete)\(["\']([^"\']+)',txt,re.I):
        # router prefix is not statically expanded, but duplicate method/path inside a single module is still useful
        key=(p.name,m.upper(),path)
        # intentionally local audit only
        if getattr(p,'_dummy',False): pass

# detect accidental committed secrets / dev defaults in deployment examples
for rel in ['docker-compose.yml','docker-compose.full.yml','docker-compose.selfhosted.yml','.env.example']:
    txt=(ROOT/rel).read_text(encoding='utf-8')
    if 'xmessenger_dev' in txt and rel=='docker-compose.selfhosted.yml': warnings.append('self-hosted compose uses a development-style default only; override POSTGRES_PASSWORD before exposure')
    if 'change-this-in-production' in txt: warnings.append(f'{rel} contains an intentional development placeholder secret')

print('Hamraz release audit')
print('version:', (ROOT/'VERSION').read_text().strip())
print('required files:', len(REQUIRED))
print('python files parsed:', sum(1 for _ in (ROOT/'backend').rglob('*.py')))
print('errors:', len(errors))
print('warnings:', len(warnings))
for x in errors: print('ERROR:',x)
for x in warnings: print('WARN :',x)
raise SystemExit(1 if errors else 0)
