import os
from PIL import Image
import numpy as np
from collections import deque

CANVAS_W = 560
CANVAS_H = 480
BASELINE_Y = 408

SCALE_DEFAULT = 334.0 / 1165.0 # ~0.2867 for 1165px sheets
SCALE_RUN = 0.53               # For 580px run sheet -> 310-325px height matching idle
SCALE_AIR = 0.35               # For jump and wall states -> 310-325px height

RAW_DIR = r"A:\Game\Fallen\assets\characters\muslan\raw"
OUT_BASE = r"A:\Game\Fallen\assets\characters\muslan"

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

def save_to_canvas(clean_frame, out_path, scale_factor=SCALE_DEFAULT, y_bottom=BASELINE_Y, head_y=None, x_center=240):
    alpha = np.array(clean_frame)[:, :, 3]
    ys, xs = np.where(alpha > 10)
    if len(ys) == 0 or len(xs) == 0:
        print(f"  Warning: empty frame for {out_path}")
        return
        
    bx1, bx2 = xs.min(), xs.max()
    by1, by2 = ys.min(), ys.max()
    tight = clean_frame.crop((bx1, by1, bx2 + 1, by2 + 1))
    
    nw = max(1, int(round(tight.width * scale_factor)))
    nh = max(1, int(round(tight.height * scale_factor)))
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    if head_y is not None:
        pos_y = head_y
    else:
        pos_y = y_bottom - scaled.height
        
    pos_x = x_center - (scaled.width // 2)
    
    if pos_x < 5:
        pos_x = 5
    if pos_x + scaled.width > CANVAS_W - 5:
        pos_x = CANVAS_W - 5 - scaled.width
        
    canvas.paste(scaled, (pos_x, pos_y), scaled)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    canvas.save(out_path)
    print(f"  Saved {os.path.basename(out_path)}: scaled ({nw}x{nh}) at ({pos_x}, {pos_y})")

def extract_standard_sheet(filename, frame_cuts, out_paths, scale_factor=SCALE_DEFAULT, y_bottoms=None, head_ys=None, x_centers=None):
    src = os.path.join(RAW_DIR, filename)
    print(f"\nProcessing {filename}...")
    img = Image.open(src)
    for idx, (x1, x2) in enumerate(frame_cuts):
        crop = img.crop((x1, 0, x2, img.height))
        clean = remove_bg(crop)
        y_bot = y_bottoms[idx] if y_bottoms else BASELINE_Y
        h_y = head_ys[idx] if head_ys else None
        x_c = x_centers[idx] if x_centers else 240
        save_to_canvas(clean, out_paths[idx], scale_factor=scale_factor, y_bottom=y_bot, head_y=h_y, x_center=x_c)

def extract_run_sheet():
    filename = "Muslan Run.jpg"
    src = os.path.join(RAW_DIR, filename)
    print(f"\nProcessing {filename} (Careful cut for dempet frames 3 & 4 with correct run scale)...")
    img = Image.open(src)
    arr = np.array(img)
    corners = np.vstack([arr[:10, :10].reshape(-1,3), arr[:10, -10:].reshape(-1,3), arr[-10:, :10].reshape(-1,3), arr[-10:, -10:].reshape(-1,3)])
    bg = np.median(corners, axis=0)
    h, w, _ = arr.shape
    
    out_dir = os.path.join(OUT_BASE, "run")
    out_paths = [os.path.join(out_dir, f"run_{i+1:02d}.png") for i in range(8)]
    
    # Frames 0, 1, 2
    f0 = img.crop((50, 0, 420, h))
    f1 = img.crop((430, 0, 750, h))
    f2 = img.crop((760, 1100, h)) if False else img.crop((760, 0, 1100, 1010)) # Exclude stray specks below y=1010
    
    # Frames 3 & 4 with boundary seam, keeping within active y-box [350, 1020]
    f3_arr = arr[0:1020, 1120:1460].copy()
    for y in range(f3_arr.shape[0]):
        cx = 1437 if y <= 574 else 1450
        rel_cx = cx - 1120
        if rel_cx < f3_arr.shape[1]:
            f3_arr[y, rel_cx:] = bg
    f3 = Image.fromarray(f3_arr)
    
    f4_arr = arr[0:1020, 1430:1820].copy()
    for y in range(f4_arr.shape[0]):
        cx = 1437 if y <= 574 else 1450
        rel_cx = cx - 1430
        if rel_cx > 0:
            f4_arr[y, :rel_cx] = bg
    f4 = Image.fromarray(f4_arr)
    
    # Frames 5, 6, 7
    f5 = img.crop((1830, 0, 2150, 1020))
    f6 = img.crop((2160, 0, 2500, h))
    f7 = img.crop((2505, 0, 2880, h))
    
    frames = [f0, f1, f2, f3, f4, f5, f6, f7]
    for idx, f in enumerate(frames):
        clean = remove_bg(f)
        save_to_canvas(clean, out_paths[idx], scale_factor=SCALE_RUN, y_bottom=BASELINE_Y, x_center=240)

def main():
    # 1. Idle (4 frames)
    idle_cuts = [(180, 590), (990, 1330), (1790, 2190), (2630, 3040)]
    idle_outs = [os.path.join(OUT_BASE, "idle", f"idle_{i+1:02d}.png") for i in range(4)]
    extract_standard_sheet("Muslan Idle.jpg", idle_cuts, idle_outs, scale_factor=SCALE_DEFAULT)
    
    # 2. Run (8 frames) - SCALE_RUN = 0.44
    extract_run_sheet()
    
    # 3. Jump (5 frames: takeoff crouch, rise, apex, fall, land)
    jump_cuts = [(110, 605), (760, 1190), (1350, 1810), (1950, 2530), (2600, 3050)]
    jump_outs = [
        os.path.join(OUT_BASE, "jump", "jump_crouch.png"),
        os.path.join(OUT_BASE, "jump", "jump_rise.png"),
        os.path.join(OUT_BASE, "jump", "jump_apex.png"),
        os.path.join(OUT_BASE, "jump", "jump_fall.png"),
        os.path.join(OUT_BASE, "jump", "jump_land.png"),
    ]
    # For airborne frames (rise, apex, fall), head is placed at natural eye-level (y=65..75) with feet floating above ground
    jump_head_ys = [None, 65, 55, 70, None]
    jump_y_bottoms = [BASELINE_Y, None, None, None, BASELINE_Y]
    extract_standard_sheet("Muslan Jump.jpg", jump_cuts, jump_outs, scale_factor=SCALE_AIR, y_bottoms=jump_y_bottoms, head_ys=jump_head_ys)
    
    # 4. Hurt (3 frames)
    hurt_cuts = [(120, 810), (1240, 2090), (2400, 3050)]
    hurt_outs = [
        os.path.join(OUT_BASE, "hurt", "hurt_stagger.png"),
        os.path.join(OUT_BASE, "hurt", "hurt_hit.png"),
        os.path.join(OUT_BASE, "hurt", "hurt_reeling.png"),
    ]
    extract_standard_sheet("Muslan Hurt.jpg", hurt_cuts, hurt_outs, scale_factor=SCALE_DEFAULT)
    
    # 5. Wall (3 frames) - scale 0.35, aligned with wall
    wall_cuts = [(200, 700), (1300, 1820), (2360, 3050)]
    wall_outs = [
        os.path.join(OUT_BASE, "wall", "wall_slide.png"),
        os.path.join(OUT_BASE, "wall", "wall_cling.png"),
        os.path.join(OUT_BASE, "wall", "wall_jump.png"),
    ]
    extract_standard_sheet("Muslan Wall.jpg", wall_cuts, wall_outs, scale_factor=SCALE_AIR, y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y - 20], x_centers=[260, 250, 230])
    
    # 6. Combo Hit 1 (3 frames)
    hit1_cuts = [(40, 950), (1100, 2140), (2140, 3010)]
    hit1_outs = [
        os.path.join(OUT_BASE, "combo", "combo_01_01.png"),
        os.path.join(OUT_BASE, "combo", "combo_01_02.png"),
        os.path.join(OUT_BASE, "combo", "combo_01_03.png"),
    ]
    extract_standard_sheet("Muslan hit 1.jpg", hit1_cuts, hit1_outs, scale_factor=SCALE_DEFAULT, x_centers=[220, 260, 240])
    
    # 7. Combo Hit 2 (3 frames)
    hit2_cuts = [(80, 950), (1190, 2130), (2320, 3040)]
    hit2_outs = [
        os.path.join(OUT_BASE, "combo", "combo_02_01.png"),
        os.path.join(OUT_BASE, "combo", "combo_02_02.png"),
        os.path.join(OUT_BASE, "combo", "combo_02_03.png"),
    ]
    extract_standard_sheet("Muslan hit 2.jpg", hit2_cuts, hit2_outs, scale_factor=SCALE_DEFAULT, x_centers=[220, 250, 230])
    
    # 8. Combo Hit 3 (3 frames)
    hit3_cuts = [(160, 830), (990, 2170), (2220, 3090)]
    hit3_outs = [
        os.path.join(OUT_BASE, "combo", "combo_03_01.png"),
        os.path.join(OUT_BASE, "combo", "combo_03_02.png"),
        os.path.join(OUT_BASE, "combo", "combo_03_03.png"),
    ]
    extract_standard_sheet("Muslan hit 3.jpg", hit3_cuts, hit3_outs, scale_factor=SCALE_DEFAULT, x_centers=[220, 260, 230])
    
    print("\nExtraction complete!")

if __name__ == '__main__':
    main()
