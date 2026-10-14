"""
Generate 2.5D environment PNG assets for Verdant Ruins.
Matches the reference image: isometric ruins with stone cliffs, waterfalls,
ancient trees, teal pools, and carved ruin floor.
Run from the project root:  python scripts/gen_verdant_2d5_assets.py
"""

import math, os, random
try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    import subprocess, sys
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "images", "env")
os.makedirs(OUT, exist_ok=True)

rng = random.Random(42)

def save(img, name):
    path = os.path.join(OUT, name)
    img.save(path)
    print(f"  saved  {name}  ({img.width}x{img.height})")

# ===================================================================
# 1. VERDANT RUINS FLOOR  512x512  (repeating ground tile)
# ===================================================================
def gen_verdant_floor():
    W, H = 512, 512
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    SAND  = (178, 148, 98)
    CRACK = (110,  88, 55)
    MOSS  = ( 52,  90, 42)
    TILE  = (155, 128, 80)
    DARK  = ( 90,  72, 42)

    d.rectangle([0,0,W-1,H-1], fill=SAND)

    GRID = 64
    for col in range(0, W+GRID, GRID):
        for row in range(0, H+GRID, GRID):
            x0, y0 = col, row
            d.rectangle([x0+1, y0+1, x0+GRID-3, y0+GRID-3], fill=TILE)
            d.rectangle([x0,   y0,   x0+GRID-1, y0],         fill=CRACK)
            d.rectangle([x0,   y0,   x0,        y0+GRID-1],  fill=CRACK)

    for _ in range(40):
        mx = rng.randint(0, W-1)
        my = rng.randint(0, H-1)
        r  = rng.randint(4, 14)
        for _ in range(r*2):
            bx = mx + rng.randint(-r, r)
            by = my + rng.randint(-r, r)
            d.ellipse([bx-3, by-3, bx+3, by+3], fill=MOSS + (rng.randint(160, 230),))

    cx, cy = W//2, H//2
    for rad in [120, 100, 84, 70]:
        d.ellipse([cx-rad, cy-rad, cx+rad, cy+rad], outline=CRACK+(210,), width=3)
    for angle_deg in range(0, 360, 45):
        ang = math.radians(angle_deg)
        x1 = int(cx + 120*math.cos(ang))
        y1 = int(cy + 120*math.sin(ang))
        d.line([cx, cy, x1, y1], fill=CRACK+(130,), width=2)

    for _ in range(20):
        x0 = rng.randint(10, W-10)
        y0 = rng.randint(10, H-10)
        length = rng.randint(20, 80)
        ang = rng.uniform(0, math.pi*2)
        x1 = int(x0 + length*math.cos(ang))
        y1 = int(y0 + length*math.sin(ang))
        d.line([x0,y0, x1,y1], fill=DARK+(160,), width=rng.randint(1,3))

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_ruins_floor.png")


