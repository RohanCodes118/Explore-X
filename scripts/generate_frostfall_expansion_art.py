import os
import math
import random
from PIL import Image, ImageDraw, ImageFilter

env_dir = "assets/images/env"
char_dir = "assets/images/characters/frost_sentinel"
os.makedirs(env_dir, exist_ok=True)
os.makedirs(char_dir, exist_ok=True)

print("Generating Frostfall Expanse Expansion Assets...")

# -------------------------------------------------------------
# 1. CRYO SENTINEL 2.5D SPRITES (High-detail sci-fi combat mecha)
# Size: 96x96 per frame, isometric 2.5D top-down view
# -------------------------------------------------------------
def draw_sentinel_base(draw, x_center, y_center, frame_type="idle", phase=0.0):
    # Contact shadow on ground (2.5D depth)
    shadow_w = 42 + math.sin(phase * 4.0) * 3
    shadow_h = 16 + math.cos(phase * 4.0) * 2
    draw.ellipse([x_center - shadow_w/2, y_center + 26 - shadow_h/2, 
                  x_center + shadow_w/2, y_center + 26 + shadow_h/2], 
                 fill=(15, 30, 48, 140))

    # Hover offset (2.5D floating mecha)
    hover_y = math.sin(phase * 3.5) * 4.0 if frame_type in ["idle", "walk"] else 0.0
    cy = y_center - 12 + hover_y

    # Thruster glow beneath chassis
    thruster_pulse = int(180 + 75 * math.sin(phase * 8.0))
    draw.ellipse([x_center - 12, cy + 18, x_center + 12, cy + 26], 
                 fill=(40, 200, 255, thruster_pulse))
    draw.ellipse([x_center - 6, cy + 20, x_center + 6, cy + 24], 
                 fill=(220, 250, 255, 240))

    # Lower chassis / thruster housing (Metallic gunmetal with frosted edge)
    draw.polygon([
        (x_center - 16, cy + 10), (x_center + 16, cy + 10),
        (x_center + 10, cy + 22), (x_center - 10, cy + 22)
    ], fill=(35, 52, 70, 255), outline=(90, 140, 180, 255))

    # Core Torso / Armor plating (Heavy cryogenic composite)
    torso_tilt = 3.0 if frame_type == "walk" else ( -4.0 if frame_type == "hurt" else 0.0)
    tx = x_center + torso_tilt
    draw.polygon([
        (tx - 22, cy - 8), (tx + 22, cy - 8),
        (tx + 18, cy + 12), (tx - 18, cy + 12)
    ], fill=(45, 68, 92, 255), outline=(130, 195, 235, 255), width=2)

    # Chest Cryo-Reactor Core (Pulsing crystalline energy)
    core_glow = int(200 + 55 * math.sin(phase * 6.0))
    draw.ellipse([tx - 10, cy - 4, tx + 10, cy + 8], 
                 fill=(20, 120, 190, 255), outline=(80, 220, 255, 255), width=2)
    draw.ellipse([tx - 6, cy - 1, tx + 6, cy + 5], 
                 fill=(160, 245, 255, core_glow))

    # Shoulder Pauldrons (Pointed frosted ice crystal armor)
    shoulder_col = (110, 175, 220, 255)
    # Left shoulder
    draw.polygon([(tx - 22, cy - 6), (tx - 34, cy - 14), (tx - 18, cy - 18), (tx - 14, cy - 6)],
                 fill=shoulder_col, outline=(200, 240, 255, 255))
    # Right shoulder
    draw.polygon([(tx + 22, cy - 6), (tx + 34, cy - 14), (tx + 18, cy - 18), (tx + 14, cy - 6)],
                 fill=shoulder_col, outline=(200, 240, 255, 255))

    # Head / Visor Dome
    head_y = cy - 20
    draw.polygon([
        (tx - 14, head_y), (tx + 14, head_y),
        (tx + 12, head_y + 14), (tx - 12, head_y + 14)
    ], fill=(30, 44, 60, 255), outline=(120, 180, 220, 255), width=2)

    # Visor Glowing Slit (Cyan / Warning Red when attacking)
    visor_color = (255, 60, 60, 255) if frame_type == "attack" else (60, 240, 255, 255)
    draw.line([(tx - 9, head_y + 6), (tx + 9, head_y + 6)], fill=visor_color, width=3)
    draw.line([(tx - 6, head_y + 6), (tx + 6, head_y + 6)], fill=(255, 255, 255, 255), width=1)

    # Weapon / Retaliation Arms
    if frame_type == "idle":
        # Glacial Energy Blade / Cryo Emitters on right arm
        draw.line([(tx + 24, cy - 4), (tx + 28, cy + 18)], fill=(70, 100, 130, 255), width=4)
        draw.line([(tx + 28, cy + 16), (tx + 34, cy + 32)], fill=(80, 225, 255, 230), width=4)
        draw.line([(tx + 28, cy + 18), (tx + 33, cy + 30)], fill=(230, 255, 255, 255), width=2)
        # Left shield projector
        draw.polygon([(tx - 26, cy + 2), (tx - 32, cy + 16), (tx - 22, cy + 18)],
                     fill=(50, 80, 110, 255), outline=(120, 210, 255, 220))
    elif frame_type == "walk":
        # Blade swinging in rhythm
        arm_sw = math.sin(phase * 4.0) * 8.0
        draw.line([(tx + 24, cy - 4), (tx + 28 + arm_sw, cy + 16)], fill=(70, 100, 130, 255), width=4)
        draw.line([(tx + 28 + arm_sw, cy + 16), (tx + 35 + arm_sw, cy + 32)], fill=(80, 225, 255, 230), width=4)
        draw.polygon([(tx - 26 - arm_sw, cy + 2), (tx - 32 - arm_sw, cy + 16), (tx - 22 - arm_sw, cy + 18)],
                     fill=(50, 80, 110, 255), outline=(120, 210, 255, 220))
    elif frame_type == "attack":
        # Windup / Extended slash strike
        draw.line([(tx + 20, cy - 10), (tx + 38, cy - 2)], fill=(70, 100, 130, 255), width=5)
        # Extended giant cryo energy glaive blade
        draw.polygon([
            (tx + 38, cy - 2), (tx + 54, cy + 12), (tx + 58, cy + 6), (tx + 44, cy - 8)
        ], fill=(120, 240, 255, 240), outline=(240, 255, 255, 255), width=2)
        # Frost arc flash
        draw.arc([tx + 22, cy - 20, tx + 64, cy + 24], start=30, end=150, fill=(200, 255, 255, 230), width=3)
    elif frame_type == "hurt":
        # Red / white damage modulation overlay
        draw.line([(tx + 18, cy - 4), (tx + 24, cy + 16)], fill=(220, 100, 100, 255), width=4)
        # Electric freeze sparks
        draw.line([(tx - 15, cy - 12), (tx - 25, cy - 22)], fill=(255, 255, 255, 240), width=2)
        draw.line([(tx + 12, cy - 18), (tx + 22, cy - 26)], fill=(255, 255, 255, 240), width=2)
    elif frame_type == "death":
        # Collapsing / fragmenting chassis
        draw.line([(tx - 14, cy), (tx + 14, cy + 10)], fill=(255, 100, 100, 200), width=3)
        draw.line([(tx - 6, cy - 12), (tx + 18, cy + 2)], fill=(120, 220, 255, 240), width=3)

