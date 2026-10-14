import re

with open(r'scenes/regions/verdant_ruins.tscn', 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.split('\n')

errors = []

# Collect ext_resource ids
ext_ids = set(re.findall(r'\[ext_resource .+? id="(.+?)"', content))
# Collect sub_resource ids
sub_ids = set(re.findall(r'\[sub_resource .+? id="(.+?)"', content))

# Check ExtResource references
for m in re.finditer(r'ExtResource\("(.+?)"\)', content):
    rid = m.group(1)
    if rid not in ext_ids:
        errors.append(f'Missing ext_resource: {rid}')

# Check SubResource references
for m in re.finditer(r'SubResource\("(.+?)"\)', content):
    rid = m.group(1)
    if rid not in sub_ids:
        errors.append(f'Missing sub_resource: {rid}')

# Check node hierarchy
nodes = set()
nodes.add('.')
root_match = re.search(r'\[node name="(.+?)" type=".+?"\]\n', content)
if root_match:
    nodes.add(root_match.group(1))

for m in re.finditer(r'\[node name="(.+?)" .+?parent="(.+?)"', content):
    name = m.group(1)
    parent = m.group(2)
    if parent == '.':
        full_path = name
    else:
        full_path = parent + '/' + name
    nodes.add(full_path)

# Verify parents exist
for m in re.finditer(r'\[node name="(.+?)" .+?parent="(.+?)"', content):
    name = m.group(1)
    parent = m.group(2)
    if parent != '.' and parent not in nodes:
        errors.append(f'Node "{name}" references nonexistent parent "{parent}"')

# Check for remaining # comment lines (invalid in TSCN)
for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if stripped.startswith('#'):
        errors.append(f'Line {i}: Invalid comment: {stripped[:60]}')

# Check for any lines starting with unexpected chars
for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if stripped and not stripped.startswith('[') and not stripped.startswith(';') and '=' not in stripped and not stripped.startswith('"') and not stripped.startswith('}'):
        # Could be a property continuation or valid value
        pass

if errors:
    print(f'Found {len(errors)} errors:')
    for e in errors:
        print(f'  - {e}')
else:
    print('No errors found! TSCN structure is valid.')

print(f'\nStats: {len(ext_ids)} ext_resources, {len(sub_ids)} sub_resources, {len(nodes)-1} nodes')
