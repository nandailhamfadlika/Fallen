import os
from PIL import Image
import numpy as np
from collections import deque

CANVAS_W = 560
CANVAS_H = 480
BASELINE_Y = 408

SCALE_DEFAULT = 310.0 / 1115.0 # ~0.2780
SCALE_RUN = SCALE_DEFAULT * 1.68
SCALE_JUMP = SCALE_DEFAULT * 1.70
SCALE_HURT = SCALE_DEFAULT * 1.40
SCALE_WALL = SCALE_DEFAULT * 1.25

# Combo scales: 1.50x multiplier to match idle scale and account for artist zoom-out for FX arcs
SCALE_HIT1 = (SCALE_DEFAULT * (2752.0 / 1024.0)) * 1.50 # ~1.1209
SCALE_HIT2 = SCALE_DEFAULT * 1.50                       # ~0.4170
SCALE_HIT3 = SCALE_DEFAULT * 1.50                       # ~0.4170

RAW_DIR = r"A:\Game\Fallen\assets\characters\sunkibo\raw"
OUT_BASE = r"A:\Game\Fallen\assets\characters\sunkibo"

def remove_bg(img, tol=22):
    arr = np.array(img.convert('RGB'))
    h, w, _ = arr.shape
    border = np.concatenate([
        arr[:8, :].reshape(-1, 3),
        arr[-8:, :].reshape(-1, 3),
        arr[:, :8].reshape(-1, 3),
        arr[:, -8:].reshape(-1, 3)
    ], axis=0)
    bg = np.median(border, axis=0)
    diff = np.max(np.abs(arr.astype(float) - bg), axis=2)
    
    visited = np.zeros((h, w), dtype=bool)
    q = deque()
    for x in range(w):
        if diff[0, x] <= tol:
            visited[0, x] = True
            q.append((0, x))
        if diff[h-1, x] <= tol and not visited[h-1, x]:
            visited[h-1, x] = True
            q.append((h-1, x))
    for y in range(h):
        if diff[y, 0] <= tol and not visited[y, 0]:
            visited[y, 0] = True
            q.append((y, 0))
        if diff[y, w-1] <= tol and not visited[y, w-1]:
            visited[y, w-1] = True
            q.append((y, w-1))
            
    while q:
        cy, cx = q.popleft()
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if diff[ny, nx] <= tol:
                    visited[ny, nx] = True
                    q.append((ny, nx))
                    
    alpha = np.ones((h, w), dtype=np.uint8) * 255
    alpha[visited] = 0
    rgba = np.dstack([arr, alpha])
    return Image.fromarray(rgba, 'RGBA')

def save_to_canvas(clean_frame, out_path, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280):
    bbox = clean_frame.getbbox()
    if not bbox:
        print(f"Warning: Empty bbox for {out_path}")
        return
    cropped = clean_frame.crop(bbox)
    new_w = max(1, int(round(cropped.width * scale_factor)))
    new_h = max(1, int(round(cropped.height * scale_factor)))
    resized = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    canvas = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    pos_x = int(round(x_center - new_w / 2.0))
    pos_y = int(round(y_bottom - new_h))
    
    canvas.paste(resized, (pos_x, pos_y), resized)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    canvas.save(out_path, 'PNG')
    print(f"Saved: {out_path} (char size: {new_w}x{new_h})")

