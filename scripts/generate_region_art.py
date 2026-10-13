import os
import math
import random
from PIL import Image, ImageDraw, ImageFilter

env_dir = "assets/images/env"
os.makedirs(env_dir, exist_ok=True)

def create_ember_assets():
    # 1. Sandstone Cliff (480x280)
    w, h = 480, 280
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Strata of orange-red sandstone
    # Irregular cliff polygon
    poly = [
        (20, h-10), (10, 80), (60, 40), (140, 20), (280, 15),
        (380, 35), (460, 70), (470, h-10), (20, h-10)
    ]
    draw.polygon(poly, fill=(185, 75, 35, 255), outline=(130, 45, 20, 255))
    # Rock strata bands
    for y in range(40, h-20, 16):
        col = (
            int(170 + 30 * math.sin(y * 0.15)),
            int(65 + 20 * math.cos(y * 0.2)),
            int(25 + 15 * math.sin(y * 0.3)),
            255
        )
        draw.line([(25 + random.randint(-5, 5), y), (455 + random.randint(-5, 5), y + random.randint(-4, 4))], fill=col, width=6)
    # Highlights & shadows
    for x in range(30, 450, 25):
        draw.line([(x, 30), (x + random.randint(-15, 15), h-15)], fill=(110, 40, 15, 120), width=4)
        draw.line([(x + 5, 25), (x + 8, h-25)], fill=(235, 120, 55, 100), width=2)
    img.save(os.path.join(env_dir, "ember_sandstone_cliff.png"))

    # 2. Volcanic Rocks (240x160)
    w, h = 240, 160
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    rock_poly = [
        (15, h-10), (10, 70), (40, 30), (110, 15), (170, 25),
        (225, 60), (230, h-10)
    ]
    draw.polygon(rock_poly, fill=(55, 38, 32, 255), outline=(25, 15, 12, 255))
    for i in range(12):
        x1 = random.randint(20, 220)
        y1 = random.randint(30, 140)
        draw.polygon([(x1, y1), (x1+30, y1-15), (x1+40, y1+20)], fill=(75, 52, 44, 255))
        draw.line([(x1, y1), (x1+35, y1+15)], fill=(110, 75, 60, 180), width=2)
    img.save(os.path.join(env_dir, "ember_volcanic_rocks.png"))

    # 3. Glowing Fissure (320x100)
    w, h = 320, 100
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Magma crack glow
    pts = [(10, 50), (60, 40), (120, 60), (190, 45), (250, 55), (310, 48)]
    for offset in range(16, 0, -2):
        alpha = int(255 * (1.0 - offset / 16.0))
        draw.line(pts, fill=(255, 120, 20, alpha), width=offset * 2)
    draw.line(pts, fill=(255, 240, 160, 255), width=3)
    img.save(os.path.join(env_dir, "ember_glowing_fissure.png"))

    # 4. Reactor Platform Landmark (360x240)
    w, h = 360, 240
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Industrial base octagon
    base = [(40, h-10), (20, 140), (80, 50), (180, 30), (280, 50), (340, 140), (320, h-10)]
    draw.polygon(base, fill=(45, 48, 55, 255), outline=(25, 28, 35, 255))
    # Tech plates & conduits
    draw.rectangle([60, 80, 300, 190], fill=(60, 65, 75, 255), outline=(90, 98, 115, 255), width=3)
    draw.ellipse([130, 95, 230, 175], fill=(25, 28, 35, 255), outline=(255, 140, 30, 255), width=4)
    # Glowing energy reactor core
    for r in range(35, 5, -5):
        alpha = int(255 * (1.0 - r / 40.0))
        draw.ellipse([180 - r, 135 - r, 180 + r, 135 + r], fill=(255, 160, 40, alpha))
    draw.ellipse([172, 127, 188, 143], fill=(255, 255, 220, 255))
    # Hazard stripes on lip
    for x in range(70, 290, 20):
        draw.polygon([(x, 180), (x+10, 180), (x+15, 190), (x+5, 190)], fill=(240, 170, 20, 220))
    img.save(os.path.join(env_dir, "ember_reactor_platform.png"))

    # 5. Desert Ground Pattern (seamless 256x256)
    w, h = 256, 256
    img = Image.new("RGB", (w, h), (185, 95, 45))
    draw = ImageDraw.Draw(img)
    for y in range(0, h, 8):
        offset = int(12 * math.sin(y * 0.08))
        draw.line([(0, y + offset), (w, y + offset)], fill=(165, 82, 38), width=3)
        draw.line([(0, y + offset - 2), (w, y + offset - 2)], fill=(205, 110, 55), width=2)
    # Sand grains
    for _ in range(600):
        gx = random.randint(0, w-1)
        gy = random.randint(0, h-1)
        c = random.choice([(140, 70, 30), (220, 125, 65), (195, 105, 50)])
        img.putpixel((gx, gy), c)
    img.save(os.path.join(env_dir, "ember_sand_ground.png"))

