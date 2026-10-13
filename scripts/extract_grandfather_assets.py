from PIL import Image
import os
from collections import deque

src = r"C:\Users\rohan\.gemini\antigravity-ide\brain\a0b484e7-de58-4711-b788-6a49bd91e71c\.user_uploaded\media_1791883852987.jpg"
im = Image.open(src).convert("RGB")
W, H = im.size

out_dir = r"assets/images/characters/grandfather"
os.makedirs(out_dir, exist_ok=True)

from typing import Any

def remove_black_bg(img: Image.Image, bg_thresh: int = 18, edge_blend: int = 12) -> Image.Image:
    """Removes dark background by flood-filling from borders and soft-edging."""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    pixels: Any = rgba.load()
    if pixels is None:
        return rgba
    
    # 2D array of visited / transparent
    # 0 = not visited, 1 = transparent background, 2 = edge blend
    visited = bytearray(w * h)
    
    q = deque()
    # Add border pixels that are near-black
    for x in range(w):
        for y in (0, h - 1):
            r, g, b, _ = pixels[x, y]
            if max(r, g, b) <= bg_thresh + edge_blend:
                visited[y * w + x] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            r, g, b, _ = pixels[x, y]
            if max(r, g, b) <= bg_thresh + edge_blend:
                if not visited[y * w + x]:
                    visited[y * w + x] = 1
                    q.append((x, y))
                    
    # BFS flood fill
    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)):
            if 0 <= nx < w and 0 <= ny < h:
                idx = ny * w + nx
                if not visited[idx]:
                    r, g, b, _ = pixels[nx, ny]
                    brightness = max(r, g, b)
                    if brightness <= bg_thresh:
                        visited[idx] = 1
                        q.append((nx, ny))
                    elif brightness <= bg_thresh + edge_blend:
                        visited[idx] = 2 # edge
                        
    # Apply alpha
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            state = visited[idx]
            if state == 1:
                r, g, b, _ = pixels[x, y]
                pixels[x, y] = (r, g, b, 0)
            elif state == 2:
                r, g, b, _ = pixels[x, y]
                brightness = max(r, g, b)
                # Linear blend
                alpha = int(255.0 * (brightness - bg_thresh) / edge_blend)
                pixels[x, y] = (r, g, b, max(0, min(255, alpha)))
                
    return rgba

def crop_and_clean(box):
    crop = im.crop(box)
    return remove_black_bg(crop)

print("Extracting Rotations (8 directions)...")
# Y=10 to 175
rot_names = ["front", "front_right", "right", "back_right", "back", "back_left", "left", "front_left"]
rot_w = (1024 - 230) / 8.0
for i, name in enumerate(rot_names):
    x0 = int(230 + i * rot_w)
    x1 = int(230 + (i + 1) * rot_w)
    sprite = crop_and_clean((x0, 10, x1, 175))
    sprite.save(os.path.join(out_dir, f"rot_{name}.png"))

print("Extracting Idle (4 frames)...")
# Y=235 to 326
step_12 = (1024 - 230) / 12.0
for i in range(4):
    x0 = int(230 + i * step_12)
    x1 = int(230 + (i + 1) * step_12)
    sprite = crop_and_clean((x0, 235, x1, 326))
    sprite.save(os.path.join(out_dir, f"idle_{i}.png"))

print("Extracting Walk (8 frames)...")
for i in range(8):
    x0 = int(230 + (4 + i) * step_12)
    x1 = int(230 + (4 + i + 1) * step_12)
    sprite = crop_and_clean((x0, 235, x1, 326))
    sprite.save(os.path.join(out_dir, f"walk_{i}.png"))

print("Extracting Run (8 frames)...")
# Y=355 to 430
# Run active from X=245 to ~905 (8 frames)
run_step = (905 - 245) / 8.0
for i in range(8):
    x0 = int(245 + i * run_step)
    x1 = int(245 + (i + 1) * run_step)
    sprite = crop_and_clean((x0, 355, x1, 430))
    sprite.save(os.path.join(out_dir, f"run_{i}.png"))

print("Extracting Actions (Interact 4, Hurt 4, Death 6)...")
# Y=465 to 540
# X from ~240 to 1010 across 14 figures
act_step = (1010 - 240) / 14.0
for i in range(4):
    x0 = int(240 + i * act_step)
    x1 = int(240 + (i + 1) * act_step)
    sprite = crop_and_clean((x0, 465, x1, 540))
    sprite.save(os.path.join(out_dir, f"interact_{i}.png"))

for i in range(4):
    x0 = int(240 + (4 + i) * act_step)
    x1 = int(240 + (4 + i + 1) * act_step)
    sprite = crop_and_clean((x0, 465, x1, 540))
    sprite.save(os.path.join(out_dir, f"hurt_{i}.png"))

for i in range(6):
    x0 = int(240 + (8 + i) * act_step)
    x1 = int(240 + (8 + i + 1) * act_step)
    sprite = crop_and_clean((x0, 465, x1, 540))
    sprite.save(os.path.join(out_dir, f"death_{i}.png"))

print("Extracting Facial Expressions (8 closeups)...")
# Y=565 to 670, X=0 to 1024 (8 portraits, 128px wide each)
face_names = ["neutral", "serious", "calm", "speaking", "thoughtful", "concerned", "determined", "weary"]
for i, name in enumerate(face_names):
    x0 = i * 128
    x1 = (i + 1) * 128
    # Keep facial expressions as high quality RGB with clean border
    face = im.crop((x0, 565, x1, 670))
    face.save(os.path.join(out_dir, f"face_{name}.png"))
    # Save the primary portrait to assets/images/grandfather_portrait.png
    if i == 0:
        face.save(r"assets/images/grandfather_portrait.png")

print("Extracting Full Body Artwork...")
# X=0 to 235, Y=0 to 555
full_body = crop_and_clean((0, 0, 235, 555))
full_body.save(os.path.join(out_dir, "grandfather_full_body.png"))
# Also save as main sprite replacement
full_body.save(r"assets/images/grandfather_sprite.png")

print("Extraction complete!")
