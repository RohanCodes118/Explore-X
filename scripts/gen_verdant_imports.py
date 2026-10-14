import os, hashlib, uuid

assets = [
    'verdant_ruins_floor',
    'verdant_cliff_wall',
    'verdant_ruins_tree',
    'verdant_water_pool',
    'verdant_stone_pillar',
    'verdant_fern_cluster',
    'verdant_ruin_gate',
    'verdant_ruin_block',
    'verdant_guardian',
]

env_dir = 'assets/images/env'

TEMPLATE = """[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://{uid}"
path="res://.godot/imported/{name}.png-{md5}.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://assets/images/env/{name}.png"
dest_files=["res://.godot/imported/{name}.png-{md5}.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""

def short_uid():
    return uuid.uuid4().hex[:16]

for name in assets:
    md5 = hashlib.md5(name.encode()).hexdigest()
    uid = short_uid()
    content = TEMPLATE.format(name=name, md5=md5, uid=uid)
    out_path = os.path.join(env_dir, name + '.png.import')
    with open(out_path, 'w') as f:
        f.write(content)
    print(f'  wrote {out_path}')

# Also write import for characters/verdant_guardian.tscn (guardian scene uid file)
uid_content = "uid://verdantguard01\n"
# write .uid file
uid_path = "scenes/characters/verdant_guardian.tscn.uid"
# note: uid files are optional, Godot auto-generates them
print("Done!")