# Generate Sentinel Frames
for f_idx in range(4):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_sentinel_base(draw, 48, 48, "idle", phase=f_idx * 1.57)
    img.save(os.path.join(char_dir, f"sentinel_idle_{f_idx}.png"))

for f_idx in range(4):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_sentinel_base(draw, 48, 48, "walk", phase=f_idx * 1.57)
    img.save(os.path.join(char_dir, f"sentinel_walk_{f_idx}.png"))

for f_idx in range(4):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_sentinel_base(draw, 48, 48, "attack", phase=f_idx * 1.57)
    img.save(os.path.join(char_dir, f"sentinel_attack_{f_idx}.png"))

for f_idx in range(2):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_sentinel_base(draw, 48, 48, "hurt", phase=f_idx * 3.14)
    img.save(os.path.join(char_dir, f"sentinel_hurt_{f_idx}.png"))

for f_idx in range(4):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_sentinel_base(draw, 48, 48, "death", phase=f_idx * 1.57)
    img.save(os.path.join(char_dir, f"sentinel_death_{f_idx}.png"))

print("Generated Sentinel animation frames successfully.")

# -------------------------------------------------------------
# 2. ENEMY RETALIATION PROJECTILE / FROST PULSE
# Size: 48x48
# -------------------------------------------------------------
img_proj = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
d_proj = ImageDraw.Draw(img_proj)
for r in range(20, 2, -3):
    alpha = int(220 * (1.0 - r / 22.0))
    d_proj.ellipse([24 - r, 24 - r, 24 + r, 24 + r], fill=(60, 200, 255, alpha))
# Diamond ice core
d_proj.polygon([(24, 8), (34, 24), (24, 40), (14, 24)], fill=(220, 250, 255, 255), outline=(120, 220, 255, 255))
d_proj.line([(24, 12), (24, 36)], fill=(255, 255, 255, 255), width=2)
img_proj.save(os.path.join(env_dir, "frost_pulse_proj.png"))