def process_idle():
    print("--- Processing Idle ---")
    im = Image.open(os.path.join(RAW_DIR, "sunkibo idle.jpg"))
    clean = remove_bg(im)
    cuts = [74, 682, 1295, 1879, 2469, 3121]
    for i in range(5):
        frame = clean.crop((cuts[i], 0, cuts[i+1], clean.height))
        out_p = os.path.join(OUT_BASE, "idle", f"idle_{i+1:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280)

def process_run():
    print("--- Processing Run (3x2 Grid) ---")
    im = Image.open(os.path.join(RAW_DIR, "sunkibo run.jpg"))
    clean = remove_bg(im)
    mid_y = 722
    row1 = clean.crop((0, 0, clean.width, mid_y))
    row2 = clean.crop((0, mid_y, clean.width, clean.height))
    
    # Row 1 cuts: 0..725, 725..1622, 1622..clean.width
    r1_cuts = [0, 725, 1622, clean.width]
    # Row 2 cuts: 0..711, 711..1618, 1618..clean.width
    r2_cuts = [0, 711, 1618, clean.width]
    
    # Frames 1, 2, 3 from Row 1
    for i in range(3):
        frame = row1.crop((r1_cuts[i], 0, r1_cuts[i+1], row1.height))
        out_p = os.path.join(OUT_BASE, "run", f"run_{i+1:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280)
        
    # Frames 4, 5, 6 from Row 2
    for i in range(3):
        frame = row2.crop((r2_cuts[i], 0, r2_cuts[i+1], row2.height))
        out_p = os.path.join(OUT_BASE, "run", f"run_{i+4:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280)

def process_jump():
    print("--- Processing Jump (3x2 Grid: 5 frames) ---")
    im = Image.open(os.path.join(RAW_DIR, "sunkibo jump.jpg"))
    clean = remove_bg(im)
    mid_y = 742
    row1 = clean.crop((0, 0, clean.width, mid_y))
    row2 = clean.crop((0, mid_y, clean.width, clean.height))
    
    r1_cuts = [0, 700, 1733, clean.width]
    r2_cuts = [0, 825, 1727]
    
    # Frame 1: Jump takeoff (grounded)
    f1 = row1.crop((r1_cuts[0], 0, r1_cuts[1], row1.height))
    save_to_canvas(f1, os.path.join(OUT_BASE, "jump", "jump_01.png"), scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280)
    
    # Frame 2: Jump ascent (airborne, elevation ~370)
    f2 = row1.crop((r1_cuts[1], 0, r1_cuts[2], row1.height))
    save_to_canvas(f2, os.path.join(OUT_BASE, "jump", "jump_02.png"), scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y - 25, x_center=280)
    
    # Frame 3: Apex tuck (airborne, elevation ~350)
    f3 = row1.crop((r1_cuts[2], 0, r1_cuts[3], row1.height))
    save_to_canvas(f3, os.path.join(OUT_BASE, "jump", "jump_03.png"), scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y - 45, x_center=280)
    
    # Frame 4: Falling descent (elevation ~360)
    f4 = row2.crop((r2_cuts[0], 0, r2_cuts[1], row2.height))
    save_to_canvas(f4, os.path.join(OUT_BASE, "jump", "jump_04.png"), scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y - 35, x_center=280)
    
    # Frame 5: Landing prep / low fall
    f5 = row2.crop((r2_cuts[1], 0, r2_cuts[2], row2.height))
    save_to_canvas(f5, os.path.join(OUT_BASE, "jump", "jump_05.png"), scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y - 10, x_center=280)

def process_hurt():
    print("--- Processing Hurt ---")
    im = Image.open(os.path.join(RAW_DIR, "sunkibo hurt.jpg"))
    clean = remove_bg(im)
    cuts = [70, 750, 1350, 1980, 2680]
    for i in range(4):
        frame = clean.crop((cuts[i], 0, cuts[i+1], clean.height))
        out_p = os.path.join(OUT_BASE, "hurt", f"hurt_{i+1:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280)

def process_wall():
    print("--- Processing Wall Cling ---")
    im = Image.open(os.path.join(RAW_DIR, "sunkibo wall.jpg"))
    clean = remove_bg(im)
    cuts = [60, 680, 1370, 2040, 2710]
    for i in range(4):
        frame = clean.crop((cuts[i], 0, cuts[i+1], clean.height))
        out_p = os.path.join(OUT_BASE, "wall", f"wall_{i+1:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y - 15, x_center=280)

def process_combo():
    print("--- Processing Combo 3-Hit ---")
    # Hit 1 (from 1024x572 sheet, scaled with SCALE_HIT1)
    im1 = Image.open(os.path.join(RAW_DIR, "sunkibo hit 1.jpg"))
    clean1 = remove_bg(im1)
    h1_cuts = [30, 330, 752, 1005]
    for i in range(3):
        frame = clean1.crop((h1_cuts[i], 0, h1_cuts[i+1], clean1.height))
        out_p = os.path.join(OUT_BASE, "combo", f"combo_01_{i+1:02d}.png")
        # Center frame 2 slightly forward if extended
        xc = 280 if i != 1 else 300
        save_to_canvas(frame, out_p, scale_factor=SCALE_HIT1, y_bottom=BASELINE_Y, x_center=xc)
        
    # Hit 2 (from 2752x1536 sheet, scaled with SCALE_DEFAULT)
    im2 = Image.open(os.path.join(RAW_DIR, "sunkibo hit 2.jpg"))
    clean2 = remove_bg(im2)
    h2_cuts = [0, 881, 1845, clean2.width]
    for i in range(3):
        frame = clean2.crop((h2_cuts[i], 0, h2_cuts[i+1], clean2.height))
        out_p = os.path.join(OUT_BASE, "combo", f"combo_02_{i+1:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_HIT2, y_bottom=BASELINE_Y, x_center=280)
        
    # Hit 3 (from 2752x1536 sheet, scaled with SCALE_DEFAULT)
    im3 = Image.open(os.path.join(RAW_DIR, "sunkibo hit 3.jpg"))
    clean3 = remove_bg(im3)
    h3_cuts = [0, 823, 1996, clean3.width]
    for i in range(3):
        frame = clean3.crop((h3_cuts[i], 0, h3_cuts[i+1], clean3.height))
        out_p = os.path.join(OUT_BASE, "combo", f"combo_03_{i+1:02d}.png")
        save_to_canvas(frame, out_p, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, x_center=280)

if __name__ == "__main__":
    process_idle()
    process_run()
    process_jump()
    process_hurt()
    process_wall()
    process_combo()
    print("=== Sunkibo Sprite Extraction Complete! ===")
