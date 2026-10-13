from PIL import Image
import os

src = r"C:\Users\rohan\.gemini\antigravity-ide\brain\a0b484e7-de58-4711-b788-6a49bd91e71c\.user_uploaded\media_1791883852987.jpg"
im = Image.open(src)
W, H = im.size
print(f"Total Dimensions: {W}x{H}")

# Inspect vertical segments
# Let's save a test slice of the facial expressions
# From Y=560 to 675
# And width 0 to 1024
faces = im.crop((0, 560, W, H))
faces.save(r"assets/images/gf_faces_row.png")
print("Saved gf_faces_row.png")

# Let's inspect the rotational views at top:
# Y from 0 to 200, X from 230 to 1024
top_rotations = im.crop((230, 0, W, 200))
top_rotations.save(r"assets/images/gf_rotations_row.png")
print("Saved gf_rotations_row.png")

# Let's inspect IDLE and WALK:
# Y around 220 to 330
row_idle_walk = im.crop((230, 220, W, 330))
row_idle_walk.save(r"assets/images/gf_idle_walk_row.png")
print("Saved gf_idle_walk_row.png")

# RUN:
# Y around 340 to 440
row_run = im.crop((230, 340, W, 440))
row_run.save(r"assets/images/gf_run_row.png")
print("Saved gf_run_row.png")

# INTERACT, HURT, DEATH:
# Y around 445 to 555
row_actions = im.crop((230, 445, W, 555))
row_actions.save(r"assets/images/gf_actions_row.png")
print("Saved gf_actions_row.png")

# Full body character on left:
# X from 0 to 240, Y from 0 to 555
full_body = im.crop((0, 0, 240, 560))
full_body.save(r"assets/images/gf_full_body.png")
print("Saved gf_full_body.png")