# -------------------------------------------------------------
# 3. CRYO CONTAINMENT POD / STASIS BARREL (Obstacle)
# Size: 120x150, 2.5D cylindrical tech container
# -------------------------------------------------------------
img_pod = Image.new("RGBA", (120, 150), (0, 0, 0, 0))
d_pod = ImageDraw.Draw(img_pod)
# Contact shadow
d_pod.ellipse([15, 128, 105, 146], fill=(12, 24, 38, 150))
# Base pedestal
d_pod.polygon([(22, 132), (98, 132), (92, 116), (28, 116)], 
              fill=(38, 52, 70, 255), outline=(80, 120, 160, 255), width=2)
# Capsule body
d_pod.rectangle([28, 42, 92, 116], fill=(45, 62, 82, 255), outline=(95, 140, 185, 255), width=2)
# Frosted transparent glass tube window
d_pod.rectangle([36, 48, 84, 110], fill=(20, 60, 95, 210), outline=(80, 210, 255, 240), width=2)
# Glowing cryogenic fluid inside
for y in range(65, 105, 10):
    d_pod.line([(40, y), (80, y)], fill=(80, 220, 255, 160), width=4)
    d_pod.line([(42, y+2), (78, y+2)], fill=(220, 250, 255, 200), width=2)
# Specular reflection gleam across glass
d_pod.line([(42, 52), (52, 106)], fill=(255, 255, 255, 180), width=3)
# Domed cryogenic pressure cap
d_pod.polygon([(28, 42), (92, 42), (80, 18), (40, 18)], 
              fill=(55, 75, 100, 255), outline=(130, 195, 240, 255), width=2)
d_pod.ellipse([52, 12, 68, 24], fill=(60, 215, 255, 255), outline=(220, 250, 255, 255), width=2)
# Hazard warning markings
d_pod.line([(32, 122), (40, 122)], fill=(240, 180, 30, 255), width=2)
d_pod.line([(48, 122), (56, 122)], fill=(240, 180, 30, 255), width=2)
img_pod.save(os.path.join(env_dir, "frost_containment_pod.png"))

# -------------------------------------------------------------
# 4. FROST CONDUIT PIPES (Obstacle)
# Size: 240x100, Frosted tech pipeline
# -------------------------------------------------------------
img_pipe = Image.new("RGBA", (240, 100), (0, 0, 0, 0))
d_pipe = ImageDraw.Draw(img_pipe)
# Shadow
d_pipe.ellipse([20, 75, 220, 95], fill=(12, 24, 38, 140))
# Support struts
d_pipe.rectangle([40, 50, 58, 82], fill=(30, 42, 58, 255), outline=(70, 105, 140, 255), width=2)
d_pipe.rectangle([182, 50, 200, 82], fill=(30, 42, 58, 255), outline=(70, 105, 140, 255), width=2)
# Main cryogenic conduit cylinder
d_pipe.rectangle([15, 32, 225, 62], fill=(50, 68, 90, 255), outline=(100, 150, 200, 255), width=3)
# Frost coating / highlight on top
d_pipe.line([(18, 35), (222, 35)], fill=(210, 240, 255, 230), width=4)
d_pipe.line([(20, 42), (220, 42)], fill=(80, 210, 255, 180), width=2)
# Flange reinforcement rings
for rx in [35, 95, 145, 205]:
    d_pipe.rectangle([rx - 6, 28, rx + 6, 66], fill=(40, 55, 75, 255), outline=(120, 180, 235, 255), width=2)
    d_pipe.ellipse([rx - 3, 44, rx + 3, 50], fill=(80, 220, 255, 255))
# Cold vapor condensation drips / icicles hanging below
for ix in range(50, 190, 22):
    d_pipe.polygon([(ix, 62), (ix+6, 62), (ix+3, 76 + (ix%7)*2)], fill=(200, 240, 255, 220))
img_pipe.save(os.path.join(env_dir, "frost_conduit_pipe.png"))

# -------------------------------------------------------------
# 5. GIANT GLACIAL CRYSTAL CLUSTER (Obstacle)
# Size: 220x280, Towering ice crystal spires
# -------------------------------------------------------------
img_crys = Image.new("RGBA", (220, 280), (0, 0, 0, 0))
d_crys = ImageDraw.Draw(img_crys)
# Shadow
d_crys.ellipse([25, 240, 195, 275], fill=(10, 22, 35, 160))
# Spires: Background spire left
d_crys.polygon([(45, 80), (15, 180), (55, 250), (75, 170)], 
               fill=(95, 150, 195, 210), outline=(160, 215, 245, 240), width=2)
