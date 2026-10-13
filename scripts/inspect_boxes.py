from PIL import Image

src = r"C:\Users\rohan\.gemini\antigravity-ide\brain\a0b484e7-de58-4711-b788-6a49bd91e71c\.user_uploaded\media_1791883852987.jpg"
im = Image.open(src)
W, H = im.size

# Let's inspect where text banners are:
# In the original image:
# Row 1 (top): Rotational views:
# Label 'FRONT' etc. are below each figure. Let's find vertical bounds of the figures.
# The figures start around Y=15 to Y=180.
# Let's inspect columns for the 8 rotations:
# Rotations are to the right of the full body portrait (X > 230).
print("--- ROTATIONS (X from 230 to 1024, Y from 10 to 190) ---")
# 8 directions across ~794 width:
# 230 to 1024:
rot_w = (1024 - 230) / 8.0 # ~99.25 px
for i in range(8):
    x0 = int(230 + i * rot_w)
    x1 = int(230 + (i + 1) * rot_w)
    print(f"Rot {i}: x=[{x0}, {x1}]")

# Row 2: IDLE (4 frames) & WALK (8 frames)
# Between X=230 and 1024.
# IDLE has 4 frames, WALK has 8 frames -> Total 12 frames!
# 794 / 12 = ~66.16 px each!
print("\n--- IDLE & WALK (Y around 235 to 330) ---")
step_12 = (1024 - 230) / 12.0
for i in range(4):
    x0 = int(230 + i * step_12)
    x1 = int(230 + (i + 1) * step_12)
    print(f"Idle {i}: x=[{x0}, {x1}]")
for i in range(8):
    x0 = int(230 + (4 + i) * step_12)
    x1 = int(230 + (4 + i + 1) * step_12)
    print(f"Walk {i}: x=[{x0}, {x1}]")

# Row 3: RUN (8 frames)
# Between X=230 and 1024. Wait, RUN has 8 frames across width? Let's check where the 8 frames are!
# Does RUN span the whole width or part of it? Let's check!
print("\n--- RUN row analysis (Y around 350 to 430) ---")
row_run = im.crop((230, 350, 1024, 430))
# Let's check non-black columns across this row:
col_sums = []
for x in range(230, 1024):
    c_sum = sum(sum(im.getpixel((x, y))) for y in range(350, 430)) / (80 * 3)
    col_sums.append((x, c_sum))
# Find non-black intervals:
active_cols = [x for x, c in col_sums if c > 3.0]
if active_cols:
    print(f"Run active X range: min={min(active_cols)}, max={max(active_cols)}, total={len(active_cols)}")

# Row 4: INTERACT (4 frames), HURT (4 frames), DEATH (6 frames) -> 14 frames total!
print("\n--- ACTIONS row analysis (Y around 460 to 550) ---")
col_sums_act = []
for x in range(230, 1024):
    c_sum = sum(sum(im.getpixel((x, y))) for y in range(460, 550)) / (90 * 3)
    col_sums_act.append((x, c_sum))
active_act = [x for x, c in col_sums_act if c > 3.0]
if active_act:
    print(f"Actions active X range: min={min(active_act)}, max={max(active_act)}, total={len(active_act)}")