def create_verdant_assets():
    # 1. Ancient Ruin Pillar (120x340)
    w, h = 120, 340
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Stone column
    draw.rectangle([25, 30, 95, h-10], fill=(70, 85, 80, 255), outline=(40, 50, 48, 255), width=3)
    # Capital and Base
    draw.rectangle([15, 15, 105, 38], fill=(85, 102, 95, 255), outline=(40, 50, 48, 255), width=2)
    draw.rectangle([15, h-30, 105, h-10], fill=(85, 102, 95, 255), outline=(40, 50, 48, 255), width=2)
    # Fluting grooves
    for x in range(35, 90, 12):
        draw.line([(x, 38), (x, h-30)], fill=(50, 62, 58, 200), width=3)
        draw.line([(x+2, 38), (x+2, h-30)], fill=(110, 135, 125, 160), width=1)
    # Overgrown moss and ivy
    for y in range(40, h-20, 22):
        ix = random.randint(20, 70)
        draw.ellipse([ix, y, ix+35, y+24], fill=(35, 130, 65, 230))
        draw.ellipse([ix+5, y+4, ix+25, y+16], fill=(55, 185, 95, 200))
    # Bioluminescent runic inlays
    for ry in [70, 130, 200, 270]:
        draw.line([(45, ry), (75, ry)], fill=(30, 240, 180, 220), width=3)
        draw.ellipse([55, ry-4, 65, ry+4], fill=(150, 255, 225, 255))
    img.save(os.path.join(env_dir, "verdant_ancient_pillar.png"))

    # 2. Ruined Temple Archway (380x280)
    w, h = 380, 280
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Left & Right piers
    draw.rectangle([30, 60, 90, h-10], fill=(65, 80, 75, 255), outline=(38, 48, 45, 255), width=3)
    draw.rectangle([290, 60, 350, h-10], fill=(65, 80, 75, 255), outline=(38, 48, 45, 255), width=3)
    # Arch lintel
    draw.rectangle([20, 20, 360, 68], fill=(78, 96, 90, 255), outline=(42, 54, 50, 255), width=3)
    # Carved pediment relief
    draw.polygon([(40, 20), (190, 2), (340, 20)], fill=(88, 108, 100, 255), outline=(45, 58, 54, 255))
    # Moss clumps
    for mx, my in [(50, 15), (180, 10), (320, 18), (40, 120), (330, 180), (70, 230)]:
        draw.ellipse([mx-15, my-10, mx+25, my+18], fill=(40, 145, 75, 220))
        draw.ellipse([mx-8, my-5, mx+15, my+10], fill=(70, 205, 110, 200))
    # Glowing glyph on arch center
    draw.ellipse([175, 30, 205, 60], fill=(20, 220, 170, 240), outline=(120, 255, 220, 255), width=2)
    img.save(os.path.join(env_dir, "verdant_temple_archway.png"))

    # 3. Navigation Shrine Landmark (320x240)
    w, h = 320, 240
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Tiered altar steps
    draw.polygon([(20, h-10), (45, 170), (275, 170), (300, h-10)], fill=(50, 65, 60, 255), outline=(30, 40, 38, 255), width=3)
    draw.polygon([(55, 170), (80, 110), (240, 110), (265, 170)], fill=(65, 82, 76, 255), outline=(35, 48, 44, 255), width=3)
    # Shrine Pedestal
    draw.rectangle([120, 50, 200, 110], fill=(75, 95, 88, 255), outline=(45, 60, 55, 255), width=3)
    # Glowing beacon energy beam ring
    for r in range(40, 5, -5):
        alpha = int(220 * (1.0 - r / 45.0))
        draw.ellipse([160 - r, 45 - r, 160 + r, 45 + r], fill=(20, 240, 180, alpha))
    draw.ellipse([150, 35, 170, 55], fill=(180, 255, 235, 255))
    img.save(os.path.join(env_dir, "verdant_navigation_shrine.png"))

    # 4. Bioluminescent Flora Cluster (160x140)
    w, h = 160, 140
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Stems
    for sx, ex in [(50, 30), (80, 80), (110, 130), (70, 55), (90, 105)]:
        draw.line([(80, h-10), (ex, 40)], fill=(30, 100, 60, 255), width=4)
        # Glowing bell/bulb
        for r in range(18, 2, -3):
            draw.ellipse([ex - r, 35 - r, ex + r, 35 + r], fill=(0, 230, 210, int(220 * (1.0 - r / 20.0))))
        draw.ellipse([ex - 6, 32, ex + 6, 44], fill=(200, 255, 245, 255))
    img.save(os.path.join(env_dir, "verdant_biolum_flora.png"))

    # 5. Overgrown Stone Paver Ground (seamless 256x256)
    w, h = 256, 256
    img = Image.new("RGB", (w, h), (25, 48, 35))
    draw = ImageDraw.Draw(img)
    # Stone pavers
    for py in range(0, h, 32):
        for px in range(0, w, 32):
            shift = 16 if (py // 32) % 2 == 1 else 0
            x0 = (px + shift) % w
            draw.rectangle([x0+2, py+2, x0+29, py+29], fill=(48, 68, 58), outline=(28, 42, 35), width=2)
            # Moss patches
            if random.random() > 0.4:
                draw.ellipse([x0+5, py+5, x0+20, py+18], fill=(32, 95, 52))
    img.save(os.path.join(env_dir, "verdant_moss_ground.png"))

def create_frost_assets():
    # 1. Translucent Ice Monolith (160x360)
    w, h = 160, 360
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Faceted crystal spire
    poly_left = [(80, 15), (20, 120), (35, h-15), (80, h-10)]
    poly_right = [(80, 15), (140, 130), (125, h-15), (80, h-10)]
    poly_center = [(80, 15), (55, 140), (80, h-10), (105, 150)]
    draw.polygon(poly_left, fill=(130, 195, 235, 210), outline=(190, 235, 255, 240), width=2)
    draw.polygon(poly_right, fill=(90, 155, 205, 210), outline=(170, 225, 255, 240), width=2)
    draw.polygon(poly_center, fill=(170, 225, 250, 230), outline=(220, 250, 255, 255), width=2)
    # Internal refraction gleams
    draw.line([(80, 25), (45, 130)], fill=(255, 255, 255, 220), width=3)
    draw.line([(80, 30), (95, 200)], fill=(255, 255, 255, 180), width=2)
    draw.line([(30, 150), (130, 210)], fill=(200, 245, 255, 150), width=2)
    img.save(os.path.join(env_dir, "frost_ice_monolith.png"))

    # 2. Glacier Wall (460x260)
    w, h = 460, 260
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    glacier_poly = [
        (10, h-10), (20, 80), (70, 45), (160, 20), (250, 40),
        (340, 25), (420, 60), (450, h-10)
    ]
    draw.polygon(glacier_poly, fill=(105, 160, 210, 240), outline=(175, 225, 255, 255), width=3)
    # Ice strata & crevasses
    for y in range(45, h-20, 20):
        draw.line([(25, y), (435, y + random.randint(-6, 6))], fill=(160, 215, 245, 180), width=4)
        draw.line([(30, y-3), (430, y-3)], fill=(230, 250, 255, 160), width=2)
    # Deep blue crevasse cracks
    for x in range(60, 400, 45):
        draw.line([(x, 30), (x + random.randint(-20, 20), h-15)], fill=(45, 85, 135, 220), width=3)
    img.save(os.path.join(env_dir, "frost_glacier_wall.png"))

    # 3. Cryogenic Facility Landmark (360x240)
    w, h = 360, 240
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Frozen high-tech research platform
    draw.polygon([(30, h-10), (50, 130), (310, 130), (330, h-10)], fill=(40, 55, 75, 255), outline=(75, 105, 140, 255), width=3)
    # Cryo chamber vault
    draw.rectangle([90, 40, 270, 150], fill=(55, 75, 105, 255), outline=(120, 180, 230, 255), width=3)
    # Cylindrical cryogenic core window
    draw.ellipse([140, 55, 220, 135], fill=(20, 45, 70, 255), outline=(80, 200, 255, 255), width=4)
    # Glowing cryo quantum containment aura
    for r in range(32, 4, -4):
        alpha = int(220 * (1.0 - r / 36.0))
        draw.ellipse([180 - r, 95 - r, 180 + r, 95 + r], fill=(80, 210, 255, alpha))
    draw.ellipse([172, 87, 188, 103], fill=(240, 255, 255, 255))
    # Frost icicles on roof
    for ix in range(95, 265, 14):
        draw.polygon([(ix, 150), (ix+8, 150), (ix+4, 172)], fill=(200, 240, 255, 240))
    img.save(os.path.join(env_dir, "frost_cryo_facility.png"))

    # 4. Frozen Scientific Debris (180x110)
    w, h = 180, 110
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Battery canister / antenna
    draw.rectangle([25, 45, 95, 95], fill=(50, 68, 85, 255), outline=(80, 110, 135, 255), width=2)
    draw.line([(60, 45), (60, 10)], fill=(150, 175, 200, 255), width=3)
    draw.ellipse([55, 5, 65, 15], fill=(80, 220, 255, 255))
    # Snow drifts covering base
    draw.ellipse([10, 75, 120, 105], fill=(215, 235, 250, 240))
    draw.ellipse([80, 65, 170, 102], fill=(230, 245, 255, 255))
    img.save(os.path.join(env_dir, "frost_frozen_debris.png"))

    # 5. Cracked Ice Ground (seamless 256x256)
    w, h = 256, 256
    img = Image.new("RGB", (w, h), (145, 190, 225))
    draw = ImageDraw.Draw(img)
    # Ice cracks network
    for _ in range(16):
        x1 = random.randint(0, w)
        y1 = random.randint(0, h)
        x2 = (x1 + random.randint(-60, 60)) % w
        y2 = (y1 + random.randint(-60, 60)) % h
        draw.line([(x1, y1), (x2, y2)], fill=(90, 140, 185), width=2)
        draw.line([(x1+1, y1+1), (x2+1, y2+1)], fill=(215, 240, 255), width=1)
    img.save(os.path.join(env_dir, "frost_ice_ground.png"))

def create_map_illustrations():
    # Region Map Card Illustrations (360x220 each)
    
    # 1. Ember Wastes Card Illustration
    w, h = 360, 220
    img = Image.new("RGB", (w, h), (75, 25, 10))
    draw = ImageDraw.Draw(img)
    # Sky gradient
    for y in range(h):
        t = y / float(h)
        r = int(140 + t * 90)
        g = int(45 + t * 45)
        b = int(15 + t * 15)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    # Distant canyon mountains
    draw.polygon([(0, 120), (80, 80), (160, 110), (250, 70), (360, 100), (360, h), (0, h)], fill=(120, 45, 18))
    # Midground rock spires
    draw.polygon([(20, 150), (90, 95), (140, 160), (210, 115), (320, 170), (360, 140), (360, h), (0, h)], fill=(85, 30, 12))
    # Glowing fissure in foreground
    draw.line([(40, 195), (160, 185), (280, 205)], fill=(255, 140, 30), width=6)
    draw.line([(40, 195), (160, 185), (280, 205)], fill=(255, 230, 140), width=2)
    img.save(os.path.join("assets/images", "map_ember_wastes.png"))

    # 2. Verdant Ruins Card Illustration
    img = Image.new("RGB", (w, h), (15, 45, 30))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / float(h)
        r = int(10 + t * 25)
        g = int(55 + t * 75)
        b = int(45 + t * 50)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    # Distant overgrown ziggurat / temples
    draw.polygon([(40, 140), (100, 75), (160, 75), (220, 140)], fill=(30, 75, 50))
    # Ancient stone pillars in midground
    draw.rectangle([70, 70, 95, 180], fill=(42, 92, 65))
    draw.rectangle([200, 60, 225, 180], fill=(42, 92, 65))
    draw.line([(60, 65), (235, 65)], fill=(50, 110, 78), width=8)
    # Bioluminescent glow pools
    draw.ellipse([110, 160, 210, 200], fill=(20, 210, 160), outline=(120, 255, 220), width=2)
    img.save(os.path.join("assets/images", "map_verdant_ruins.png"))

    # 3. Frostfall Expanse Card Illustration
    img = Image.new("RGB", (w, h), (15, 35, 60))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / float(h)
        r = int(25 + t * 80)
        g = int(60 + t * 110)
        b = int(110 + t * 115)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    # Distant glaciers
    draw.polygon([(0, 130), (90, 85), (180, 120), (280, 70), (360, 110), (360, h), (0, h)], fill=(75, 130, 180))
    # Crystal monolith spires
    draw.polygon([(110, 180), (130, 40), (150, 180)], fill=(160, 225, 255))
    draw.polygon([(230, 190), (245, 60), (260, 190)], fill=(140, 210, 250))
    # Frozen plains
    draw.polygon([(0, 175), (120, 165), (250, 178), (360, 170), (360, h), (0, h)], fill=(185, 225, 250))
    img.save(os.path.join("assets/images", "map_frostfall_expanse.png"))

    # 4. Unknown Component Obscured Icon (128x128)
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Holographic radar reticle
    draw.ellipse([14, 14, 114, 114], outline=(60, 170, 240, 160), width=3)
    draw.ellipse([30, 30, 98, 98], outline=(40, 130, 200, 120), width=2)
    draw.line([(64, 8), (64, 24)], fill=(80, 200, 255, 220), width=3)
    draw.line([(64, 104), (64, 120)], fill=(80, 200, 255, 220), width=3)
    draw.line([(8, 64), (24, 64)], fill=(80, 200, 255, 220), width=3)
    draw.line([(104, 64), (120, 64)], fill=(80, 200, 255, 220), width=3)
    # Question mark glyph
    # Draw arc and dot for ?
    draw.arc([46, 32, 82, 68], start=180, end=360, fill=(100, 220, 255, 255), width=6)
    draw.line([(82, 50), (64, 74)], fill=(100, 220, 255, 255), width=6)
    draw.line([(64, 74), (64, 84)], fill=(100, 220, 255, 255), width=6)
    draw.ellipse([60, 92, 68, 100], fill=(120, 235, 255, 255))
    img.save(os.path.join("assets/images", "component_unknown.png"))

print("Generating environment and map assets...")
create_ember_assets()
create_verdant_assets()
create_frost_assets()
create_map_illustrations()
print("All environment and map assets generated successfully!")
