import os
from PIL import Image
import numpy as np
from collections import deque

CANVAS_W = 640
CANVAS_H = 560
BASELINE_Y = 490 # Ground level / feet anchor

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

def find_frame_cuts(arr, n_expected):
    h, w, _ = arr.shape
    border = np.concatenate([arr[:8, :].reshape(-1, 3), arr[-8:, :].reshape(-1, 3)], axis=0)
    bg = np.median(border, axis=0)
    diff = np.max(np.abs(arr.astype(float) - bg), axis=2)
    fg = diff > 25
    col_counts = np.sum(fg, axis=0)
    
    cuts = [0]
    for i in range(1, n_expected):
        expected_x = int(w * (i / n_expected))
        search_radius = int(w / (n_expected * 2) * 0.7)
        x_min = max(0, expected_x - search_radius)
        x_max = min(w, expected_x + search_radius)
        
        smooth_w = max(5, int(w * 0.008))
        smoothed = np.convolve(col_counts[x_min:x_max], np.ones(smooth_w) / smooth_w, mode='same')
        best_cut = x_min + np.argmin(smoothed)
        cuts.append(best_cut)
    cuts.append(w)
    return cuts

def process_sheet(src_path, n_frames, out_paths, scale_factor=None, is_jump=False):
    print(f"Processing {os.path.basename(src_path)} -> {len(out_paths)} frames...")
    raw_img = Image.open(src_path).convert('RGB')
    arr = np.array(raw_img)
    cuts = find_frame_cuts(arr, n_frames)
    
    # Process each frame
    for idx in range(n_frames):
        x1, x2 = cuts[idx], cuts[idx+1]
        frame_crop = raw_img.crop((x1, 0, x2, raw_img.height))
        clean_frame = remove_bg(frame_crop)
        
        # Find tight bounding box
        alpha = np.array(clean_frame)[:, :, 3]
        ys, xs = np.where(alpha > 10)
        if len(ys) == 0 or len(xs) == 0:
            print(f"  Warning: empty frame {idx}")
            continue
            
        bx1, bx2 = xs.min(), xs.max()
        by1, by2 = ys.min(), ys.max()
        tight_frame = clean_frame.crop((bx1, by1, bx2 + 1, by2 + 1))
        
        # Apply scaling
        if scale_factor:
            nw = max(1, int(tight_frame.width * scale_factor))
            nh = max(1, int(tight_frame.height * scale_factor))
            scaled_frame = tight_frame.resize((nw, nh), Image.Resampling.LANCZOS)
        else:
            scaled_frame = tight_frame
            
        # Place onto standardized canvas
        canvas = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        
        # Align: bottom at BASELINE_Y, horizontally centered around 270 (allowing forward attack reach)
        # For jump apex/fall, keep it slightly lifted above ground
        target_bottom = BASELINE_Y
        if is_jump and idx in [1, 2]: # Apex and fall
            target_bottom = BASELINE_Y - 50
            
        pos_y = target_bottom - scaled_frame.height
        # Anchor center_x around 260
        pos_x = 260 - (scaled_frame.width // 2)
        
        # Clamp to canvas
        if pos_x < 5:
            pos_x = 5
        if pos_x + scaled_frame.width > CANVAS_W - 5:
            pos_x = CANVAS_W - 5 - scaled_frame.width
            
        canvas.paste(scaled_frame, (pos_x, pos_y), scaled_frame)
        
        out_file = out_paths[idx]
        os.makedirs(os.path.dirname(out_file), exist_ok=True)
        canvas.save(out_file)
        print(f"  Saved {out_file} (tight size: {tight_frame.size} -> scaled: {scaled_frame.size})")

def main():
    # PHASE 1 (Armored Sovereign)
    p1_src = 'assets/characters/the_first_fallen/extracted_p1'
    p1_dst = 'assets/characters/the_first_fallen/phase1'
    
    # Idle: H=1536, char H~1237 -> target H=420 => scale = 420 / 1237 ~ 0.3395
    p1_scale_hires = 420.0 / 1237.0
    # For lowres (Jump, Run, Wall H=572, char H~457 -> target H=420 => scale = 420 / 457 ~ 0.919)
    p1_scale_lowres = 420.0 / 457.0
    # For Hit 1 (H=434, char H~278 -> target H~380 => scale = 380 / 278 ~ 1.367)
    p1_scale_hit1 = 380.0 / 278.0
    
    # P1 Idle (4 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Idle.jpg'), 4,
        [os.path.join(p1_dst, f'idle/idle_{i+1:02d}.png') for i in range(4)],
        scale_factor=p1_scale_hires
    )
    # P1 Run (3 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Run.jpeg'), 3,
        [os.path.join(p1_dst, f'run/run_{i+1:02d}.png') for i in range(3)],
        scale_factor=p1_scale_lowres
    )
    # P1 Jump (4 frames: rise, apex, fall, land)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Jump.jpeg'), 4,
        [
            os.path.join(p1_dst, 'jump/jump_rise.png'),
            os.path.join(p1_dst, 'jump/jump_apex.png'),
            os.path.join(p1_dst, 'jump/jump_fall.png'),
            os.path.join(p1_dst, 'jump/jump_land.png')
        ],
        scale_factor=p1_scale_lowres,
        is_jump=True
    )
    # P1 Wall (3 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Wall.jpeg'), 3,
        [
            os.path.join(p1_dst, 'wall/wall_01.png'),
            os.path.join(p1_dst, 'wall/wall_slide.png'),
            os.path.join(p1_dst, 'wall/wall_03.png')
        ],
        scale_factor=p1_scale_lowres
    )
    # P1 Hit 1 (3 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Hit 1.jpeg'), 3,
        [
            os.path.join(p1_dst, 'combo/combo_01_windup.png'),
            os.path.join(p1_dst, 'combo/combo_01_strike.png'),
            os.path.join(p1_dst, 'combo/combo_01_recover.png')
        ],
        scale_factor=p1_scale_hit1
    )
    # P1 Hit 2 (3 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Hit 2.jpg'), 3,
        [
            os.path.join(p1_dst, 'combo/combo_02_windup.png'),
            os.path.join(p1_dst, 'combo/combo_02_strike.png'),
            os.path.join(p1_dst, 'combo/combo_02_recover.png')
        ],
        scale_factor=p1_scale_hires
    )
    # P1 Hit 3 (3 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Hit 3.jpg'), 3,
        [
            os.path.join(p1_dst, 'combo/combo_03_windup.png'),
            os.path.join(p1_dst, 'combo/combo_03_strike.png'),
            os.path.join(p1_dst, 'combo/combo_03_recover.png')
        ],
        scale_factor=p1_scale_hires
    )
    # P1 Hurt (3 frames)
    process_sheet(
        os.path.join(p1_src, 'First Fallen Hurt.jpg'), 3,
        [
            os.path.join(p1_dst, 'hurt/hurt_01.png'),
            os.path.join(p1_dst, 'hurt/hurt_02.png'),
            os.path.join(p1_dst, 'hurt/hurt_03.png')
        ],
        scale_factor=p1_scale_hires
    )

    # PHASE 2 (Monstrous Beast)
    p2_src = 'assets/characters/the_first_fallen/extracted_p2'
    p2_dst = 'assets/characters/the_first_fallen/phase2'
    
    # All P2 images are 3168 x 1344. Idle char H ~ 1208 -> target H = 450 (huge beast!)
    p2_scale = 450.0 / 1208.0 # ~ 0.3725
    
    # P2 Idle (4 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 idle.jpg'), 4,
        [os.path.join(p2_dst, f'idle/idle_{i+1:02d}.png') for i in range(4)],
        scale_factor=p2_scale
    )
    # P2 Walk (4 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 walk.jpg'), 4,
        [os.path.join(p2_dst, f'walk/walk_{i+1:02d}.png') for i in range(4)],
        scale_factor=p2_scale
    )
    # P2 Jump (4 frames: rise, apex, fall, land)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 jump.jpg'), 4,
        [
            os.path.join(p2_dst, 'jump/jump_rise.png'),
            os.path.join(p2_dst, 'jump/jump_apex.png'),
            os.path.join(p2_dst, 'jump/jump_fall.png'),
            os.path.join(p2_dst, 'jump/jump_land.png')
        ],
        scale_factor=p2_scale,
        is_jump=True
    )
    # P2 Wall (3 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 wall.jpg'), 3,
        [
            os.path.join(p2_dst, 'wall/wall_01.png'),
            os.path.join(p2_dst, 'wall/wall_slide.png'),
            os.path.join(p2_dst, 'wall/wall_03.png')
        ],
        scale_factor=p2_scale
    )
    # P2 Hit 1 (3 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 hit 1.jpg'), 3,
        [
            os.path.join(p2_dst, 'combo/combo_01_windup.png'),
            os.path.join(p2_dst, 'combo/combo_01_strike.png'),
            os.path.join(p2_dst, 'combo/combo_01_recover.png')
        ],
        scale_factor=p2_scale
    )
    # P2 Hit 2 (3 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 hit 2.jpg'), 3,
        [
            os.path.join(p2_dst, 'combo/combo_02_windup.png'),
            os.path.join(p2_dst, 'combo/combo_02_strike.png'),
            os.path.join(p2_dst, 'combo/combo_02_recover.png')
        ],
        scale_factor=p2_scale
    )
    # P2 Hit 3 (3 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 hit 3.jpg'), 3,
        [
            os.path.join(p2_dst, 'combo/combo_03_windup.png'),
            os.path.join(p2_dst, 'combo/combo_03_strike.png'),
            os.path.join(p2_dst, 'combo/combo_03_recover.png')
        ],
        scale_factor=p2_scale
    )
    # P2 Hurt (3 frames)
    process_sheet(
        os.path.join(p2_src, 'The first fallen phase 2 hurt.jpg'), 3,
        [
            os.path.join(p2_dst, 'hurt/hurt_01.png'),
            os.path.join(p2_dst, 'hurt/hurt_02.png'),
            os.path.join(p2_dst, 'hurt/hurt_03.png')
        ],
        scale_factor=p2_scale
    )
    print("ALL SPRITES EXTRACTED AND STANDARDIZED SUCCESSFULLY!")

if __name__ == '__main__':
    main()