# ===================================================================
# 2. STONE CLIFF WALL WITH WATERFALL  320x640
# ===================================================================
def gen_verdant_cliff():
    W, H = 320, 640
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    STONE = (55, 58, 52)
    LIGHT = (80, 84, 72)
    MOSS  = (40, 82, 38)
    WATER = (50, 185, 170, 200)
    FOAM  = (190, 240, 235, 180)
    VINE  = (35, 110, 45)

    pts = [20,0, W-20,0, W,H, 0,H]
    d.polygon(pts, fill=STONE)

    for row_y in range(0, H, 48):
        d.line([0, row_y, W, row_y], fill=LIGHT+(120,), width=2)

    for row_i, row_y in enumerate(range(0, H, 48)):
        offset = 40 if (row_i % 2 == 0) else 20
        for col_x in range(offset, W, 80):
            d.line([col_x, row_y, col_x, row_y+48], fill=LIGHT+(80,), width=1)

    for _ in range(55):
        mx = rng.randint(0, W)
        my = rng.randint(0, H//2)
        r  = rng.randint(5, 18)
        d.ellipse([mx-r, my-r, mx+r, my+r], fill=MOSS+(rng.randint(120,200),))

    for vx in [55, 120, 190, 260]:
        vlen = rng.randint(160, 400)
        pts_v = []
        cx = vx
        for vy in range(0, vlen, 10):
            cx += rng.randint(-4, 4)
            pts_v.extend([cx, vy])
        if len(pts_v) >= 4:
            d.line(pts_v, fill=VINE+(220,), width=3)
            for i in range(0, len(pts_v)-2, 20):
                lx, ly = pts_v[i], pts_v[i+1]
                d.ellipse([lx-7, ly-5, lx+7, ly+5], fill=MOSS+(180,))

    wfall_x = W//3
    for wy in range(0, H, 4):
        alpha = rng.randint(120, 200)
        width = rng.randint(18, 32)
        d.line([wfall_x-width//2, wy, wfall_x+width//2, wy],
               fill=WATER[:3]+(alpha,), width=3)

    for _ in range(30):
        fx = wfall_x + rng.randint(-25, 25)
        fy = H - rng.randint(0, 40)
        d.ellipse([fx-8, fy-5, fx+8, fy+5], fill=FOAM)

    d.line([20, 0, 0, H], fill=(110, 115, 105, 80), width=6)

    img = img.filter(ImageFilter.SMOOTH_MORE)
    save(img, "verdant_cliff_wall.png")


# ===================================================================
# 3. ANCIENT RUINS TREE  260x420
# ===================================================================
def gen_verdant_tree():
    W, H = 260, 420
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    TRUNK = (62, 44, 28)
    BARK  = (88, 62, 38)
    LEAF  = (38, 90, 30)
    LEAFL = (55, 120, 40)
    ROOT  = (50, 36, 22)

    cx = W//2
    trunk_top = 160

    for rx, ry_off in [(-50, 20), (50, 20), (-30, 40), (30, 40)]:
        d.polygon([cx-8, H-20, cx+rx, H+ry_off, cx+rx+20, H+ry_off-10, cx+8, H-20],
                  fill=ROOT)

    d.polygon([cx-22, H, cx-14, trunk_top, cx+14, trunk_top, cx+22, H],
              fill=TRUNK)
    d.line([cx-8, trunk_top+10, cx-16, H], fill=BARK+(140,), width=3)
    d.line([cx+6,  trunk_top+10, cx+14, H], fill=BARK+(100,), width=2)

    branches = [
        (cx, trunk_top, cx-70, 90),
        (cx, trunk_top, cx+70, 80),
        (cx, trunk_top, cx,    50),
        (cx-70, 90,  cx-110, 40),
        (cx+70, 80,  cx+100, 35),
    ]
    for x1,y1,x2,y2 in branches:
        d.line([x1,y1,x2,y2], fill=TRUNK, width=7)
        d.line([x1,y1,x2,y2], fill=BARK+(140,), width=3)

    canopy_centers = [
        (cx, 80, 90, 65),
        (cx-60, 100, 70, 55),
        (cx+60, 95, 70, 55),
        (cx-30, 55, 80, 60),
        (cx+30, 50, 80, 60),
        (cx, 40, 95, 55),
    ]
    for (lx, ly, lw, lh) in canopy_centers:
        color = rng.choice([LEAF, LEAFL])
        d.ellipse([lx-lw, ly-lh, lx+lw, ly+lh], fill=color+(220,))

    for (lx, ly, lw, lh) in canopy_centers:
        d.ellipse([lx-lw//3, ly-lh//2, lx+lw//3, ly], fill=LEAFL+(110,))

    for _ in range(8):
        vx = rng.randint(cx-80, cx+80)
        vy_start = rng.randint(80, 140)
        vlen = rng.randint(40, 100)
        d.line([vx, vy_start, vx+rng.randint(-10,10), vy_start+vlen],
               fill=(42, 110, 35, 180), width=2)

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_ruins_tree.png")


# ===================================================================
# 4. TEAL WATER POOL  200x120
# ===================================================================
def gen_verdant_pool():
    W, H = 200, 120
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    WATER  = (32, 175, 165, 210)
    SHINE  = (120, 230, 220, 160)
    RIM    = (60, 50, 38, 200)
    FOAM   = (200, 245, 240, 140)

    d.ellipse([0,0,W-1,H-1], fill=RIM)
    d.ellipse([10,8, W-10, H-8], fill=WATER)

    for _ in range(12):
        sx = rng.randint(20, W-20)
        sy = rng.randint(12, H-12)
        sl = rng.randint(10, 30)
        d.ellipse([sx-sl//2, sy-4, sx+sl//2, sy+4], fill=SHINE)

    d.arc([W//2-20, 8, W//2+20, 36], 0, 180, fill=FOAM, width=4)

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_water_pool.png")


# ===================================================================
# 5. STONE PILLAR COLUMN  96x320
# ===================================================================
def gen_verdant_pillar():
    W, H = 96, 320
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    STONE = (58, 62, 55)
    LIGHT = (85, 90, 78)
    MOSS  = (42, 88, 38)
    CAP   = (48, 50, 44)

    d.polygon([0, 40, 8, 0, W-8, 0, W, 40], fill=CAP)
    d.rectangle([4, 20, W-4, 40], fill=LIGHT)
    d.rectangle([12, 40, W-12, H-20], fill=STONE)

    for fx in range(16, W-12, 12):
        d.line([fx, 45, fx, H-22], fill=LIGHT+(80,), width=1)

    for _ in range(20):
        mx = rng.randint(14, W-14)
        my = rng.randint(50, H-30)
        r  = rng.randint(5, 14)
        d.ellipse([mx-r, my-r, mx+r, my+r], fill=MOSS+(rng.randint(130,200),))

    for _ in range(3):
        vx = rng.randint(14, W-14)
        d.line([vx, 40, vx+rng.randint(-6,6), H-20], fill=(38,100,35,180), width=2)

    d.rectangle([4, H-20, W-4, H], fill=CAP)

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_stone_pillar.png")


# ===================================================================
# 6. FERN CLUSTER  120x100
# ===================================================================
def gen_verdant_fern():
    W, H = 120, 100
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    DARK_G  = (28, 70, 22)
    MID_G   = (44, 105, 35)
    LIGHT_G = (62, 138, 46)

    cx = W//2
    fronds = [
        (-60, -80), (-35, -90), (-10, -85), (15, -88), (40, -82), (60, -75),
        (-50, -55), (50, -55),
    ]
    for i, (fx, fy) in enumerate(fronds):
        color = [DARK_G, MID_G, LIGHT_G][i % 3]
        steps = 6
        for s in range(steps):
            t = (s+1)/steps
            px = int(cx + fx * t)
            py = int(H + fy * t)
            lw = max(4, int(14*(1-t)))
            lh = max(3, int(10*(1-t)))
            d.ellipse([px-lw, py-lh, px+lw, py+lh], fill=color+(200,))

    for (fx, fy) in fronds:
        d.line([cx, H, cx+fx//2, H+fy//2], fill=DARK_G+(180,), width=2)

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_fern_cluster.png")


# ===================================================================
# 7. STONE STAIRCASE + GLOWING GATE  320x360
# ===================================================================
def gen_verdant_gate():
    W, H = 320, 360
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    STONE  = (58, 62, 52)
    STAIR  = (75, 78, 65)
    TRIM   = (90, 95, 80)
    GLOW   = (42, 220, 160, 220)
    GLOW2  = (20, 180, 130, 120)
    DOOR_D = (18, 22, 18, 240)
    MOSS   = (42, 88, 38)

    cx = W//2
    step_count = 5
    step_h = 14
    base_y = H - 20
    for step in range(step_count):
        sy = base_y - step * step_h
        sw = 260 - step * 28
        d.rectangle([cx - sw//2, sy - step_h, cx + sw//2, sy], fill=STAIR)
        d.line([cx - sw//2, sy - step_h, cx + sw//2, sy - step_h], fill=TRIM+(180,), width=2)

    arch_y = base_y - step_count * step_h
    arch_w = 100
    arch_h = 160
    d.rectangle([cx - arch_w//2 - 16, arch_y - arch_h, cx - arch_w//2, arch_y],  fill=STONE)
    d.rectangle([cx + arch_w//2,       arch_y - arch_h, cx + arch_w//2 + 16, arch_y], fill=STONE)
    d.rectangle([cx - arch_w//2 - 16, arch_y - arch_h - 16, cx + arch_w//2 + 16, arch_y - arch_h], fill=STONE)
    d.rectangle([cx - arch_w//2, arch_y - arch_h + 4, cx + arch_w//2, arch_y], fill=DOOR_D)

    rune_cx, rune_cy = cx, arch_y - arch_h - 20
    for r in [30, 22, 14, 7]:
        alpha = 150 - (30-r)*3
        d.ellipse([rune_cx-r, rune_cy-r, rune_cx+r, rune_cy+r],
                  outline=GLOW[:3]+(alpha,), width=2)
    d.ellipse([rune_cx-7, rune_cy-7, rune_cx+7, rune_cy+7], fill=GLOW)

    for r in [44, 34, 22, 12]:
        a = 60 + (44-r)*2
        d.ellipse([cx-r, arch_y - arch_h//2 - r + 20, cx+r, arch_y - arch_h//2 + r + 20],
                  fill=GLOW2[:3]+(a,))

    for _ in range(18):
        mx = rng.randint(cx-arch_w//2-16, cx+arch_w//2+16)
        my = rng.randint(arch_y - arch_h, arch_y)
        r  = rng.randint(4, 12)
        d.ellipse([mx-r, my-r, mx+r, my+r], fill=MOSS+(160,))

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_ruin_gate.png")


# ===================================================================
# 8. STONE RUIN BLOCK (obstacle)  128x96
# ===================================================================
def gen_verdant_ruin_block():
    W, H = 128, 96
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    STONE = (62, 65, 55)
    TOP   = (88, 92, 78)
    DARK  = (42, 44, 36)
    MOSS  = (44, 92, 36)

    d.rectangle([0, 32, W, H], fill=STONE)
    d.polygon([0, 32, W//2, 0, W, 32], fill=TOP)
    d.polygon([W, 32, W, H, W-8, H, W-8, 36], fill=DARK)
    d.line([0, 64, W, 64], fill=DARK+(100,), width=2)
    d.line([W//2, 32, W//2, H], fill=DARK+(80,), width=2)

    for _ in range(10):
        mx = rng.randint(0, W)
        my = rng.randint(32, H)
        r  = rng.randint(4, 10)
        d.ellipse([mx-r, my-r, mx+r, my+r], fill=MOSS+(150,))

    d.line([20, 40, 55, 80], fill=DARK+(150,), width=2)
    d.line([70, 35, 100, 75], fill=DARK+(120,), width=2)

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_ruin_block.png")


# ===================================================================
# 9. NPC / ENEMY GUARDIAN sprite  80x120
# ===================================================================
def gen_verdant_guardian():
    W, H = 80, 120
    img = Image.new("RGBA", (W, H), (0,0,0,0))
    d   = ImageDraw.Draw(img)

    BODY   = (40, 110, 60)
    ARMOR  = (55, 145, 80)
    SKIN   = (200, 170, 130)
    DARK   = (20, 55, 30)
    EYE    = (255, 80, 80)
    SPEAR  = (90, 65, 38)

    cx = W//2

    d.rectangle([cx-14, 80, cx-4,  H],  fill=BODY)
    d.rectangle([cx+4,  80, cx+14, H],  fill=BODY)
    d.rectangle([cx-17, H-14, cx-1, H], fill=DARK)
    d.rectangle([cx+1,  H-14, cx+17, H],fill=DARK)

    d.rectangle([cx-18, 48, cx+18, 82], fill=ARMOR)
    d.line([cx-18, 60, cx+18, 60], fill=BODY+(180,), width=2)
    d.line([cx, 48, cx, 82], fill=BODY+(100,), width=1)

    d.rectangle([cx-26, 50, cx-18, 78], fill=BODY)
    d.rectangle([cx+18, 50, cx+26, 78], fill=BODY)

    d.ellipse([cx-14, 24, cx+14, 50], fill=SKIN)
    d.rectangle([cx-15, 24, cx+15, 36], fill=ARMOR)

    d.ellipse([cx-7, 34, cx-2, 40], fill=EYE)
    d.ellipse([cx+2, 34, cx+7, 40], fill=EYE)

    d.line([cx+24, 20, cx+28, 95], fill=SPEAR, width=4)
    d.polygon([cx+20, 20, cx+28, 8, cx+34, 22], fill=(180, 180, 200))

    img = img.filter(ImageFilter.SMOOTH)
    save(img, "verdant_guardian.png")


if __name__ == "__main__":
    print("Generating Verdant Ruins 2.5D assets...")
    gen_verdant_floor()
    gen_verdant_cliff()
    gen_verdant_tree()
    gen_verdant_pool()
    gen_verdant_pillar()
    gen_verdant_fern()
    gen_verdant_gate()
    gen_verdant_ruin_block()
    gen_verdant_guardian()
    print("Done! All assets saved to assets/images/env/")