# Spires: Background spire right
d_crys.polygon([(170, 70), (145, 160), (165, 250), (205, 170)], 
               fill=(90, 145, 190, 210), outline=(160, 215, 245, 240), width=2)
# Main Central Tall Spire
poly_c_left = [(110, 15), (60, 130), (80, 255), (110, 255)]
poly_c_right = [(110, 15), (160, 140), (140, 255), (110, 255)]
poly_c_face = [(110, 15), (88, 145), (110, 255), (132, 150)]
d_crys.polygon(poly_c_left, fill=(120, 185, 230, 230), outline=(190, 235, 255, 250), width=2)
d_crys.polygon(poly_c_right, fill=(85, 150, 195, 230), outline=(170, 220, 250, 250), width=2)
d_crys.polygon(poly_c_face, fill=(160, 220, 250, 240), outline=(220, 250, 255, 255), width=2)
# Gleam lines
d_crys.line([(110, 22), (92, 135)], fill=(255, 255, 255, 240), width=3)
d_crys.line([(110, 22), (128, 140)], fill=(255, 255, 255, 200), width=2)
# Small forward crystals
d_crys.polygon([(90, 180), (75, 240), (105, 258), (115, 210)], 
               fill=(140, 205, 245, 240), outline=(210, 245, 255, 255), width=2)
img_crys.save(os.path.join(env_dir, "frost_crystal_cluster.png"))

# -------------------------------------------------------------
# 6. CRYO FORCEFIELD BARRIER (Gate locked until enemies defeated)
# Size: 320x120, Electric-cyan holographic energy grid & pylon posts
# -------------------------------------------------------------
img_field = Image.new("RGBA", (320, 120), (0, 0, 0, 0))
d_field = ImageDraw.Draw(img_field)
# Left and right emitter pylons
for px in [20, 300]:
    # Pylon shadow
    d_field.ellipse([px - 14, 98, px + 14, 116], fill=(10, 22, 35, 150))
    # Metal tech column
    d_field.rectangle([px - 10, 24, px + 10, 105], fill=(35, 50, 70, 255), outline=(90, 140, 190, 255), width=2)
    # Glowing emitter orb
    for r in range(16, 2, -3):
        d_field.ellipse([px - r, 18 - r + 8, px + r, 18 + r + 8], fill=(60, 210, 255, int(180*(1.0-r/18.0))))
    d_field.ellipse([px - 6, 20, px + 6, 32], fill=(220, 250, 255, 255))

# Forcefield energy grid beams
for by in range(35, 100, 14):
    d_field.line([(30, by), (290, by)], fill=(40, 190, 255, 160), width=4)
    d_field.line([(30, by), (290, by)], fill=(200, 245, 255, 220), width=2)

# Hexagonal energy barrier lattice patterns
for hx in range(50, 280, 28):
    for hy in [46, 74]:
        d_field.polygon([
            (hx, hy-8), (hx+10, hy-4), (hx+10, hy+4),
            (hx, hy+8), (hx-10, hy+4), (hx-10, hy-4)
        ], outline=(100, 230, 255, 200), width=2)
        d_field.ellipse([hx-3, hy-3, hx+3, hy+3], fill=(220, 255, 255, 230))

# Warning laser text / symbol in center
d_field.rectangle([110, 52, 210, 68], fill=(10, 35, 60, 200), outline=(255, 80, 80, 220), width=2)
d_field.line([(118, 60), (202, 60)], fill=(255, 100, 100, 255), width=3)
img_field.save(os.path.join(env_dir, "frost_forcefield_barrier.png"))

# -------------------------------------------------------------
# 7. CRYO STEAM HAZARD VENT
# Size: 120x80, Metallic floor vent with frosted grille
# -------------------------------------------------------------
img_vent = Image.new("RGBA", (120, 80), (0, 0, 0, 0))
d_vent = ImageDraw.Draw(img_vent)
d_vent.ellipse([10, 15, 110, 65], fill=(25, 40, 55, 255), outline=(75, 115, 155, 255), width=3)
d_vent.ellipse([24, 25, 96, 55], fill=(15, 25, 38, 255), outline=(50, 180, 240, 200), width=2)
# Grille slats
for gx in range(35, 86, 10):
    d_vent.line([(gx, 28), (gx, 52)], fill=(90, 135, 175, 255), width=3)
    d_vent.line([(gx+1, 28), (gx+1, 52)], fill=(180, 230, 255, 200), width=1)
img_vent.save(os.path.join(env_dir, "frost_hazard_vent.png"))

print("All Frostfall expansion assets successfully generated!")
