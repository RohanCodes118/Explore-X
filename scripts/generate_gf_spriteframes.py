import os

tres_path = "resources/animations/grandfather_sprite_frames.tres"
img_base = "res://assets/images/characters/grandfather"

# Define animations
animations = {
    "idle": [f"{img_base}/idle_{i}.png" for i in range(4)],
    "walk": [f"{img_base}/walk_{i}.png" for i in range(8)],
    "run": [f"{img_base}/run_{i}.png" for i in range(8)],
    "interact": [f"{img_base}/interact_{i}.png" for i in range(4)],
    "hurt": [f"{img_base}/hurt_{i}.png" for i in range(4)],
    "death": [f"{img_base}/death_{i}.png" for i in range(6)],
    "rot_front": [f"{img_base}/rot_front.png"],
    "rot_front_right": [f"{img_base}/rot_front_right.png"],
    "rot_right": [f"{img_base}/rot_right.png"],
    "rot_back_right": [f"{img_base}/rot_back_right.png"],
    "rot_back": [f"{img_base}/rot_back.png"],
    "rot_back_left": [f"{img_base}/rot_back_left.png"],
    "rot_left": [f"{img_base}/rot_left.png"],
    "rot_front_left": [f"{img_base}/rot_front_left.png"],
}

# Collect all unique textures
unique_textures = []
for frames in animations.values():
    for f in frames:
        if f not in unique_textures:
            unique_textures.append(f)

# Build ext_resource lines
lines = ['[gd_resource type="SpriteFrames" format=3]', '']
tex_to_id = {}
for i, tex in enumerate(unique_textures, 1):
    ext_id = f"{i}_gf_{os.path.basename(tex).split('.')[0]}"
    tex_to_id[tex] = ext_id
    lines.append(f'[ext_resource type="Texture2D" path="{tex}" id="{ext_id}"]')

lines.append('')
lines.append('[resource]')
lines.append('animations = [')

anim_blocks = []
for anim_name, frames in animations.items():
    speed = 6.0
    loop = "true"
    if anim_name == "idle":
        speed = 5.0
    elif anim_name == "walk":
        speed = 8.0
    elif anim_name == "run":
        speed = 10.0
    elif anim_name in ("interact", "hurt"):
        speed = 5.0
        loop = "false"
    elif anim_name == "death":
        speed = 4.0
        loop = "false"
    elif anim_name.startswith("rot_"):
        speed = 1.0
        loop = "true"
        
    f_list = []
    for f in frames:
        f_list.append(f'{{\n"duration": 1.0,\n"texture": ExtResource("{tex_to_id[f]}")\n}}')
    
    frames_str = ", ".join(f_list)
    block = f'{{\n"frames": [{frames_str}],\n"loop": {loop},\n"name": &"{anim_name}",\n"speed": {speed}\n}}'
    anim_blocks.append(block)

lines.append(", ".join(anim_blocks))
lines.append(']')

with open(tres_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print(f"Generated {tres_path} correctly formatted!")
